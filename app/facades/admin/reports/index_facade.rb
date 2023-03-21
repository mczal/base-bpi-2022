# frozen_string_literal: true

module Admin
  module Reports
    class IndexFacade
      def initialize params, current_company
        @params = params
        @current_company = current_company
      end

      def start_date
        @start_date ||= @params[:date]&.to_date&.beginning_of_month || Date.today.beginning_of_month
      end

      def end_date
        @end_date ||= @params[:date]&.to_date&.end_of_month || Date.today
      end

      def report
        return @report if @report.present?
        report_s = Report.find_by(id: @params[:id])
        @report = Report.find_by(display: :xlsx, group: "#{report_s.group}_xlsx")
      end

      def report_a
      end

      private
    end
  end
end
