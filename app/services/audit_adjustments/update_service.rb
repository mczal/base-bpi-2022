module AuditAdjustments
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def audit_adjustment
      @audit_adjustment ||= AuditAdjustment.find_by(id: @params[:id])
    end

    private
      def action
        destroy_not_available_lines

        audit_adjustment.assign_attributes(attributes)
        handle_status_change_if_from_draft

        audit_adjustment.save!
      end

      def handle_status_change_if_from_draft
        return unless audit_adjustment.draft?
        audit_adjustment.status = :waiting_for_approval
      end

      def destroy_not_available_lines
        ids = attributes[:audit_adjustment_lines_attributes].values.map{|x|x[:id]}
        audit_adjustment.audit_adjustment_lines
          .where.not(id: ids)
          .destroy_all

        audit_adjustment.reload
      end

      def attributes
        return @attributes if @attributes.present?
        @attributes = @params.require(:audit_adjustment).permit(
          :date, :period, files: [],
          audit_adjustment_lines_attributes: [
            :group, :description,
            :price_idr, :price_usd,
            :account_id
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
