module Admin
  class InvoiceDirectExternalsController < ::Admin::InvTrackings::Finances::ApplicationController
    before_action :invoice_direct_external, only: %i[show]

    def index
      @invoice_direct_external = InvoiceDirectExternal.new
    end

    def show; end

    def create
      service = ::InvoiceDirectExternals::CreateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_invoice_direct_externals_path
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_invoice_direct_external_path(id: service.invoice_direct_external.id)
    end

    def update
      service = ::InvoiceDirectExternals::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_invoice_direct_external_path(id: service.invoice_direct_external.id)
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_invoice_direct_external_path(id: service.invoice_direct_external.id)
    end

    def destroy
      ActiveRecord::Base.transaction do
        if invoice_direct_external.destroy
          flash[:success] = "Berhasil!"
          return redirect_to admin_invoice_direct_externals_path(slug: current_company.slug)
        end

        flash[:danger] = "Gagal. #{invoice_direct_external.errors.full_messages.join(", ")}"
        return redirect_back fallback_location: admin_invoice_direct_external_path(id: invoice_direct_external.id,slug: current_company.slug)
      end
    end

    private
      def invoice_direct_external
        @invoice_direct_external ||= InvoiceDirectExternal.find_by(id: params[:id])
      end
  end
end
