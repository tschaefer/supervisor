require 'rails_helper'

RSpec.describe 'Monitors', type: :request do
  describe 'GET /dashboard' do
    it 'returns http success' do
      username = DashboardController.username
      password = DashboardController.password
      auth = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)

      get '/dashboard', headers: { 'HTTP_AUTHORIZATION' => auth }
      expect(response).to have_http_status(:success)
    end
  end
end
