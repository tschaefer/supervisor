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
        environment = stack.compose_variables.map { |k, v| "#{k}=\"#{v}\"" }.join("\n")

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

    describe '#start' do
      it 'enqueues a StackStartJob' do
        allow(StackStartJob).to receive(:perform_later).and_return(true)

        stack.start
        expect(StackStartJob).to have_received(:perform_later).with(stack)
      end
    end

    describe '#stop' do
      it 'enqueues a StackStopJob' do
        allow(StackStopJob).to receive(:perform_later).and_return(true)

        stack.stop
        expect(StackStopJob).to have_received(:perform_later).with(stack)
      end
    end

    describe '#restart' do
      it 'enqueues a StackRestartJob' do
        allow(StackRestartJob).to receive(:perform_later).and_return(true)

        stack.restart
        expect(StackRestartJob).to have_received(:perform_later).with(stack)
      end
    end

    describe '#redeploy' do
      it 'enqueues a StackDeployJob' do
        allow(StackDeployJob).to receive(:perform_later).and_return(true)

        stack.redeploy
        expect(StackDeployJob).to have_received(:perform_later).with(stack)
      end
    end

    describe '#assets' do
      it 'returns a Hashie::Mash of stack assets' do
        assets = stack.assets

        expect(assets.base_dir).to match(%r{#{stack.uuid}$})
        expect(assets.env_file).to match(%r{#{stack.uuid}/stack.env$})
        expect(assets.git_dir).to match(%r{#{stack.uuid}/git$})
        expect(assets.log_file).to match(%r{#{stack.uuid}/stack.log$})
      end
    end

    describe '#log' do
      before do
        stub_const('Stack::ROOT', Pathname.new(Dir.mktmpdir))
      end

      it 'returns the last line of the log file' do
        base_dir = stack.assets.base_dir
        FileUtils.mkdir_p(base_dir)
        log_file = stack.assets.log_file
        entries = { created_at: Time.current, message: Faker::Lorem.sentence }
        File.write(log_file, entries.to_json)

        expect(stack.log.last).to eq(JSON.parse(File.readlines(log_file).last))
      end

      it 'returns nil when the log file does not exist' do
        expect(stack.log).to be_empty
      end
    end
  end
end
