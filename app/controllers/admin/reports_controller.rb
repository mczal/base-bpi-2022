module Admin
  class ReportsController < AdminController
    before_action :report, only: %i[show]
    before_action :show_facade, only: %i[show]

    def index
      @total_reports = Report
        .where(company: current_company)
        .count

      @reports = Report
        .where(company: current_company)
        .page(params[:page])
        .per(10)
    end

    def show; end

    def show_equity
      @show_facade = Admin::Reports::Shows::EquityFacade.new(params)
    end
    def show_financial_statement
      if params[:group].to_s == 'balance_sheet_xlsx'
        @report = Report.balance_sheet_xlsx.first
        @report_idr_version = @report.idr_version
        @report_usd_version = @report.usd_version

        @show_facade_idr = Admin::Reports::Shows::BalanceSheetXlsxFacade.new(params, @report_idr_version)
        @show_facade_usd = Admin::Reports::Shows::BalanceSheetXlsxFacade.new(params, @report_usd_version)
        return
      end
      if params[:group].to_s == 'income_statement_xlsx'
        @report = Report.income_statement_xlsx.first
        @report_idr_version = @report.idr_version
        @report_usd_version = @report.usd_version

        @show_facade_idr = Admin::Reports::Shows::IncomeStatementXlsxFacade.new(params, @report_idr_version)
        @show_facade_usd = Admin::Reports::Shows::IncomeStatementXlsxFacade.new(params, @report_usd_version)
        return
      end
    end

    def destroy
      if report.destroy
        return redirect_to admin_reports_path, notice: "Laporan Berhasil di hapus."
      end

      redirect_to admin_reports_path, alert: "Laporan tidak ditemukan."
    end

    private
      def report
        @report ||= report = Report.find_by(id: params[:id])
      end

      def show_facade
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
  end
end
