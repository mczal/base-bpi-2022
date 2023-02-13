module GeneralTransactions
  class CreateService < ::BaseService
    def initialize params, company
      @params = params
      @company = company
    end

    def general_transaction
      @general_transaction ||= GeneralTransaction.new(attributes)
    end

    private
      def action
        general_transaction.save!
      end

      def attributes
        @attributes ||= @params.require(:general_transaction).permit(
          :date, :number_evidence, :input_option,
          :rates_source, :rates_group,
          :status, :location, :source,
          :origin_id,
          fixed_rates_options: %i[id],
          end_of_period_rates_options: %i[month year],
          files: [],
          general_transaction_lines_attributes: [
            :group, :code, :is_master_business_units_enabled,
            :master_business_unit_id, :master_business_unit_location_id,
            :master_business_unit_area_id, :master_business_unit_activity_id,
            :description, :price_idr, :price_usd, :rate
          ]
        ).merge({company: @company})
      end
  end
end
