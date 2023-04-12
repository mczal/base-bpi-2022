module Invoices
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      assign_other_files
      invoice.assign_attributes(invoice_attributes.except(:other_files))
      invoice.status = invoice_status
      invoice.save!
    end

    def invoice
      @invoice ||= Invoice.find_by(id: @params[:id])
    end

    private
      def assign_other_files
        return unless invoice_attributes[:other_files].present?
        invoice_attributes[:other_files].each do |other_file|
          invoice.other_files.attach(other_file)
        end
      end

      def invoice_status
        if invoice_attributes[:bank_account_id].present?
          return :paid
        end
        if @params[:commit].to_s == 'Simpan as Draft'
          return :draft
        end
        if @params[:commit].to_s.match(/simpan/i)
          return :ok
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
          :pph_percentage, :fine, :bonus,
          :fine_account_id, :bonus_account_id,
          :accrued_credit_id,
          :bank_account_id, :spp_checked,
          :invoice_checked, :kwitansi_checked,
          :faktur_pajak_checked,
          other_files: []
        )
      end
  end
end
