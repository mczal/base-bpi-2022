# frozen_string_literal: true

module AccountBeginningBalances
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :account_code => 3,
      :account_name => 4,
      :balance_idr => 5,
      :balance_usd => 6,
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
        account_beginning_balance = AccountBeginningBalance.find_or_initialize_by(
          code: account.code,
          year: year
        )
        account_beginning_balance.price_idr = price_idr(row)
        account_beginning_balance.price_usd = price_usd(row)
        if account_beginning_balance.new_record? || account_beginning_balance.changed?
          account_beginning_balance.save!
        end
      end

      def get_account row
        Account.find_by(code: account_code(row))
      end
      def price_idr row
        row[FIELD_MAP[:balance_idr]].to_f.to_money
      end
      def price_usd row
        row[FIELD_MAP[:balance_usd]].to_f.to_money.with_currency(:usd)
      end
      def account_code row
        row[FIELD_MAP[:account_code]].to_s.strip.split('.')[0]
      end

      def year
        @year ||= sheet.cell(1,2)
      end

      def sheet
        @sheet ||= xlsx.sheet('Saldo Awal 2024 - TB')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        get_account(row).present?
      end

      def company
        @company ||= Company.find_by(slug: 'bpi')
      end
  end
end
