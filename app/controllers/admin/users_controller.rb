module Admin
  class UsersController < AdminController
    before_action :user, only: %i[show edit]

    def index
      @user = User.new(company: current_company)
    end
    def show; end
    def edit
      render partial: 'form'
    end

    def create
      service = ::Users::CreateService.new(params, current_company)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_users_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_users_path
    end
    def update
      service = ::Users::UpdateService.new(params, current_company)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_users_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_users_path
    end

    def destroy
      ActiveRecord::Base.transaction do
        if user.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_users_path
        end

        flash[:danger] = "Gagal. #{user.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_users_path
      end
    end

    private
      def user
        @user = User.find_by(id: params[:id])
      end
  end
end
