module SavedReportLines
  class GenerateFromCurrentDataService < ::BaseService
    attr_reader :report, :year, :month

    def initialize report, year, month
      @report = report
      @year = year
      @month = month
    end

    def action
      report.report_lines.each.with_index(1) do |report_line,i|
        next if report_line.title?
        if report_line.value?
          idr = facade.calculate_value_idr_for(report_line)
          usd = facade.calculate_value_usd_for(report_line)
        elsif report_line.accumulation?
          idr = facade.calculate_accumulation_idr_for(report_line)
          usd = facade.calculate_accumulation_usd_for(report_line)
        end

        save_to_saved_report_line! report_line, idr, usd
      end
    end

    private
      def save_to_saved_report_line! report_line, idr, usd
        srl = SavedReportLine.find_or_initialize_by(
          report_line_id: report_line.id,
          month: month, year: year,
          date: Date.current.change(month:month,year:year,day:10).end_of_month
        )
        srl.assign_attributes(
          price_idr: idr,
          price_usd: usd,
        )
        srl.save! if srl.new_record? || srl.changed?
      end

      def facade
        return @show_facade if @show_facade.present?
        if report.html?
          if report.cash_flow?
            return @show_facade = Admin::Reports::Shows::CashFlowFacade.new(params)
          elsif report.income_statement?
            return @show_facade = Admin::Reports::Shows::IncomeStatementFacade.new(params)
          elsif report.balance_sheet?
            return @show_facade = Admin::Reports::Shows::BalanceSheetFacade.new(params)
          else
            return @show_facade = Admin::Reports::ShowFacade.new(params)
          end
        end

        if report.xlsx?
          if report.cash_flow_xlsx?
            return @show_facade = Admin::Reports::Shows::CashFlowXlsxFacade.new(params)
          end
          if report.income_statement_xlsx?
            return @show_facade = Admin::Reports::Shows::IncomeStatementXlsxFacade.new(params)
          end
          if report.balance_sheet_xlsx?
            return @show_facade = Admin::Reports::Shows::BalanceSheetXlsxFacade.new(params)
          end
        end
      end

      def params
        {date: "#{month}-#{year}"}
      end
  end
end
