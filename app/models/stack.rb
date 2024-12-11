class Stack < ApplicationRecord
  include Stack::ValidatesAttribute
  include Stack::PerformsJob
  include Stack::HasStats
  include Stack::ReadsLog

  broadcasts_refreshes

  ROOT = ENV.fetch('SUPERVISOR_STACKS_ROOT', Rails.root.join('storage/stack'))

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

  def environment(shellescape: false)
    seperator = shellescape ? '\n' : "\n"

    env = compose_variables.map do |k, v|
      "#{k}=\"#{v}\""
    end.join(seperator)

    env = Shellwords.escape(env) if shellescape

    env
  end

  def polling?
    strategy == 'polling'
  end

  def webhook?
    strategy == 'webhook'
  end

  def log(entries: 1)
    return unless File.exist?(assets.log_file)

    entries = read_log(assets.log_file, entries:)
    return if entries.empty?

    entries
  end

  def assets
    return @assets if defined?(@assets)

    hash = {}.tap do |h|
      base_dir = ROOT.join(uuid)

      h[:base_dir] = base_dir
      h[:env_file] = base_dir.join('stack.env')
      h[:git_dir]  = base_dir.join('git')
      h[:log_file] = base_dir.join('stack.log')
    end
    hash.transform_values!(&:to_s)

    @assets = Hashie::Mash.new(hash)
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def rackify_signature_header
    return unless changes.key?(:signature_header)
    return if signature_header.blank?

    self.signature_header = signature_header.upcase.titleize.tr(' ', '-')
  end
end
