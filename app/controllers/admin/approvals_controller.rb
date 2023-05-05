module Admin
  class ApprovalsController < AdminController
    layout 'approval'
    include Approvals::RedirectHandlers

    before_action :approval, except: %i[index]
    before_action :pending_approvals, only: %i[index show update]

    def index; end

    def show
      pre_approvals = @approval.pre_approvals
      if pre_approvals.present?
        statuses = pre_approvals.map{|x|x.accepted?}

        if statuses.include?(false)
          pre_approval_failed = pre_approvals.filter do |pre_approval|
            !pre_approval.accepted?
          end

          pre_approval_failed_messages = pre_approval_failed.map.with_index(1) do |pre_approval, i|
            "#{i}. #{pre_approval.name} (#{pre_approval.role.titlecase}) - status: #{I18n.t(pre_approval.status).titlecase}"
          end

          flash[:danger] = "Ada persetujuan yang belum. #{pre_approval_failed_messages}"
          return redirect_to admin_approvals_path(slug: current_company.slug)
        end

        if approval.accepted?
          flash[:success] = "Surat telah disetujui oleh #{approval.name} pada tanggal #{helpers.readable_timestamp_2(approval.updated_at)}"
          return redirect_to admin_approvals_path(slug: current_company.slug)
        end
      end
    end

    def update
      service = Approvals::UpdateService.new(approval, approval_params)
      if !service.run
        flash[:danger] = "Gagal melakukan approval #{service.error_messages.to_sentence}"
        return redirect_to admin_approval_path(id: approval.id, slug: current_company.slug)
      end

      binding.pry
      flash[:success] = "Berhasil melakukan approval"
      next_sibl = approval.next
      if next_sibl.present? && current_user.roles_name.include?(next_sibl.role)
        return redirect_to admin_approval_path(id: next_sibl.id, slug: current_company.slug)
      end
      return redirect_to admin_approvals_path
    end

    def send_notification
      service = Approvals::SendNotificationService.new(approval, current_user.id)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages}"
        return redirect_back fallback_location: root_path
      end

      flash[:success] = "Berhasil mengirim notifikasi persetujuan ke #{service.approver.name}"
      redirect_back fallback_location: root_path
    end

    private
      def approval
        @approval ||= Approval.find_by(id: params[:id])
      end

      def approval_params
        params.require(:approval)
          .permit(:status, :audit_comment)
      end

      def pending_approvals
        return @pendding_approvals if @pendding_approvals.present?
        @pending_approvals = Approval
          .where(role: current_user_roles_name)
          .where.not(status: :accepted)
      end

      def current_user_roles_name
        current_user_roles_name ||= current_user.roles.pluck(:name)
      end
  end
end
