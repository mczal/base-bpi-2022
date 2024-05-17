module Admin
  module Reports
    module Shows
      class BalanceSheetXlsxFacade < ::Admin::Reports::Shows::BaseXlsxFacade
        attr_reader :report

        def initialize params, report=nil
          if report.present?
            @report = report
          else
            @report = Report.xlsx.balance_sheet_xlsx.first
          end
          super(params)
        end

        # def report
          # @report ||= Report.xlsx.balance_sheet_xlsx.first
        # end
        def source_report_lines
          @source_report_lines ||= Report.html.balance_sheet.first.report_lines
        end
        def source_facade
          @source_facade ||= ::Admin::Reports::Shows::BalanceSheetFacade.new(@params)
        end
      end
    end
  end
end
