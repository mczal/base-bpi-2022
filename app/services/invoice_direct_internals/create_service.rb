module InvoiceDirectInternals
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      invoice_direct_internal.save!
    end

    def invoice_direct_internal
      return @invoice_direct_internal if @invoice_direct_internal.present?

      @invoice_direct_internal = InvoiceDirectInternal.new(invoice_direct_internal_attributes)
      @invoice_direct_internal.status = invoice_direct_internal_status
      @invoice_direct_internal
    end

    private
      def invoice_direct_internal_status
        if invoice_direct_internal_attributes[:bank_account_id].present?
          return :paid
        end
        if @params[:commit].to_s == 'Simpan as Draft'
          return :draft
        end
        :ok
      end

      def invoice_direct_internal_attributes
        @params.require(:invoice_direct_internal).permit(
          :date, :location,
          :ref_number, :description,
          :bank_account_id,
          other_files: [],
          invoice_direct_internal_lines_attributes: [
            :name, :price, :cost_center_id,
            :is_master_business_units_enabled,
            :master_business_unit_id,
            :master_business_unit_location_id,
            :master_business_unit_area_id,
            :master_business_unit_activity_id,
          ]
        )
      end
  end
end
