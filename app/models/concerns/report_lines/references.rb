module ReportLines
  module References extend ActiveSupport::Concern
    def codes_references
      return @codes_references if @codes_references.present?

      return nil if %w(title break).include?(self.group)
      if self.value?
        return @codes_references = report_references.pluck(:account_code)
      end
    end

    def report_references
      @report_references ||= ReportReference.where(
        report_id: self.report_id,
        reference_code: self.codes
      )
    end
  end
end
