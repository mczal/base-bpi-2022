# frozen_string_literal: true

module Admin
  module Journals
    class ActionsController < Admin::JournalsController
      def export
        @journals = Journal.where(company: current_company)
        if !current_user.has_role?(:super_admin)
          if current_user.has_role?(:jakarta) && !current_user.has_role?(:site)
            @journals = @journals
              .where(location: :jakarta)
          end
          if !current_user.has_role?(:jakarta) && current_user.has_role?(:site)
            @journals = @journals
              .where(location: :site)
          end
        end

        if date_range.present?
          @journals = @journals
            .where(date: date_range)
        end
        if params[:search].present?
          @journals = @journals
            .search(params[:search])
        end
        if params[:number_evidence].present?
          @journals = @journals.where(
            number_evidence: params[:number_evidence]
          )
        end
        if params[:code].present?
          @journals = @journals.where(
            code: params[:code]
          )
        end
        if params[:location].present?
          @journals = @journals.where(
            location: params[:location]
          )
        end
        if params[:description].present?
          @journals = @journals.where(
            description: params[:description]
          )
        end

        respond_to do |format|
          format.xlsx {
            response.headers['Content-Disposition'] = "attachment; filename=\"[SIAP] Exported Journals #{helpers.readable_timestamp_7(DateTime.now.localtime)}.xlsx\""
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
          return @date_range if @date_range.present?

          if params[:date].present?
            date = Date.strptime(params[:date], '%m-%Y')
            return @date_range = (date.beginning_of_month..date.end_of_month)
          end
        end
    end
  end
end
