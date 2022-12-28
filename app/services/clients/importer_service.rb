module Clients
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :number => 0,
      :npwp => 1,
      :name => 2,
      :phone_number => 3,
      :email => 4,
      :address => 5,
      :group => 6,
      :pkp_group => 7,
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
        client = Client.find_or_initialize_by(
          name: get_name(row),
          company: company
        )
        client.assign_attributes(
          npwp: row[FIELD_MAP[:npwp]].to_s.strip,
          phone_number: row[FIELD_MAP[:phone_number]].to_s.strip,
          email: row[FIELD_MAP[:email]].to_s.strip,
          address: row[FIELD_MAP[:address]].to_s.strip,
          group: row[FIELD_MAP[:group]].to_s.strip,
          pkp_group: row[FIELD_MAP[:pkp_group]].to_s.strip,
        )

        client.save! if client.new_record? || client.changed?
      end

      def get_name row
        row[FIELD_MAP[:name]].to_s.strip.upcase
      end
      def company
        @company ||= Company.find_by(slug: :bpi)
      end

      def sheet
        @sheet ||= xlsx.sheet('Master Vendor')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        get_name(row).present?
      end
  end
end

