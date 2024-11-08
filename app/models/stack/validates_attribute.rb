class Stack
  module ValidatesAttribute
    extend ActiveSupport::Concern

    included do
      validate :validate_git_repository

      validates :name, presence: true, uniqueness: true
      validates :git_repository, presence: true
      validates :git_reference, presence: true
      validates :compose_file, presence: true
      validates :strategy, inclusion: { in: %w[polling webhook] }, presence: true
      validates :polling_interval, numericality: { only_integer: true, greater_than: 0 },
                                   if: -> { strategy == 'polling' }
      validates :signature_header, presence: true, if: -> { strategy == 'webhook' }
      validates :signature_secret, presence: true, if: -> { strategy == 'webhook' }

      private

      def validate_git_repository
        return if git_repository.blank?

        begin
          uri = Addressable::URI.parse(git_repository)
        rescue Addressable::URI::InvalidURIError
          errors.add(:git_repository, 'is not a valid URL')
          return
        end

        return if %w[ssh http https file].include?(uri.scheme)

        errors.add(:git_repository, 'scheme must be one of file, ssh, http, or https')
      end
    end
  end
end
