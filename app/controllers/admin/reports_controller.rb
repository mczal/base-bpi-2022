module Admin
  class ReportsController < AdminController
    before_action :report, only: %i[show]

    def index
      @total_reports = Report
        .where(company: current_company)
        .count

      @reports = Report
        .where(company: current_company)
        .page(params[:page])
        .per(10)
    end

    def show
      @show_facade = Admin::Reports::ShowFacade.new(params)
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
  end
end
