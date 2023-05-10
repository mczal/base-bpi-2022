module AuditAdjustments
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def audit_adjustment
      @audit_adjustment ||= AuditAdjustment.new(attributes)
    end

    private
      def action
        audit_adjustment.save!
      end

      def attributes
        return @attributes if @attributes.present?
        @attributes = @params.require(:audit_adjustment).permit(
          :date, :period, files: [],
          audit_adjustment_lines_attributes: [
            :group, :description,
            :price_idr, :price_usd,
            :rate, :account_id
          ]
        )
        @attributes[:audit_adjustment_lines_attributes].each do |_,v|
          if !v[:price_idr].present?
            v[:price_idr] = nil
          end
          if !v[:price_usd].present?
            v[:price_usd] = nil
          end
          if !v[:rate].present?
            v[:rate] = nil
          end
        end
        @attributes
      end
  end
end
