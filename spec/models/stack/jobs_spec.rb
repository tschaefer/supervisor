require 'rails_helper'

RSpec.describe 'Stack::performs_job', type: :model do
  let(:stack) { build(:stack) }

  before do
    allow(StackDeployJob).to receive(:perform_later).and_return(true)
    allow(StackPollingJob).to receive(:perform_later).and_return(true)
    allow(StackDestroyJob).to receive(:perform_later).and_return(true)
  end

  context 'when the stack is created' do
    it 'performs a deploy job after creation' do
      stack.save
      expect(StackDeployJob).to have_received(:perform_later).with(stack)
    end

    it 'enqueues a schedule job when the strategy is polling' do
      expect { stack.save }.to have_enqueued_job(StackPollingJob)
    end

    it 'does not enqueue a schedule job when the strategy is webhook' do
      stack.strategy = 'webhook'
      expect { stack.save }.not_to have_enqueued_job(StackPollingJob)
    end
  end

  context 'when the stack is updated' do
    it 'performs a deploy job when relevant info changed' do
      stack.strategy = 'webhook'
      stack.save
      allow(StackDeployJob).to receive(:perform_later)
      stack.update(strategy: 'polling')
      expect(StackDeployJob).to have_received(:perform_later).with(stack)
    end

    it 'does not perfrom a deploy job when no relevant info changed' do
      Stack.skip_callback(:commit, :after, :perform_deploy_job)
      stack.save
      Stack.set_callback(:commit, :after, :perform_deploy_job)
      allow(StackDeployJob).to receive(:perform_now)
      stack.update(name: Faker::App.name)
      expect(StackDeployJob).not_to have_received(:perform_now)
    end

    it 'enqueues a schedule job when the strategy is changed to polling' do
      stack.strategy = 'webhook'
      stack.signature_header = Faker::Lorem.word
      stack.signature_secret = Faker::Lorem.word
      stack.save

      expect { stack.update(strategy: 'polling') }.to have_enqueued_job(StackPollingJob)
    end

    it 'does not enqueue a schedule job when the strategy is changed to webhook' do
      stack.save
      properties = {
        strategy: 'webhook',
        signature_header: Faker::Lorem.word,
        signature_secret: Faker::Lorem.word
      }

      expect { stack.update(properties) }.not_to have_enqueued_job(StackPollingJob)
    end
  end
end
