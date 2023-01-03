module Admin
  class ReportLinesController < ::AdminController
    before_action :report_line, only: %i[edit]

    def edit
      render partial: 'form'
    end

    def update
      service = ::ReportLines::UpdateService.new(params)
      if !service.run
        flash[:danger] = "Gagal. #{service.full_error_messages_html}"
        return redirect_to admin_report_path(slug: params[:slug], id: params[:id], tag: :configuration)
      end

      flash[:success] = "Berhasil!"
      redirect_to admin_report_path(slug: params[:slug], id: report_line.report_id, tag: :configuration)
    end

    private
      def report_line
        @report_line = ReportLine.find_by(id: params[:id])
      end
  end
end
