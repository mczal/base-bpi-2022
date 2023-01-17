module ApprovalConfigurations
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    private
      def action
        attributes.each do |attr|
          ac = ApprovalConfiguration.find_by(id: attr[:id])
          ac.assign_attributes(attr.except(:id))
          ac.save! if ac.changed?
        end
      end

      def attributes
        @attributes ||= @params[:approval_configuration].map do |p|
          p.permit(
            :id, :bottom_treshold, :upper_treshold,
            roles: []
          )
        end
      end
  end
end
