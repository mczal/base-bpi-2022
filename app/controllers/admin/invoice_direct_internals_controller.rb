module Admin
  class InvoiceDirectInternalsController < ::Admin::InvTrackings::Finances::ApplicationController
    before_action :invoice_direct_internal, only: %i[show]

    def index
      @invoice_direct_internal = InvoiceDirectInternal.new
    end

    def show; end

    def create
      service = ::InvoiceDirectInternals::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_invoice_direct_internals_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_invoice_direct_internal_path(id: service.invoice_direct_internal.id)
    end

    def update
      service = ::InvoiceDirectInternals::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_invoice_direct_internal_path(id: service.invoice_direct_internal.id)
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_invoice_direct_internal_path(id: service.invoice_direct_internal.id)
    end

    def destroy
      ActiveRecord::Base.transaction do
        if invoice_direct_internal.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_invoice_direct_internals_path(slug: current_company.slug)
        end

        flash[:danger] = "Gagal. #{invoice_direct_internal.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_invoice_direct_internal_path(id: invoice_direct_internal.id,slug: current_company.slug)
      end
    end

    private
      def invoice_direct_internal
        @invoice_direct_internal ||= InvoiceDirectInternal.find_by(id: params[:id])
      end
  end
end
