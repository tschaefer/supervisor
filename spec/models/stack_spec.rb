require 'rails_helper'

RSpec.describe Stack, type: :model do
  before do
    allow_any_instance_of(described_class).to receive(:perform_deploy_job).and_return(true)
    allow_any_instance_of(described_class).to receive(:perform_destroy_job).and_return(true)
  end

  describe 'validations' do
    let(:stack) { create(:stack) }

    it { expect(stack).to validate_presence_of(:name) }
    it { expect(stack).to validate_uniqueness_of(:name) }
    it { expect(stack).to validate_presence_of(:git_repository) }
    it { expect(stack).to validate_presence_of(:git_reference) }
    it { expect(stack).to validate_presence_of(:compose_file) }
    it { expect(stack).to validate_inclusion_of(:strategy).in_array(%w[polling webhook]) }

    it 'checks the repository is a valid URL' do
      stack.git_repository = 'ssh:'

      expect(stack).not_to be_valid
      expect(stack.errors[:git_repository]).to include('is not a valid URL')
    end

    it 'checks repository scheme is one of file, ssh, http, or https' do
      stack.git_repository = 'ftp://example.com'

      expect(stack).not_to be_valid
      expect(stack.errors[:git_repository]).to include('scheme must be one of file, ssh, http, or https')
    end

    it 'generates a uuid on create' do
      stack = create(:stack)

      expect(stack.uuid).not_to be_nil
    end
  end

  describe 'methods' do
    let(:stack) { create(:stack, :with_credentials) }

    describe '#url' do
      it 'returns a URI object with the repository, username, and token' do
        expect(stack.url.to_s).to include(stack.git_username).and include(stack.git_token)
      end
    end

    describe '#environment' do
      it 'returns a string of shell-like environment variables' do
        stack.compose_variables = {
          Faker::Lorem.word => Faker::Lorem.word,
          Faker::Lorem.word => Faker::Lorem.word
        }
        environment = stack.compose_variables.map { |k, v| "#{k}=#{v}" }.join("\n")

        expect(stack.environment).to eq(environment)
      end
    end

    describe '#polling?' do
      it 'returns true when the strategy is polling' do
        stack.strategy = 'polling'

        expect(stack).to be_polling
      end

      it 'returns false when the strategy is not polling' do
        stack.strategy = 'webhook'

        expect(stack).not_to be_polling
      end
    end

    describe '#webhook?' do
      it 'returns true when the strategy is webhook' do
        stack.strategy = 'webhook'

        expect(stack).to be_webhook
      end

      it 'returns false when the strategy is not webhook' do
        stack.strategy = 'polling'

        expect(stack).not_to be_webhook
      end
    end
  end
end
