module Admin
  module InvTrackings
    module Accountings
      module Bas
        class ActionsController < ::Admin::InvTrackings::Procurements::ApplicationController
          def get_contract_detail
            @contract = Contract.find_by(id: params[:contract_id])
            render layout: false
          end
        end
      end
    end
  end
end
