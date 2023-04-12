module Admin
  class RevalsController < ::AdminController
    # include ClosedJournalPolicy
    before_action :reval, only: %i[show edit]

    def index
      @reval = Reval.new
    end

    def create
      service = ::Revals::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_revals_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_reval_path(id: service.reval.id)
    end

    def update
      service = ::Revals::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_reval_path(id: params[:id])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_reval_path(id: params[:id])
    end

    def new
      @reval = Reval.new
      @accounts = current_company.accounts
    end

    def show; end

    def edit
      render partial: 'form'
    end

    def destroy
      ActiveRecord::Base.transaction do
        if reval.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_revals_path
        end

        flash[:danger] = "Gagal. #{reval.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_revals_path
      end
    end

    private
      def reval
        @reval = Reval.find(params[:id])
      end
  end
end
