module Admin
  module InvTrackings
    module Finances
      class InvoicesController < ::Admin::InvTrackings::Finances::ApplicationController
        before_action :invoice, only: %i[show]

        def index
          @invoice = Invoice.new
        end

        def show; end

        def create
          service = ::Invoices::CreateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_finances_invoices_path
          end

          flash[:success] = "Berhasil!"
          redirect_to admin_inv_trackings_finances_invoice_path(id: service.invoice.id)
        end

        def update
          service = ::Invoices::UpdateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_finances_invoice_path(id: service.invoice.id)
          end

          flash[:success] = "Berhasil!"
          redirect_to admin_inv_trackings_finances_invoice_path(id: service.invoice.id)
        end

        private
          def invoice
            @invoice ||= Invoice.find_by(id: params[:id])
          end
      end
    end
  end
end
