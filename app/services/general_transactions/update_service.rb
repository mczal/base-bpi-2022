module GeneralTransactions
  class UpdateService < ::BaseService
    def initialize params, company
      @params = params
      @company = company
    end

    def general_transaction
      @general_transaction ||= GeneralTransaction.find_by(id: @params[:id])
    end

    private
      def action
        destroy_not_available_lines

        general_transaction.assign_attributes(attributes)
        general_transaction.save!
      end

      def destroy_not_available_lines
        ids = attributes[:general_transaction_lines_attributes].values.map{|x|x[:id]}
        general_transaction.general_transaction_lines
          .where.not(id: ids)
          .destroy_all

        general_transaction.reload
      end

      def attributes
        @attributes ||= @params.require(:general_transaction).permit(
          :date, :number_evidence, :input_option,
          :rates_source, :rates_group,
          fixed_rates_options: %i[id],
          end_of_period_rates_options: %i[month year],
          files: [],
          general_transaction_lines_attributes: [
            :id,
            :group, :code, :is_master_business_units_enabled,
            :master_business_unit_id, :master_business_unit_location_id,
            :master_business_unit_area_id, :master_business_unit_activity_id,
            :description, :price_idr, :price_usd
          ]
        ).merge({company: @company})
      end
  end
end
