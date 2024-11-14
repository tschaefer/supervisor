class Stack < ApplicationRecord
  include Stack::ValidatesAttribute
  include Stack::PerformsJob
  include Stack::HasStats

  attr_readonly :uuid

  serialize :compose_variables, type: Hash, coder: JSON
  serialize :compose_includes, type: Array, coder: JSON

  after_validation :generate_uuid, on: :create
  after_validation :rackify_signature_header, on: %i[create update]

  # rubocop:disable all
  def self.👽
    puts '👽 All your stacks are belong to us!'
  end
  # rubocop:enable all

  def url
    Addressable::URI.parse(git_repository).tap do |u|
      u.user = git_username
      u.password = git_token
    end
  end

  def environment
    compose_variables.map { |k, v| "#{k}=#{v}" }.join("\n")
  end

  def polling?
    strategy == 'polling'
  end

  def webhook?
    strategy == 'webhook'
  end

  def log
    log_file = StackJob::STACKS_ROOT.join(uuid, 'stack.log')
    return if !File.exist?(log_file)

    last_line = nil
    File.open(log_file, 'r') { |log| log.each { |line| last_line = line } }

    last_line
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def rackify_signature_header
    return if !changes.key?(:signature_header)
    return if signature_header.blank?

    self.signature_header = signature_header.upcase.titleize.tr(' ', '-')
  end
end
