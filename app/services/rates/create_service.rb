# frozen_string_literal: true

module Rates
  class CreateService < ::BaseService
    def initialize(params)
      @params = params
    end

    def action
      rate.save!
    end

    def rate
      @rate ||= Rate.new(rate_attributes)
    end

    private
      def rate_attributes
        @params.require(:rate)
          .permit(:origin)
          .merge({
            buying: buying,
            selling: selling
          })
      end

      def buying
        @params.require(:rate)[:middle]
      end

      def selling
        @params.require(:rate)[:middle]
      end
  end
end
