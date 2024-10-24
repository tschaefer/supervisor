require 'rails_helper'

RSpec.describe '/stacks', type: :request do
  before do
    allow_any_instance_of(Stack).to receive(:perform_deploy_job).and_return(true)
    allow_any_instance_of(Stack).to receive(:perform_destroy_job).and_return(true)
    allow(StackWebhookJob).to receive(:perform_later).and_return(true)
  end

  let(:valid_attributes) do
    {
      name: Faker::Lorem.unique.word,
      strategy: 'polling',
      polling_interval: 30,
      git_repository: Faker::Internet.unique.url,
      git_reference: 'refs/heads/main',
      compose_file: 'lib/stacks/traefik/docker-compose.yml'
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      git_repository: nil,
      git_reference: nil,
      compose_file: nil
    }
  end

  let(:valid_headers) do
    {
      Authorization: ENV.fetch('SUPERVISOR_API_KEY', Rails.application.credentials.supervisor_api_key)
    }
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Stack.create! valid_attributes
      get stacks_url, headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      stack = Stack.create! valid_attributes
      get stack_url(stack.uuid), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Stack' do
        expect do
          post stacks_url,
               params: { stack: valid_attributes }, headers: valid_headers, as: :json
        end.to change(Stack, :count).by(1)
      end

      it 'renders a JSON response with the new stack' do
        post stacks_url,
             params: { stack: valid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:created)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Stack' do
        expect do
          post stacks_url,
               params: { stack: invalid_attributes }, as: :json
        end.not_to change(Stack, :count)
      end

      it 'renders a JSON response with errors for the new stack' do
        post stacks_url,
             params: { stack: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        {
          name: Faker::Lorem.unique.word,
          git_repository: Faker::Internet.unique.url,
          git_reference: 'refs/heads/main',
          compose_file: 'lib/stacks/traefik/docker-compose.yml'
        }
      end

      it 'updates the requested stack' do
        stack = Stack.create! valid_attributes
        patch stack_url(stack.uuid),
              params: { stack: new_attributes }, headers: valid_headers, as: :json
        stack.reload
        expect(response).to have_http_status(:ok)
        expect(stack.name).to eq(response.parsed_body['name'])
      end

      it 'renders a JSON response with the stack' do
        stack = Stack.create! valid_attributes
        patch stack_url(stack.uuid),
              params: { stack: new_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end

    context 'with invalid parameters' do
      it 'renders a JSON response with errors for the stack' do
        stack = Stack.create! valid_attributes
        patch stack_url(stack.uuid),
              params: { stack: invalid_attributes }, headers: valid_headers, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.content_type).to match(a_string_including('application/json'))
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested stack' do
      stack = Stack.create! valid_attributes
      expect do
        delete stack_url(stack.uuid), headers: valid_headers, as: :json
      end.to change(Stack, :count).by(-1)
    end
  end

  describe 'GET /stats' do
    it 'renders a successful response' do
      stack = Stack.create! valid_attributes
      get stack_stats_url(stack.uuid), headers: valid_headers, as: :json
      expect(response).to be_successful
    end
  end

  describe 'POST /webhook' do
    context 'with invalid signature header' do
      it 'renders a response with error' do
        stack = Stack.create! valid_attributes.merge(
          strategy: 'webhook',
          signature_header: 'X-Hub-Signature',
          signature_secret: SecureRandom.hex(32)
        )
        payload = { message: Faker::Lorem.unique.word }.to_json
        sha256 = SecureRandom.hex(32)

        post stack_webhook_url(stack.uuid), params: JSON.parse(payload),
                                            headers: { 'X-Hub-Signature': "sha256=#{sha256}" }, as: :json
        expect(response).not_to be_successful
        expect(response).to have_http_status(:bad_request)
        expect(response.body).to include('Payload signature is invalid')
      end
    end

    context 'with valid signature header and strategy polling' do
      it 'renders a response with error' do
        stack = Stack.create! valid_attributes.merge(
          signature_header: 'X-Hub-Signature',
          signature_secret: SecureRandom.hex(32)
        )
        payload = { message: Faker::Lorem.unique.word }.to_json
        sha256 = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), stack.signature_secret, payload)

        post stack_webhook_url(stack.uuid), params: JSON.parse(payload),
                                            headers: { 'X-Hub-Signature': "sha256=#{sha256}" }, as: :json
        expect(response).not_to be_successful
        expect(response).to have_http_status(:conflict)
        expect(response.body).to include('Stack strategy is not webhook')
      end
    end

    context 'with valid signature header and strategy webhook' do
      it 'renders a response with success' do
        stack = Stack.create! valid_attributes.merge(
          strategy: 'webhook',
          signature_header: 'X-Hub-Signature',
          signature_secret: SecureRandom.hex(32)
        )
        payload = { message: Faker::Lorem.unique.word }.to_json
        sha256 = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), stack.signature_secret, payload)

        post stack_webhook_url(stack.uuid), params: JSON.parse(payload),
                                            headers: { 'X-Hub-Signature': "sha256=#{sha256}" }, as: :json
        expect(response).to be_successful
        expect(response).to have_http_status(:accepted)
        expect(response.body).to include('Webhook received')
      end
    end
  end
end
