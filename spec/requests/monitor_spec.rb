require 'rails_helper'

RSpec.describe 'Monitors', type: :request do
  describe 'GET /dashboard' do
    it 'returns http success' do
      get '/monitor/dashboard'
      expect(response).to have_http_status(:success)
    end
  end
end
