module Admin
  module InvTrackings
    module Finances
      module Invoices
        class ActionsController < ::Admin::InvTrackings::Finances::ApplicationController
          def get_ba_detail
            @ba = Ba.find_by(id: params[:ba_id])
            render json: {
              html: render_to_string(layout: false),
              price_currency: @ba.price_currency,
              price: @ba.price.format
            }
          end

          def get_verification
            @invoice = Invoice.find_by(id: params[:id])
            @invoice.assign_attributes(
              pph_percentage: params[:pph_percentage],
              pph_id: params[:pph_id],
              fine: params[:fine],
              bonus: params[:bonus],
              fine_account_id: params[:fine_account_id],
              bonus_account_id: params[:bonus_account_id],
              ppn_cost_group: params[:ppn_cost_group],
            )
            render layout: false
          end
        end
      end
    end
  end
end
