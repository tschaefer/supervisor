class StacksController < ApplicationController
  before_action :set_stack, only: %i[show update destroy stats webhook]
  before_action :authorize, except: :webhook
  before_action :validate_signature, only: :webhook

  # GET /stacks
  def index
    @stacks = Stack.all

    keys = %w[name uuid]
    render json: @stacks.map { |stack| stack.attributes.slice(*keys) }
  end

  # GET /stacks/${uuid}
  def show
    # Getting stats is a separate request.
    stack = @stack.attributes.except('processed', 'failed', 'last_run')
    render json: stack
  end

  # POST /stacks
  def create
    @stack = Stack.new(stack_params)

    if @stack.save
      render json: @stack, status: :created, location: @stack
    else
      render json: { error: @stack.errors }, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /stacks/${uuid}
  def update
    if @stack.update(stack_params)
      render json: @stack
    else
      render json: { error: @stack.errors }, status: :unprocessable_entity
    end
  end

  # DELETE /stacks/${uuid}
  def destroy
    @stack.destroy!
  end

  # GET /stacks/${uuid}/stats
  def stats
    render json: @stack.stats.merge(uuid: @stack.uuid)
  end

  # POST /stacks/${uuid}/webhook
  def webhook
    if @stack.polling?
      render json: { error: 'Stack strategy is not webhook' }, status: :conflict
    else
      StackWebhookJob.perform_later(@stack)
      render json: { message: 'Webhook received' }, status: :accepted
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_stack
    Rails.logger.debug { params.to_json }
    @stack = Stack.find_by!(uuid: params[:uuid])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Stack not found' }, status: :not_found
  end

  def stack_params
    # Using permit with the list of permitted attributes is not possible.
    # The attribute compose_include is an array with unknown elements (file
    # names). The attribute compose_variables is a hash with unknown key-value
    # pairs (environment variables).
    # That is way permit removes the named attributes from the params hash.
    stack = params.require(:stack).permit!

    permitted = %w[
      compose_file
      compose_includes
      compose_variables
      git_reference
      git_repository
      git_token
      git_username
      name
      polling_interval
      signature_header
      signature_secret
      strategy
    ]

    stack.slice(*permitted)
  end
end
