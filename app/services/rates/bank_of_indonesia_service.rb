# frozen_string_literal: true

module Rates
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
      if !find_kurs
        error_messages << "Kurs USD Tidak Ditemukan"
        return false
      end

      save_kurs
    end

    private
      def find_kurs currency=nil
        rate_text = docs.css(selector).first.css("td")[1].text
        date_text = docs.css(selector).first.css("td")[0].text
        LOCAL_MONTH_NAMES_MAPPING.each do |k,v|
          date_text = date_text.downcase.gsub(k.downcase, v.downcase)
        end

        @selling_rate = rate_text.gsub("Rp", "").to_money
        @buying_rate = rate_text.gsub("Rp", "").to_money
        @published_date = Date.strptime(date_text, '%d %B %Y')
        return true
      rescue => e
        return false
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
