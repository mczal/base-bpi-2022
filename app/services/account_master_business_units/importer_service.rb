# frozen_string_literal: true

module AccountMasterBusinessUnits
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :code => 0,
      :account_code => 1,
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
        account = get_account(row)

        relation_1 = AccountMasterBusinessUnit.find_or_initialize_by(
          account: account,
          master_business_unit: get_business_unit(row)
        )
        relation_1.save! if relation_1.new_record?

        relation_2 = AccountMasterBusinessUnit.find_or_initialize_by(
          account: account,
          master_business_unit: get_business_unit_location(row)
        )
        relation_2.save! if relation_2.new_record?

        relation_3 = AccountMasterBusinessUnit.find_or_initialize_by(
          account: account,
          master_business_unit: get_business_unit_area(row)
        )
        relation_3.save! if relation_3.new_record?

        relation_4 = AccountMasterBusinessUnit.find_or_initialize_by(
          account: account,
          master_business_unit: get_business_unit_activity(row)
        )
        relation_4.save! if relation_4.new_record?
      end

      def get_business_unit row
        business_unit_code = get_kode_karyawan(row).first(1)
        MasterBusinessUnit.find_by(code: business_unit_code, group: :business_unit)
      end
      def get_business_unit_location row
        business_unit_location_code = get_kode_karyawan(row)[1..2]
        MasterBusinessUnit.find_by(code: business_unit_location_code, group: :business_unit_location)
      end
      def get_business_unit_area row
        business_unit_area_code = get_kode_karyawan(row)[3..7]
        MasterBusinessUnit.find_by(code: business_unit_area_code, group: :business_unit_area)
      end
      def get_business_unit_activity row
        business_unit_activity_code = get_kode_karyawan(row)[8..11]
        mbu_activity = MasterBusinessUnit.find_by(code: business_unit_activity_code, group: :business_unit_activity)
        return mbu_activity if mbu_activity.present?

        mbu_activity = MasterBusinessUnit.new(
          code: business_unit_activity_code,
          group: :business_unit_activity,
          description: 'N/A'
        )
        mbu_activity.save!
        mbu_activity
      end

      def get_kode_karyawan row
        row[FIELD_MAP[:code]].to_s.strip
      end

      def get_account row
        Account.find_by(code: row[FIELD_MAP[:account_code]].to_s.strip)
      end

      def sheet
        @sheet ||= xlsx.sheet('Akun dan Master Business Unit')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        row[FIELD_MAP[:code]].present?
      end

      def company
        @company ||= Company.find_by(slug: 'bpi')
      end
  end
end
