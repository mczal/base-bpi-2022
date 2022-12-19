module MasterBusinessUnits
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      master_business_unit.assign_attributes(attributes)
      master_business_unit.save!
    end

    def master_business_unit
      @master_business_unit ||= MasterBusinessUnit.find_by(id: @params[:id])
    end

    private
      def attributes
        @params.require(:master_business_unit)
          .permit(:code, :description, :group)
      end
  end
end
