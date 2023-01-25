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

    def destroy
      if report.destroy
        return redirect_to admin_reports_path, notice: "Laporan Berhasil di hapus."
      end

      redirect_to admin_reports_path, alert: "Laporan tidak ditemukan."
    end

    private
      def report
        @report ||= Report.find_by(id: params[:id])
      end

      def show_facade
        return @show_facade if @show_facade.present?

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
  end
end
