# frozen_string_literal: true

module Approvals
  class UpdateService < BaseService
    def initialize approval, approval_params
      @approval = approval
      @approval_params = approval_params
    end

    def validate_before_action
      return if @approval_params[:status] == 'rejected'
      if @approval_params[:status] == 'accepted'
        pre_approvals = @approval.pre_approvals
        statuses = pre_approvals.map{|x|x.accepted?}

        if statuses.include?(false)
          pre_approval_failed = pre_approvals.filter do |pre_approval|
            !pre_approval.accepted?
          end

          pre_approval_failed_messages = pre_approval_failed.map.with_index(1) do |pre_approval, i|
            "#{i}. #{pre_approval.name} (#{pre_approval.role.titlecase}) - status: #{I18n.t(pre_approval.status).titlecase}"
          end

          error_messages << "Gagal, ada persetujuan yang belum. <br/> #{pre_approval_failed_messages.join('<br/>')}"
          return
        end
      end
    end

    def action
      @approval.assign_attributes(@approval_params)
      return unless @approval.changed?
      @approval.save!

      if @approval.accepted?
        forward_notification(:next)
      end
    end

    private
      def forward_notification direction
        to_be_notified_approval = @approval.send(direction)
        return unless to_be_notified_approval.present?

        to_be_notified_approver = to_be_notified_approval
          .approvers
          .where
          .not(email: 'admin@wellcode.io')
          .first
        return unless to_be_notified_approver.present?

        # service = ::Approvals::SendNotificationService.new(
          # to_be_notified_approval, to_be_notified_approver.id
        # )
        # service.run
      end
  end
end
