# frozen_string_literal: true

module Rates
  class BankOfIndonesiaService < ::Rates::BaseService
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

        @selling_rate = rate_text.gsub("Rp", "").to_money
        @buying_rate = rate_text.gsub("Rp", "").to_money
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
