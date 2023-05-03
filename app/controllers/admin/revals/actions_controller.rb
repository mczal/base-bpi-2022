# frozen_string_literal: true

module Admin
  module Revals
    class ActionsController < ::Admin::Revals::ApplicationController
      def edit_account_configuration
        render layout: false
      end

      def update_account_configuration
        service = ::Revals::UpdateAccountConfigurationService.new(params)
        if !service.run
          flash[:danger] = "Gagal. #{service.full_error_messages_html}"
          return redirect_to admin_revals_path
        end

        flash[:success] = "Berhasil!"
        redirect_to admin_revals_path
      end

      private
    end
  end
end

