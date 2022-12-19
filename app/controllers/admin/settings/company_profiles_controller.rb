# frozen_string_literal: true

module Admin
  module Settings
    class CompanyProfilesController < Admin::ReportsController
      def index
      end

      def create
        if current_company.update(company_params)
          return redirect_to admin_settings_path, notice: 'Company profile was successfully updated.'
        end

        redirect_to admin_settings_company_profiles_path, alert: current_company.errors.errors.full_messages.to_sentence
      end

      private
      def company_params
        params.require(:company).permit(:name, :codename, :slug, :address)
      end
    end
  end
end
