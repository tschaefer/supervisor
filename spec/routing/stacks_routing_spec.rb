require 'rails_helper'

RSpec.describe StacksController, type: :routing do
  describe 'routing' do
    let(:uuid) { SecureRandom.uuid }

    it 'routes to #index' do
      expect(get: '/stacks').to route_to('stacks#index')
    end

    it 'routes to #show' do
      expect(get: "/stacks/#{uuid}").to route_to('stacks#show', uuid:)
    end

    it 'routes to #create' do
      expect(post: '/stacks').to route_to('stacks#create')
    end

    it 'routes to #update via PUT' do
      expect(put: "/stacks/#{uuid}").to route_to('stacks#update', uuid:)
    end

    it 'routes to #update via PATCH' do
      expect(patch: "/stacks/#{uuid}").to route_to('stacks#update', uuid:)
    end

    it 'routes to #destroy' do
      expect(delete: "/stacks/#{uuid}").to route_to('stacks#destroy', uuid:)
    end

    it 'routes to #webhook' do
      expect(post: "/stacks/#{uuid}/webhook").to route_to('stacks#webhook', uuid:)
    end

    it 'routes to #stats' do
      expect(get: "/stacks/#{uuid}/stats").to route_to('stacks#stats', uuid:)
    end

    it 'routes to #control' do
      expect(post: "/stacks/#{uuid}/control").to route_to('stacks#control', uuid:)
    end

    it 'routes to #log' do
      expect(get: "/stacks/#{uuid}/log").to route_to('stacks#log', uuid:)
    end
  end
end
