module MasterBusinessUnits
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :code => 1,
      :description => 2,
      :group => 3,
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
        master_business_unit = MasterBusinessUnit.find_or_initialize_by(
          code: row[FIELD_MAP[:code]].to_s.strip,
          group: row[FIELD_MAP[:group]].to_s.strip,
        )

        master_business_unit.assign_attributes(
          description: row[FIELD_MAP[:description]].to_s.strip,
        )
        master_business_unit.save! if master_business_unit.new_record? || master_business_unit.changed?
      end

      def sheet
        @sheet ||= xlsx.sheet('Master Business Unit')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        row[FIELD_MAP[:code]].present?
      end
  end
end
