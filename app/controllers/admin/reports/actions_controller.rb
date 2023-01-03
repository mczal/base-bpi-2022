# frozen_string_literal: true

module Admin
  module Reports
    class ActionsController < Admin::ReportsController

      def import_form
      end

      def import_preview
        return render partial: "admin/reports/partials/table_report_lines",
          locals: { report_facede: report_facede }
      end

      def import
        if params[:import][:file].present? && !parser_service.run
          return redirect_to admin_reports_path,
            alert: parser_service.error_messages.join('<br/>')
        end

        redirect_to admin_reports_path, notice: 'File Berhasil di import'
      end

      def download_template
        if params[:file_name].present?
          send_file(
            "#{Rails.root}/public/sample/#{params[:file_name]}",
            filename: "#{params[:file_name]}",
            type: 'application/xlsx'
          )
        end
      end

      def export
        @report = Report.find_by(id: params[:id])
        return redirect_to admin_reports_path, alert: 'Laporan tidak ditemukan.' if @report.blank?
        @report_facede = Admin::Reports::IndexFacade.new(params, current_company)
        respond_to do |format|
          format.xlsx {
            response.headers['Content-Disposition'] = "attachment; filename=\"Laporan #{@report.name}.xlsx\""
          }
        end
      end

      def export_pdf
        @report = Report.find_by(id: params[:id])
        return redirect_to admin_reports_path, alert: 'Laporan tidak ditemukan.' if @report.blank?
        @report_facede = Admin::Reports::IndexFacade.new(params, current_company)
        respond_to do |format|
          format.pdf {
            render pdf: "Laporan #{@report.name}",
              template: 'admin/reports/actions/export_pdf.html.slim',
              layout: 'pdf'
          }
        end
      end

      private
        def parser_service
          @file_blob = ActiveStorage::Blob.find_signed(params[:import][:file].first, purpose: :blob_id)
          @file = url_for(@file_blob)
          @parser_service ||= ::Reports::ImporterService.new(
            @file,
            current_user.company.id
          )
        end

        def preview_parser_service
          @file_blob = ActiveStorage::Blob.find_signed(params[:id], purpose: :blob_id)
          @file = url_for(@file_blob)
          @preview_parser_service = ::Reports::ParserPreviewService.new(
            @file,
            current_user.company.id
          )
        end

        def report_facede
          preview_parser_service.run
          @report = @preview_parser_service.report
          @report_facede = ::Admin::Reports::PreviewFacade.new(@report)
        end
    end
  end
end
