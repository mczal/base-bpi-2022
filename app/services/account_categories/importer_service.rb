module AccountCategories
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :code => 0,
      :bottom_treshold => 1, # int
      :upper_treshold => 2, # int
      :description => 3,
    }

    def initialize file
      @file = file
    end

    def action
      sheet.each_with_index do |row,i|
        next if i == 0 || !is_row_valid?(row)
        find_or_initialize_by_and_save(row)
      end
    end

    private
      def find_or_initialize_by_and_save(row)
        account_category = AccountCategory.find_or_initialize_by(
          code: row[FIELD_MAP[:code]].to_s.strip,
          bottom_treshold: row[FIELD_MAP[:bottom_treshold]].to_i,
          upper_treshold: row[FIELD_MAP[:upper_treshold]].to_i,
        )

        account_category.assign_attributes(
          description: row[FIELD_MAP[:description]].to_s.strip,
        )
        account_category.save! if account_category.new_record? || account_category.changed?
      end

      def sheet
        @sheet ||= xlsx.sheet('Kategori')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        row[FIELD_MAP[:code]].present? &&
          row[FIELD_MAP[:bottom_treshold]].present? &&
          row[FIELD_MAP[:upper_treshold]].present?
      end
  end
end
