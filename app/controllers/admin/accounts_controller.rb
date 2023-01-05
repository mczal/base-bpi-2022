class Admin::AccountsController < AdminController
  before_action :account, only: %i[edit show]

  def index
    @account = Account.new
  end

  def create
    service = ::Accounts::CreateService.new(params, current_company)
    if !service.run
      flash[:danger] = "Gagal. #{service.full_error_messages_html}"
      return redirect_to admin_accounts_path(slug: params[:slug])
    end

    flash[:success] = "Berhasil!"
    redirect_to admin_accounts_path(slug: params[:slug])
  end

  def show; end

  def edit
    render partial: 'form'
  end

  def update
    service = ::Accounts::UpdateService.new(params)
    if !service.run
      flash[:danger] = "Gagal. #{service.full_error_messages_html}"
      return redirect_to admin_accounts_path(slug: params[:slug])
    end

    flash[:success] = "Berhasil!"
    redirect_to admin_accounts_path(slug: params[:slug])
  end

  def destroy
    ActiveRecord::Base.transaction do
      if account.general_transaction_lines.present? || account.journals.present?
        flash[:danger] = "Gagal. Akun tidak bisa dihapus, masih ada data transaksi yang berhubungan dengan akun ini."
        return redirect_back fallback_location: admin_accounts_path(slug: params[:slug])
      end

      account.destroy!
      flash[:success] = "Berhasil!"
      return redirect_to admin_accounts_path(slug: params[:slug])
    end
  end

  private
    def account
      @account = Account.find(params[:id])
    end
end
