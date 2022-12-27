# frozen_string_literal: true

module Rates
  class MinistryOfFinanceService < ::Rates::BaseService
    def action
      visit

      if !find_kurs('USD')
        error_messages << "Kurs USD Tidak Ditemukan"
        return false
      end

      save_kurs
    end

    private
      def find_kurs currency
        docs.css(selector).each do |rate_row|
          if !rate_row.css('td span')[1].children.first.content.match(/#{currency}/)
            next
          end

          @selling_rate = rate_row.css('td')[2].children[3].content.to_money
          @buying_rate = rate_row.css('td')[2].children[3].content.to_money
          return true
        end

        return false
      end

      def selector
        @selector ||= 'table.table.table-bordered.table-striped tbody tr'
      end

      def origin
        :ministry_of_finance
      end

      def url
        # Temporay using google cache for scarping fiskal cause original web blocked
        # "https://webcache.googleusercontent.com/search?q=cache:7iexm6SYQc8J:https://fiskal.kemenkeu.go.id/informasi-publik/kurs-pajak+&cd=1&hl=en&ct=clnk&gl=id"
        "https://fiskal.kemenkeu.go.id/informasi-publik/kurs-pajak"
      end
  end
end

