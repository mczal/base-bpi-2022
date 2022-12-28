# frozen_string_literal: true

module Accounts
  module ReportCategoryForCheckbox extend ActiveSupport::Concern
    def report_categories_for_checkbox
      %w[isak_16 non_isak fiskal].map do |report_category|
        checked = ''
        if self.send("#{report_category}?")
          checked = 'checked="checked"'
        end

        <<-EOS
          <label>
            <input
              type="checkbox" #{checked}
              name="select"
              data-toggle-report-category-path="#"
              disabled="disabled"
            >
            <span></span>
          </label>
          #{report_category}
        EOS
      end
    end
  end
end
