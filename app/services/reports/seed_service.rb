module Reports
  class SeedService < ::BaseService
    attr_reader :report

    def initialize
      @date = Date.current.change(day:10,month:12,year:2021).end_of_month
    end

    private
      def action
        seed_for_cash_flow
        seed_for_income_statement
      end

      def seed_for_income_statement
      end

      def seed_for_cash_flow
        cash_flow = Report.cash_flow.first
        report_line = cash_flow.report_lines.last # Saldo Akhir Kas
        saved_report_line = SavedReportLine.find_or_initialize_by(
          report_line_id: report_line.id,
          year: 2021, month: 12,
          date: @date
        )
        saved_report_line.assign_attributes(
          price_idr: 293909897065.339,
          price_usd: 20597416.4550441
        )
        saved_report_line.save! if saved_report_line.new_record? || saved_report_line.changed?
      end
  end
end
