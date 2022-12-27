# frozen_string_literal: true

module Admin
  module Accounts
    class ActionsController < Admin::AccountsController
      def import
        if !parser_service.run
          return redirect_to admin_accounts_path,
            alert: parser_service.error_messages.join('<br/>')
        end

        redirect_to admin_accounts_path, notice: 'File Berhasil di import'
      end

      def download_template
        send_file(
          "#{Rails.root}/public/template/template_import_account.xlsx",
          filename: 'template_import_account.xlsx',
          type: 'application/xlsx'
        )
      end

      private
        def parser_service
          @parser_service ||= ::Accounts::ParserService.new(
            params[:file],
            current_user.company.id
          )
        end

    end
  end
end
