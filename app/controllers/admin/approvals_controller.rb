module Admin
  class ApprovalsController < AdminController
    before_action :approval, except: %i[index]
    before_action :pending_approvals, only: %i[index show update]
    layout 'approval'

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
          return redirect_to admin_approvals_path
        end

        if approval.accepted?
          flash[:success] = "Surat telah disetujui oleh #{approval.name} pada tanggal #{readable_timestamp_2(approval.updated_at)}"
          return redirect_to admin_approvals_path
        end
      end
    end

    def update
      service = Approvals::UpdateService.new(approval, approval_params)
      if !service.run
        flash[:danger] = "Gagal melakukan approval #{service.error_messages.to_sentence}"
        return redirect_to admin_general_transaction_path(id: @approval.approvable_id) if @approval.GeneralTransaction?
        return redirect_to admin_asset_path(id: @approval.approvable.asset.id) if @approval.AssetSale?
      end
      flash[:success] = "Berhasil melakukan approval"
      return redirect_to admin_general_transaction_path(id: @approval.approvable_id) if @approval.GeneralTransaction?
      return redirect_to admin_asset_path(id: @approval.approvable.asset.id) if @approval.AssetSale?
    end

    def send_notification
      service = Approvals::SendNotificationService.new(approval, params[:approver_id])
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages}"
        return redirect_back fallback_location: admin_root_path
      end

      flash[:success] = "Berhasil mengirim notifikasi persetujuan ke #{service.approver.name}"
      redirect_back fallback_location: admin_root_path
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