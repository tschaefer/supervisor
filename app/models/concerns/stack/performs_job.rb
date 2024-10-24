class Stack
  module PerformsJob
    extend ActiveSupport::Concern

    included do
      after_save_commit    :perform_deploy_job
      after_destroy_commit :perform_destroy_job

      private

      def perform_deploy_job
        keys = %w[
          compose_file
          compose_includes
          compose_variables
          git_reference
          git_repository
          git_token
          git_username
          git_variables
        ]
        StackDeployJob.perform_later(self) if saved_changes.keys.any? { |key| keys.include?(key) }

        return if !saved_change_to_strategy?
        return cancel_polling_job if webhook?

        StackPollingJob.set(wait: polling_interval).perform_later(self)
      end

      def perform_destroy_job
        keys = %w[
          compose_file
          compose_includes
          id
          uuid
        ]
        slice = attributes.slice(*keys)

        StackDestroyJob.perform_later(slice)

        return if webhook?

        cancel_polling_job
      end

      def cancel_polling_job
        return if Rails.application.config.active_job.queue_adapter != :solid_queue

        SolidQueue::Job.where(class_name: 'StackPollingJob', finished_at: nil)
                       .where('arguments like ?', "%#{to_global_id}%")
      end
    end
  end
end
