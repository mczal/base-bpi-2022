module InvoiceDirectExternals
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      invoice_direct_external.save!
    end

    def invoice_direct_external
      return @invoice_direct_external if @invoice_direct_external.present?
      @invoice_direct_external = InvoiceDirectExternal.new(invoice_direct_external_attributes)
      @invoice_direct_external.status = invoice_direct_external_status
      @invoice_direct_external
    end

    private
      def invoice_direct_external_status
        if invoice_direct_external_attributes[:bank_account_id].present?
          return :paid
        end
        if @params[:commit].to_s == 'Simpan as Draft'
          return :draft
        end
        :ok
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
