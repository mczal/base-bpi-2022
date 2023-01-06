# frozen_string_literal: true

namespace :rates do
  namespace :scrap do
    desc 'Scrap rate from Bank of Indonesia'
    task bank_of_indonesia: :environment do
      Rates::BankOfIndonesiaService.new.run
    end

    desc 'Scrap rate from Ministry Of Finance'
    task ministry_of_finance: :environment do
      Rates::MinistryOfFinanceService.new.run
    end
  end
end

