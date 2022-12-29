# frozen_string_literal: true

namespace :banks do
  namespace :seed do
    desc 'Populate bank seed data'
    task populate: :environment do
      url_list_bank_json = 'https://raw.githubusercontent.com/mul14/gudang-data/master/bank/bank.json'
      list_bank_json = JSON.load(URI.open(url_list_bank_json))

      list_bank_json.each do |bank|
        bank = Bank.find_or_initialize_by(
          code: bank["code"],
          name: bank["name"]
        )
        bank.save!
      end
    end
  end
end

