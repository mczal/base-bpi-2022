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

      if %i[draft ok].include?(invoice_status)
        invoice.general_transactions.destroy_all
      end
      if invoice_status == :verified
        invoice.general_transactions.invoice_paid.destroy_all
        gt = invoice.general_transactions.invoice_approved.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
      if invoice_status == :paid
        gt = invoice.general_transactions.invoice_paid.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
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
        return @invoice_status if @invoice_status.present?

        if invoice_attributes[:bank_account_id].present?
          return @invoice_status = :paid
        end
        if @params[:commit].to_s == 'Simpan as Draft'
          return @invoice_status = :draft
        end
        if @params[:commit].to_s.match(/simpan/i)
          return @invoice_status = :ok
        end
        if @invoice.accrued_credit_id.present?
          return @invoice_status = :verified
        end
        @invoice_status = :ok
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
          :bamp_checked, :bapb_checked,
          :bastp_checked, :copy_perjanjian_checked,
          :copy_spmk_checked, :copy_npwp_pkp_checked,
          :jaminan_pemeliharaan_checked,
          other_files: [],
          faktur_pajak_attributes: [
            :faktur_link, :file_png, :file_pdf,
          ]
        )
      end
  end
end
