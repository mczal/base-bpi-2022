# frozen_string_literal: true

module Admin
  module Reports
    class ActionsController < Admin::ReportsController
      def import_form; end

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
        if export_facade.report.present?
          return respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename=\"#{export_facade.report.name}.xlsx\""
            }
          end
        end

        if params[:id] == "equity"
          return respond_to do |format|
            format.xlsx {
              response.headers['Content-Disposition'] = "attachment; filename='Laporan Perubahan Ekuitas.xlsx'"
              render xlsx: "Laporan Equity", template: 'admin/reports/actions/export_equity'
            }
          end
        end

        redirect_to admin_reports_path, alert: 'Laporan versi XLSX tidak tersedia.'
      end

      # def export_pdf
        # @report = Report.find_by(id: params[:id])

        # if @report.present?
          # @report_facede = Admin::Reports::IndexFacade.new(params, current_company)
          # return respond_to do |format|
            # format.pdf {
              # render pdf: "Laporan #{@report.name}",
                # template: 'admin/reports/actions/export_pdf.html.slim',
                # layout: 'pdf'
            # }
          # end
        # end

        # if params[:id] == "equity"
          # @show_facade = Admin::Reports::Shows::EquityFacade.new(params)
          # return respond_to do |format|
            # format.pdf {
              # render pdf: "Laporan Equity",
                # template: 'admin/reports/actions/export_pdf_equity.html.slim',
                # layout: 'pdf',
                # orientation: 'Landscape'
            # }
          # end
        # end

        # redirect_to admin_reports_path, alert: 'Laporan tidak ditemukan.'
      # end

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

        def report
          return @report if @report.present?
          report_s = Report.find_by(id: params[:id])
          @report = Report.find_by(display: :xlsx, group: "#{report_s.group}_xlsx")
        end

        def export_facade
          return @export_facade if @export_facade.present?

          if params[:id] == 'equity'
            return @export_facade = Admin::Reports::Shows::EquityFacade.new(params)
          end

          return nil unless report.xlsx?
          if report.cash_flow_xlsx?
            return @export_facade = Admin::Reports::Shows::CashFlowXlsxFacade.new(params)
          end
          if report.income_statement_xlsx?
            return @export_facade = Admin::Reports::Shows::IncomeStatementXlsxFacade.new(params)
          end
          if report.balance_sheet_xlsx?
            return @export_facade = Admin::Reports::Shows::BalanceSheetXlsxFacade.new(params)
          end
        end
    end
  end
end
