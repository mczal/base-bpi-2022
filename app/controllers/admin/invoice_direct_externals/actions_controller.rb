module Admin
  module InvoiceDirectExternals
    class ActionsController < ::Admin::InvTrackings::Procurements::ApplicationController
      def get_client_detail
        @client = Client.find_by(id: params[:client_id])
        render layout: false
      end
    end
  end
end