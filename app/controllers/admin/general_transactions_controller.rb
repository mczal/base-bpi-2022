module Admin
  class GeneralTransactionsController < ::AdminController
    before_action :general_transaction, only: %i[show edit]
    before_action :closed_journals, only: %i[destroy create update]

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

      def closed_journals
        closed_journals = false
        if params[:transaction].present? && params[:transaction][:date].present?
          date = params[:transaction][:date].to_date
          closed_journals = ClosedJournal.where("date >= ?", date)
        end

        if params[:id].present? && general_transaction.present?
          date = general_transaction.date
          closed_journals = ClosedJournal.where("date >= ?", general_transaction.date)
        end

        if closed_journals.present?
          return redirect_to admin_general_transactions_path,
            alert: "Transaksi sudah di tutup di Tutup Buku dan tidak dapat hapus atau di tambah pada bulan #{date.strftime("%m %Y")}."
        end
      end
  end
end
