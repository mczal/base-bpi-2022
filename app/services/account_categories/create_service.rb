module AccountCategories
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      account_category.save!
    end

    def account_category
      @account_category ||= AccountCategory.new(attributes)
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
