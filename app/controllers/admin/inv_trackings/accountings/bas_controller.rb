module Admin
  module InvTrackings
    module Accountings
      class BasController < ::Admin::InvTrackings::Accountings::ApplicationController
        before_action :ba, :contract, only: %i[show]

        def index
          @ba = Ba.new
        end

        def show; end

        def create
          service = ::Bas::CreateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_accountings_bas_path
          end

          flash[:success] = "Berhasil!"
          redirect_to admin_inv_trackings_accountings_ba_path(id: service.ba.id)
        end

        def update
          service = ::Bas::UpdateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_accountings_ba_path(id: service.ba.id)
          end

          flash[:success] = "Berhasil!"
          redirect_to admin_inv_trackings_accountings_ba_path(id: service.ba.id)
        end

        private
          def ba
            @ba ||= Ba.find_by(id: params[:id])
          end
          def contract
            @contract ||= ba.contract
          end
      end
    end
  end
end