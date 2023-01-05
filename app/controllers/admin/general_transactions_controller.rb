module Admin
  class GeneralTransactionsController < ::AdminController
    include ClosedJournalPolicy
    before_action :general_transaction, only: %i[show edit]

    def index
      @general_transaction = GeneralTransaction.new(company: current_company)
    end

    def create
      service = ::GeneralTransactions::CreateService.new(params, current_company)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_general_transactions_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_general_transaction_path(id: service.general_transaction.id)
    end

    def update
      service = ::GeneralTransactions::UpdateService.new(params, current_company)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_general_transaction_path(id: params[:id])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_general_transaction_path(id: params[:id])
    end

    def new
      @transaction = GeneralTransaction.new
      @accounts = current_company.accounts
    end

    def show; end

    def edit
      render partial: 'form'
    end

    def destroy
      ActiveRecord::Base.transaction do
        if general_transaction.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_general_transactions_path
        end

        flash[:danger] = "Gagal. #{general_transaction.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_general_transactions_path
      end
    end

    private
      def general_transaction
        @general_transaction = GeneralTransaction.find(params[:id])
      end
  end
end
