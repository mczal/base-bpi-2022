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
        @attributes ||= @params.require(:reval).permit(
          :date, files: [],
          reval_lines_attributes: [
            :group, :description,
            :price_idr, :price_usd
          ]
        )
      end
  end
end
