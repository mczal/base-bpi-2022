# frozen_string_literal: true

module Admin
  module Journals
    class ActionsController < Admin::JournalsController
      def export
        @journals = Journal.where(date: date_range, company: current_company)
        respond_to do |format|
          format.xlsx {
            response.headers['Content-Disposition'] = "attachment; filename=\"Journals.xlsx\""
          }
        end
      end

      def import
        if !importer_service.run
          flash[:danger] = "Gagal. #{importer_service.full_error_messages_html}"
          return redirect_to admin_journals_path
        end

        flash[:success] = "Berhasil!"
        redirect_to admin_journals_path
      end

      def download_template
        send_file(
          "#{Rails.root}/public/template/template_journal.xlsx",
          filename: 'template_journal.xlsx',
          type: 'application/xlsx'
        )
      end

      private
        def importer_service
          @importer_service = ::Journals::ImporterService.new(params[:file])
        end

        def date_range
          if params[:start_date].present? && params[:end_date].present?
            return (params[:start_date].to_date..params[:end_date].to_date)
          end
          return (Date.today.beginning_of_year..Date.today.end_of_month)
        end
    end
  end
end
