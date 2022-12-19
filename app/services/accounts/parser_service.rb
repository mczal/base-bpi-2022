# frozen_string_literal: true

module Accounts
  class ParserService < Accounts::BaseService
    FIELD_MAP = {
      :code => 0,
      :name => 1,
      :subclassification => 3,
      :account_type => 4,
      :subclassification_en => 5,
      :balance_type => 6
    }

    def action
      sheet.each.with_index(1) do |row, i|
        next if i < 4 || !is_row_valid?(row)
        parse_and_save(row, i)
      end
    end

    def is_row_valid? row
      return false if row[FIELD_MAP[:code]].blank?
      return false if row[FIELD_MAP[:name]].blank?
      return false if row[FIELD_MAP[:subclassification]].blank?
      return false if row[FIELD_MAP[:account_type]].blank?
      return false if row[FIELD_MAP[:subclassification_en]].blank?
      return false if row[FIELD_MAP[:balance_type]].blank?
      true
    end

    def parse_and_save row, i
      @raw_row = { index: i,row: row }
      @row = OpenStruct.new(
        FIELD_MAP.map {|key,val| [key, row[val]]}.to_h
      )

      new_account = Account.find_or_initialize_by(
        code: @row.code,
        name: @row.name,
        company_id: @company_id
      )

      new_account.subclassification = @row.subclassification
      new_account.account_type = @row.account_type
      new_account.subclassification_en = @row.subclassification_en
      new_account.balance_type = @row.balance_type
      new_account.save!
    end
  end
end
