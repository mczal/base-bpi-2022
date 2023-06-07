module InvoiceDirectExternals
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      assign_other_files
      invoice_direct_external.assign_attributes(invoice_direct_external_attributes.except(:other_files))
      invoice_direct_external.status = invoice_direct_external_status
      invoice_direct_external.save!

      if invoice_direct_external_status == :draft
        invoice_direct_external.general_transactions.destroy_all
      end
      if invoice_direct_external_status == :ok
        gt = invoice_direct_external.general_transactions.invoice_direct_external_paid.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
      if invoice_direct_external_status == :paid
        gt = invoice_direct_external.general_transactions.invoice_direct_external_paid.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
    end

    def invoice_direct_external
      @invoice_direct_external ||= InvoiceDirectExternal.find_by(id: @params[:id])
    end

    private
      def assign_other_files
        return unless invoice_direct_external_attributes[:other_files].present?
        invoice_direct_external_attributes[:other_files].each do |other_file|
          invoice_direct_external.other_files.attach(other_file)
        end
      end

      def invoice_direct_external_status
        return @invoice_direct_external_status if @invoice_direct_external_status.present?

        if @params[:commit].to_s == 'Simpan as Draft'
          return @invoice_direct_external_status = :draft
        end
        if @params[:commit].to_s.match(/simpan/i)
          return @invoice_direct_external_status = :ok
        end
        @invoice_direct_external_status = :ok
      end

      def invoice_direct_external_attributes
        @params.require(:invoice_direct_external).permit(
          :client_id, :bank_id, :account_number, :account_holder,
          :location,

          :date, :ref_number, :receipt_number, :description,
          :price_currency, :price,
          :ppn_group, :ppn_cost_group, :ppn_percentage,
          :tax_receipt_number, :tax_receipt_date,
          :bank_account_id, :cost_center_id,
          :faktur_pajak_checked,

          :is_master_business_units_enabled,
          :master_business_unit_id,
          :master_business_unit_location_id,
          :master_business_unit_area_id,
          :master_business_unit_activity_id,

          other_files: [],
          faktur_pajak_attributes: [
            :faktur_link, :file_png, :file_pdf,
          ]
        )
      end
  end
end
