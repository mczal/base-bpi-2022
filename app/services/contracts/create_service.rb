module Contracts
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      contract.save!
    end

    def contract
      return @contract if @contract.present?
      @contract = Contract.new(contract_attributes)
      @contract.status = contract_status
      @contract
    end

    private
      def contract_status
        if @params[:submit_button] == 'Simpan as Draft'
          return :draft
        end
        :waiting
      end

      def contract_attributes
        @params.require(:contract).permit(
          :client_id, :bank_id, :account_number, :account_holder,
          :ref_number, :description, :price, :price_currency,
          :started_at, :ended_at, :started_with_group,
          :started_with_ref_number, :started_with_date,
          :time_period, :payment_time_period,
          :payment_time_period_group, :contract_file,
          :accrued_debit_id, :location,
          :is_master_business_units_enabled,
          :master_business_unit_id,
          :master_business_unit_location_id,
          :master_business_unit_area_id,
          :master_business_unit_activity_id,
          :started_with_file, other_files: []
        )
      end
  end
end
