# frozen_string_literal: true

module Accounts
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :code => 0,
      :name => 1,
      :balance_type => 2,
      :isak_16 => 3,
      :non_isak => 4,
      :fiskal => 5,
      :account_category_code => 6,
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
        account = Account.find_or_initialize_by(
          code: row[FIELD_MAP[:code]].to_s.strip,
          company: company
        )
        account.assign_attributes(
          name: row[FIELD_MAP[:name]].to_s.strip,
          balance_type: get_balance_type(row),
          isak_16: get_isak_16(row),
          non_isak: get_non_isak(row),
          fiskal: get_fiskal(row),
          account_category: get_account_category(row),
        )
        account.save! if account.new_record? || account.changed?
      end

      def get_balance_type row
        balance_type = row[FIELD_MAP[:balance_type]].to_s.strip
        if balance_type == 'K'
          return :kredit
        end
        if balance_type == 'D'
          return :debit
        end
      end
      def get_isak_16 row
        isak_16 = row[FIELD_MAP[:isak_16]].to_s.strip
        if isak_16 == 'Y'
          return true
        else
          return false
        end
      end
      def get_non_isak row
        non_isak = row[FIELD_MAP[:non_isak]].to_s.strip
        if non_isak == 'Y'
          return true
        else
          return false
        end
      end
      def get_fiskal row
        fiskal = row[FIELD_MAP[:fiskal]].to_s.strip
        if fiskal == 'Y'
          return true
        else
          return false
        end
      end
      def get_account_category row
        AccountCategory.find_by(code: row[FIELD_MAP[:account_category_code]].to_s.strip)
      end

      def sheet
        @sheet ||= xlsx.sheet('Chart of Accounts')
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
