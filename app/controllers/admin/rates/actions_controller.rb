module Admin
  module Rates
    class ActionsController < ::AdminController
      before_action :rates, only: %i[get_select_options]

      def get_select_options
        render layout: false
      end

      private
        def rates
          @rates ||= Rate.where(origin: params[:origin]).limit(31*4)
        end
    end
  end
end
