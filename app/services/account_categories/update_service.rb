module AccountCategories
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      account_category.assign_attributes(attributes)
      account_category.save!
    end

    def account_category
      @account_category ||= AccountCategory.find_by(id: @params[:id])
    end

    private
      def attributes
        @params.require(:account_category)
          .permit(
            :bottom_treshold,
            :upper_treshold,
            :description
          )
      end
  end
end
