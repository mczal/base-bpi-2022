module MasterBusinessUnits
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      master_business_unit.save!
    end

    def master_business_unit
      @master_business_unit ||= MasterBusinessUnit.new(attributes)
    end

    private
      def attributes
        @params.require(:master_business_unit)
          .permit(:code, :description, :group)
      end
  end
end
