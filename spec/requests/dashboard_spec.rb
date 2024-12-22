require 'rails_helper'

RSpec.describe 'Dashboard', type: :request do
  def basic_auth(username: nil, password: nil)
    user = username.presence || DashboardController.username
    pass = password.presence || DashboardController.password
    ActionController::HttpAuthentication::Basic.encode_credentials(user, pass)
  end

  describe 'Authorization' do
    context 'with no credentials' do
      it 'returns http unauthorized' do
        get '/dashboard'
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with invalid credentials' do
      it 'returns http unauthorized' do
        get '/dashboard', headers: { 'HTTP_AUTHORIZATION' => basic_auth(username: 'root') }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with valid credentials' do
      it 'returns http success' do
        get '/dashboard', headers: { 'HTTP_AUTHORIZATION' => basic_auth }
        expect(response).to have_http_status(:success)
      end
    end
  end

  context 'with stack UUID parameter' do
    it 'stores UUID in DOM' do
      stack_uuid = SecureRandom.uuid
      get "/dashboard?uuid=#{stack_uuid}", headers: { 'HTTP_AUTHORIZATION' => basic_auth }
      expect(response.body).to include(stack_uuid)
    end
  end
end
