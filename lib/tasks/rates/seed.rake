# frozen_string_literal: true

namespace :rates do
  namespace :seed do
    desc 'Seed rate from Bank of Indonesia'
    task bank_of_indonesia: :environment do
      # Rates::BankOfIndonesiaService.new.run
      data = [
        {
          price: 14278,
          month: 12,
          year: 2021
        },
        {
          price: 14392,
          month: 1,
          year: 2022
        },
        {
          price: 14369,
          month: 2,
          year: 2022
        },
        {
          price: 14357,
          month: 3,
          year: 2022
        },
        {
          price: 14480,
          month: 4,
          year: 2022
        },
        {
          price: 14592,
          month: 5,
          year: 2022
        },
        {
          price: 14882,
          month: 6,
          year: 2022
        },
        {
          price: 14860,
          month: 7,
          year: 2022
        },
        {
          price: 14853,
          month: 8,
          year: 2022
        },
        {
          price: 15232,
          month: 9,
          year: 2022
        },
        {
          price: 15596,
          month: 10,
          year: 2022
        },
        {
          price: 15742,
          month: 11,
          year: 2022
        },
        {
          price: 15592,
          month: 12,
          year: 2022
        },
        {
          price: 14992,
          month: 1,
          year: 2023
        },
        {
          price: 15240,
          month: 2,
          year: 2023
        },
        {
          price: 14977,
          month: 3,
          year: 2023
        },
        {
          price: 14661,
          month: 4,
          year: 2023
        },
        {
          price: 15003,
          month: 5,
          year: 2023
        },
      ]

      data.each do |entry|
        date = DateTime.now
        date = date.change(
          month: entry[:month],
          year: entry[:year],
          day: 20,
          hour:8,minute:0,second:0
        )
        date = date.change(day: date.end_of_month.day)

        rate = Rate.find_or_initialize_by(
          created_at: date,
          origin: :bank_of_indonesia
        )
        rate.published_date = date
        rate.buying = entry[:price]
        rate.selling = entry[:price]
        rate.origin = :bank_of_indonesia
        rate.save! if rate.new_record? || rate.changed?
      end
    end

    desc 'Seed rate from Ministry Of Finance'
    task ministry_of_finance: :environment do
      # Rates::MinistryOfFinanceService.new.run
      data = [
        {
          price: 14294,
          month: 12,
          year: 2021
        },
        {
          price: 14344,
          month: 1,
          year: 2022
        },
        {
          price: 14310,
          month: 2,
          year: 2022
        },
        {
          price: 14351,
          month: 3,
          year: 2022
        },
        {
          price: 14353,
          month: 4,
          year: 2022
        },
        {
          price: 14682,
          month: 5,
          year: 2022
        },
        {
          price: 14837,
          month: 6,
          year: 2022
        },
        {
          price: 15001,
          month: 7,
          year: 2022
        },
        {
          price: 14854,
          month: 8,
          year: 2022
        },
        {
          price: 15007,
          month: 9,
          year: 2022
        },
        {
          price: 15526,
          month: 10,
          year: 2022
        },
        {
          price: 15688,
          month: 11,
          year: 2022
        },
        {
          price: 15606,
          month: 12,
          year: 2022
        },
        {
          price: 15109,
          month: 1,
          year: 2023
        },
        {
          price: 15191,
          month: 2,
          year: 2023
        },
        {
          price: 15304,
          month: 3,
          year: 2023
        },
        {
          price: 14824,
          month: 4,
          year: 2023
        },
        {
          price: 14919,
          month: 5,
          year: 2023
        },
      ]

      data.each do |entry|
        date = DateTime.now
        date = date.change(
          month: entry[:month],
          year: entry[:year],
          day: 20,
          hour:8,minute:0,second:0
        )
        date = date.change(day: date.end_of_month.day)

        rate = Rate.find_or_initialize_by(
          created_at: date,
          origin: :ministry_of_finance
        )
        rate.published_date = date
        rate.buying = entry[:price]
        rate.selling = entry[:price]
        rate.origin = :ministry_of_finance
        rate.save! if rate.new_record? || rate.changed?
      end
    end
  end
end

