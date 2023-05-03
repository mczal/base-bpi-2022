module Revals
  class CreateService < ::BaseService
    def initialize params
      @params = params
    end

    def reval
      @reval ||= Reval.new(attributes)
    end

    private
      def action
        reval.save!
      end

      def attributes
        return @attributes if @attributes.present?
        @attributes = @params.require(:reval).permit(
          :date, :periode, files: [],
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
