# frozen_string_literal: true

module Admin
  module Settings
    class GeneralImportersController < AdminController
      def index; end

      def create
        results = []
        services.each do |service|
          results << {
            status: service.run,
            messages: service.full_error_messages_html
          }
        end

        if !results.map{|x|x[:status]}.include?(true)
          flash[:danger] = "Gagal. #{results.map{|x|x[:messages]}.to_sentence}"
        elsif results.map{|x|x[:status]}.include?(false)
          flash[:warning] = "Ada yang gagal. #{results.map{|x|x[:messages]}.to_sentence}"
        else
          flash[:success] = "Berhasil"
        end
        redirect_to admin_settings_general_importers_path
      end

      private
        def services
          @services ||= [
            master_business_units_service,
            account_categories_service,
            accounts_service,
            account_master_business_units_service,
            account_beginning_balances_service,
            # journals_service,
            clients_service,
          ]
        end

        def master_business_units_service
          @master_business_units_service = ::MasterBusinessUnits::ImporterService.new(params[:file])
        end
        def account_categories_service
          @account_categories_service = ::AccountCategories::ImporterService.new(params[:file])
        end
        def accounts_service
          @accounts_service = ::Accounts::ImporterService.new(params[:file])
        end
        def account_master_business_units_service
          @account_master_business_units_service = ::AccountMasterBusinessUnits::ImporterService.new(params[:file])
        end
        def account_beginning_balances_service
          @account_beginning_balances_service = ::AccountBeginningBalances::ImporterService.new(params[:file])
        end
        def journals_service
          @journals_service = ::Journals::ImporterService.new(params[:file])
        end
        def clients_service
          @clients_service = ::Clients::ImporterService.new(params[:file])
        end
    end
  end
end
