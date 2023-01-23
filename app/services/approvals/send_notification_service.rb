# frozen_string_literal: true

module Approvals
  class SendNotificationService < BaseService
    def initialize approval, approver_id
      @approval = approval
      @approver_id = approver_id
    end

    def validate_before_action
      if !approver.present?
        error_messages << "User (approver) tidak ditemukan"
        return
      end
      if !approver.has_role?(@approval.role)
        error_messages << "User (approver) tidak memiliki hak akses #{@approval.role.titlecase}"
        return
      end

      pre_approvals = @approval.pre_approvals
      statuses = pre_approvals.map{|x|x.accepted?}

      if statuses.include?(false)
        pre_approval_failed = pre_approvals.filter do |pre_approval|
          !pre_approval.accepted?
        end

        pre_approval_failed_messages = pre_approval_failed.map.with_index(1) do |pre_approval, i|
          "#{i}. #{pre_approval.name} (#{pre_approval.role.titlecase}) - status: #{I18n.t(pre_approval.status).titlecase}"
        end

        error_messages << " ada persetujuan yang belum. <br/> #{pre_approval_failed_messages.join('<br/>')}"
        return
      end
    end

    def action
      # return if !Rails.env.staging? && !Rails.env.production?

      Notifications::WhatsappJob.perform_later(
        approver.id,
        message
      )
    end

    def approver
      return @approver if @approver.present?
      return nil unless @approver_id.present?
      @approver = User.find_by(id: @approver_id)
    end

    private

      def message
        messages = []
        messages << "Notifikasi PT BPI"
        messages << ""
        messages << "Permintaan persetujuan pada Transaksi"
        messages << "No. #{approvable.number_evidence}"
        messages << "Kepada #{@approval.role.titlecase} - #{approver.name}"
        messages << "Silahkan klik pada link berikut untuk melakukan proses persetujuan:"
        messages << "#{link}"
        messages << ""
        messages << "Terima kasih."
        messages << "Salam,"
        messages << ""
        messages << "PT BPI"
        messages << "Pinterusaha.ai"
        messages.join("\n")
      end

      def approvable
        @approvable ||= @approval.approvable
      end

      def link
        @link ||= Rails.application.routes.url_helpers.admin_approval_url(
          host: ENV['HOST'],
          id: @approval.id
        )
      end
  end
end
