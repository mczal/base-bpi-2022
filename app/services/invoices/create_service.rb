module Invoices
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      invoice.save!
    end

    def invoice
      return @invoice if @invoice.present?
      @invoice = Invoice.new(invoice_attributes)
      @invoice.status = invoice_status
      @invoice
    end

    private
      def invoice_status
        if invoice_attributes[:bank_account_id].present?
          return :paid
        end
        if @params[:commit].to_s == 'Simpan as Draft'
          return :draft
        end
        if @invoice.accrued_credit_id.present?
          return :verified
        end
        :ok
      end

      def invoice_attributes
        @params.require(:invoice).permit(
          :invoiceable_id, :invoiceable_type,
          :spp_number, :date,
          :ref_number, :receipt_number, :price,
          :price_currency, :tax_receipt_number,
          :tax_receipt_date,
          :spp_file, :file, :receipt_file,
          :tax_receipt_file, :ppn_group,
          :ppn_cost_group, :pph_id, :ppn_percentage,
          :pph_percentage, :fine,
          :accrued_credit_id,
          :bank_account_id, :spp_checked,
          :invoice_checked, :kwitansi_checked,
          :faktur_pajak_checked,
          other_files: [],
          faktur_pajak_attributes: [
            :faktur_link, :file_png, :file_pdf,
          ]
        )
      end
  end
end
