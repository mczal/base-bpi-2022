module Admin
  module Settings
    class ApprovalsController < ::AdminController
      def index; end

      def create
        service = ::ApprovalConfigurations::CreateService.new(params)
        if !service.run
          flash[:danger] = "Gagal. #{service.full_error_messages_html}"
          return redirect_to admin_settings_approvals_path
        end

        flash[:success] = "Berhasil!"
        redirect_to admin_settings_approvals_path
      end
    end
  end
end
