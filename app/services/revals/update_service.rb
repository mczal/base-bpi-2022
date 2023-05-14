module Revals
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def reval
      @reval ||= Reval.find_by(id: @params[:id])
    end

    private
      def action
        destroy_not_available_lines

        reval.assign_attributes(attributes)
        handle_status_change_if_from_draft

        reval.save!

        revoke_journals
        revoke_all_approvals
      end

      def revoke_journals
        return unless reval.approvals.present?
        reval.journals.destroy_all
      end

      def revoke_all_approvals
        reval.approvals.update(status: :waiting)
      end

      def handle_status_change_if_from_draft
        return unless reval.draft?
        reval.status = :waiting_for_approval
      end

      def destroy_not_available_lines
        ids = attributes[:reval_lines_attributes].values.map{|x|x[:id]}
        reval.reval_lines
          .where.not(id: ids)
          .destroy_all

        reval.reload
      end

      def attributes
        return @attributes if @attributes.present?
        @attributes = @params.require(:reval).permit(
          :date, :period, files: [],
          reval_lines_attributes: [
            :group, :description,
            :price_idr, :price_usd,
            :account_id
          ]
        )
        @attributes[:reval_lines_attributes].each do |k,v|
          if !v[:price_idr].present?
            v[:price_idr] = nil
          end
          if !v[:price_usd].present?
            v[:price_usd] = nil
          end
        end
        @attributes
      end
  end
end
