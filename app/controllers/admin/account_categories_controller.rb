module Admin
  class AccountCategoriesController < ::AdminController
    before_action :account_category, only: %i[edit show]

    def index
      @account_category = AccountCategory.new
    end

    def create
      service = ::AccountCategories::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_account_categories_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_account_categories_path(slug: params[:slug])
    end

    def show; end

    def edit
      render partial: 'form'
    end

    def update
      service = ::AccountCategories::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_account_categories_path(slug: params[:slug])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_account_categories_path(slug: params[:slug])
    end

    def destroy
      ActiveRecord::Base.transaction do
        account_category.destroy!
        flash[:success] = "Berhasil!"
        redirect_to admin_account_categories_path(slug: params[:slug])
      end
    end

    private
      def account_category
        @account_category = AccountCategory.find_by(id: params[:id])
      end
  end
end
