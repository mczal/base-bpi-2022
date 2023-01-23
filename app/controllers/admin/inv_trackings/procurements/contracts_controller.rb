module Admin
  module InvTrackings
    module Procurements
      class ContractsController < ::Admin::InvTrackings::Procurements::ApplicationController
        before_action :contract, only: %i[show]

        def index
          @contract = Contract.new
        end

        def show
          # @addendum = Addendum.new
        end

        def create
          service = ::Contracts::CreateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_procurements_contracts_path
          end

          flash[:success] = "Berhasil!"
          if params[:submit_button] == 'Simpan & Lanjut ke Berita Acara'
            return redirect_to admin_inv_trackings_accountings_bas_path(contract_id: service.contract.id, page: :new)
          end
          redirect_to admin_inv_trackings_procurements_contract_path(id: service.contract.id)
        end

        def update
          service = ::Contracts::UpdateService.new(params)
          if !service.run
            flash[:danger] = "Gagal. #{service.full_error_messages_html}"
            return redirect_to admin_inv_trackings_procurements_contract_path(id: service.contract.id)
          end

          flash[:success] = "Berhasil!"

          if params[:submit_button] == 'Simpan & Lanjut ke Berita Acara'
            return redirect_to admin_inv_trackings_accountings_bas_path(contract_id: service.contract.id, page: :new)
          end
          redirect_to admin_inv_trackings_procurements_contract_path(id: service.contract.id)
        end

        def destroy
          ActiveRecord::Base.transaction do
            if contract.destroy
              flash[:success] = "Berhasil!"
              return redirect_to admin_inv_trackings_procurements_contracts_path(slug: current_company.slug)
            end

            flash[:danger] = "Gagal. #{contract.errors.full_messages.join(", ")}"
            return redirect_back fallback_location: admin_inv_trackings_procurements_contract_path(id: contract.id,slug: current_company.slug)
          end
        end

        private
          def contract
            @contract ||= Contract.find_by(id: params[:id])
          end
      end
    end
  end
end
