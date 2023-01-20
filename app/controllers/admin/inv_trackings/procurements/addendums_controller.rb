module Admin
  module InvTrackings
    module Procurements
      class AddendumsController < ::Admin::InvTrackings::Procurements::ApplicationController
        before_action :addendum, only: %i[show]

        def show
          @contract = addendum.contract
        end

        def create
          service = ::Addendums::CreateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_procurements_addendums_path
          end

          flash[:success] = "Berhasil!"
          redirect_to admin_procurements_addendum_path(id: service.addendum.id)
        end

        def update
          service = ::Addendums::UpdateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_procurements_addendum_path(id: service.addendum.id)
          end

          flash[:success] = "Berhasil!"

          if params[:submit_button] == 'Simpan & Lanjut ke Berita Acara'
            return redirect_to admin_accountings_bas_path(addendum_id: service.addendum.id, page: :new)
          end
          redirect_to admin_procurements_addendum_path(id: service.addendum.id)
        end

        def destroy
          addendum.destroy!
          flash[:success] = "Berhasil!"
          redirect_to admin_procurements_contract_path(id: addendum.contract_id)
        end

        private
          def addendum
            @addendum ||= Addendum.find_by(id: params[:id])
          end
      end
    end
  end
end
