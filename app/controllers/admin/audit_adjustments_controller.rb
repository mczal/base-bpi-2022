module Admin
  class AuditAdjustmentsController < ::Admin::AuditAdjustments::ApplicationController
    # include ClosedJournalPolicy
    before_action :audit_adjustment, only: %i[show edit]

    def index
      @audit_adjustment = AuditAdjustment.new
    end

    def create
      service = ::AuditAdjustments::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_audit_adjustments_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_audit_adjustment_path(id: service.audit_adjustment.id)
    end

    def update
      service = ::AuditAdjustments::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.error_messages.to_sentence}"
        return redirect_to admin_audit_adjustment_path(id: params[:id])
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_audit_adjustment_path(id: params[:id])
    end

    def new
      @audit_adjustment = AuditAdjustment.new
      @accounts = current_company.accounts
    end

    def show; end

    def edit
      render partial: 'form'
    end

    def destroy
      ActiveRecord::Base.transaction do
        if audit_adjustment.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_audit_adjustments_path
        end

        flash[:danger] = "Gagal. #{audit_adjustment.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_audit_adjustments_path
      end
    end

    private
      def audit_adjustment
        @audit_adjustment = AuditAdjustment.find(params[:id])
      end
  end
end
