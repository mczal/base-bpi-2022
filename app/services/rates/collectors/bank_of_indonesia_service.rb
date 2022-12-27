# frozen_string_literal: true

module Rates
  module Collectors
    class BankOfIndonesiaService < ::Rates::BaseService
      LOCAL_MONTH_NAMES_MAPPING = {
        'Januari' => 'January',
        'Februari' => 'Februari',
        'Maret' => 'March',
        'April' => 'April',
        'Mei' => 'May',
        'Juni' => 'June',
        'Juli' => 'July',
        'Agustus' => 'August',
        'September' => 'September',
        'Oktober' => 'October',
        'November' => 'November',
        'Desember' => 'December',
      }

      def action
        visit
        binding.pry

        # if !find_kurs
          # error_messages << "Kurs USD Tidak Ditemukan"
          # return false
        # end
        # save_kurs
      end

      private
        def find_kurs currency=nil
          raw_rates = docs.css(selector).map do |x|
            tds = x.css('td')
            [tds[0].text, tds[1].text]
          end

          raw_rates.each do |entry|
            @selling_rate = entry[1].gsub("Rp", "").to_money
            @buying_rate = @selling_rate
          end
        end

        def selector
          @selector ||= '.table tbody tr'
        end

        def origin
          :bank_of_indonesia
        end

        def url
          "https://www.bi.go.id/id/statistik/informasi-kurs/jisdor/default.aspx"
        end
    end
  end
end
