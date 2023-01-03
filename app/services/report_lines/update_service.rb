module ReportLines
  class UpdateService < ::BaseService
    def initialize params
      @params = params
    end

    def action
      run_report_line
      run_report_reference
    end

    def report_line
      @report_line ||= ReportLine.find_by(id: @params[:id])
    end

    private
      def run_report_reference
        report_reference_attributes.each do |p|
          next unless p[:reference_code].present? && p[:account_code].filter{|x|x.present?}.present?

          report_references = ReportReference.where(
            report_id: report_line.report_id,
            reference_code: p[:reference_code]
          )
          origin_codes = report_references.pluck(:account_code)
          param_codes = p[:account_code]

          codes_to_be_removed = origin_codes - param_codes
          codes_to_be_added = param_codes - origin_codes

          report_references_to_be_destroyed = ReportReference.where(
            report_id: report_line.report_id,
            reference_code: p[:reference_code],
            account_code: codes_to_be_removed
          )
          report_references_to_be_destroyed.destroy_all

          codes_to_be_added.each do |c|
            report_reference = ReportReference.new(
              report_id: report_line.report_id,
              reference_code: p[:reference_code],
              account_code: c
            )
            report_reference.save!
          end
        end
      end

      def run_report_line
        report_line.assign_attributes(attributes)
        report_line.save!
      end

      def attributes
        @attributes ||= @params.require(:report_line)
          .permit(:formula)
      end

      def report_reference_attributes
        @report_reference_attributes ||= @params.require(:report_reference).map do |p|
          p.permit(:reference_code, account_code: [])
        end
      end
  end
end
