module InvoiceDirectInternals
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      assign_other_files
      invoice_direct_internal.assign_attributes(invoice_direct_internal_attributes.except(:other_files))
      invoice_direct_internal.status = invoice_direct_internal_status
      invoice_direct_internal.save!

      if invoice_direct_internal_status == :draft
        invoice_direct_internal.general_transactions.destroy_all
      end
      if invoice_direct_internal_status == :ok
        gt = invoice_direct_internal.general_transactions.invoice_direct_internal_paid.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
      if invoice_direct_internal_status == :paid
        gt = invoice_direct_internal.general_transactions.invoice_direct_internal_paid.first
        if gt.present?
          gt.revoke_journals
          gt.revoke_all_approvals
        end
      end
    end

    def invoice_direct_internal
      @invoice_direct_internal ||= InvoiceDirectInternal.find_by(id: @params[:id])
    end

    private
      def assign_other_files
        return unless invoice_direct_internal_attributes[:other_files].present?
        invoice_direct_internal_attributes[:other_files].each do |other_file|
          invoice_direct_internal.other_files.attach(other_file)
        end
      end

      def invoice_direct_internal_status
        return @invoice_direct_internal_status if @invoice_direct_internal_status.present?

        if @params[:commit].to_s == 'Simpan as Draft'
          return @invoice_direct_internal_status = :draft
        end
        if @params[:commit].to_s.match(/simpan/i)
          return @invoice_direct_internal_status = :ok
        end
        @invoice_direct_internal_status = :ok
      end

      def invoice_direct_internal_attributes
        @params.require(:invoice_direct_internal).permit(
          :date, :location,
          :ref_number, :description,
          :bank_account_id,
          other_files: [],
          invoice_direct_internal_lines_attributes: [
            :id,
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
