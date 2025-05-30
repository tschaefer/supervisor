class StacksController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionController::Live
  include StacksController::StreamsLogs

  before_action :set_stack, except: %i[index create]
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
    stack = @stack.attributes.except('processed', 'failed', 'last_run', 'last_action')
    stack['healthy'] = @stack.healthy
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

  # POST /stacks/${uuid}/control
  def control
    command = params[:command]

    allowed_commands = %w[start stop restart redeploy pause unpause]
    return render json: { error: 'Invalid control command' }, status: :bad_request if allowed_commands.exclude?(command)

    @stack.send(command.to_sym)
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

  # GET /stacks/${uuid}/log
  def log
    follow = params.fetch(:follow, false)
    entries = params.fetch(:entries, 1).to_i

    return render json: @stack.log(entries:) unless follow

    response.headers.merge!(
      'Content-Type' => 'text/event-stream',
      'Cache-Control' => 'no-cache',
      'Connection' => 'keep-alive'
    )

    response.headers['rack.hijack'] = proc do |stream|
      Thread.new do
        sse = SSE.new(stream, retry: 100, event: 'open')
        stream_logs(sse)
      end
    end

    head :ok
  end

  private

  def set_stack
    Rails.logger.debug { params.to_json }
    @stack = Stack.find_by!(uuid: params[:uuid])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Stack not found' }, status: :not_found
  end

  def validate_signature
    signature       = request.headers.fetch(@stack.signature_header, nil)
    algorithm, hmac = signature&.split('=')
    payload         = request.body.read
    secret          = @stack.signature_secret

    begin
      return if ActiveSupport::SecurityUtils.fixed_length_secure_compare(
        hmac,
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new(algorithm), secret, payload)
      )
    rescue ArgumentError, TypeError, RuntimeError
      # signature is nil or differs in length
      # bad digest algorithm
    end

    render json: { error: 'Payload signature is invalid' }, status: :bad_request
  end

  def stack_params
    attributes = [
      :compose_file,
      :git_reference,
      :git_repository,
      :git_token,
      :git_username,
      :name,
      :polling_interval,
      :signature_header,
      :signature_secret,
      :strategy,
      { compose_includes: [],
        compose_variables: {} }
    ]
    params.expect(stack: attributes)
  end

  def fetch_log; end
end
