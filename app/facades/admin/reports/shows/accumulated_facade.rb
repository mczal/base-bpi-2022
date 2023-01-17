module Admin
  module Reports
    module Shows
      class AccumulatedFacade
        def initialize start_date, end_date, origin_facade
          @start_date = start_date
          @end_date = end_date
          @origin_facade = origin_facade
          @result = {}
        end

        def calculate_value_for report_line
          if daterange.present?
            price_idr = SavedReportLine.find_by_sql(
              <<-EOS
                SELECT SUM(price_idr_cents) as price_idr_cents, price_idr_currency
                FROM saved_report_lines
                WHERE month BETWEEN '#{daterange[0].first}' AND '#{daterange[0].last}'
                AND year = '#{daterange[1]}'
                AND report_line_id = '#{report_line.id}'
                GROUP BY price_idr_currency
              EOS
            ).first&.price_idr.to_money

            price_usd = SavedReportLine.find_by_sql(
              <<-EOS
                SELECT SUM(price_usd_cents) as price_usd_cents, price_usd_currency
                FROM saved_report_lines
                WHERE month BETWEEN '#{daterange[0].first}' AND '#{daterange[0].last}'
                AND year = '#{daterange[1]}'
                AND report_line_id = '#{report_line.id}'
                GROUP BY price_usd_currency
              EOS
            ).first&.price_usd.to_money.with_currency(:usd)
          else
            price_idr = 0.to_money
            price_usd = 0.to_money.with_currency(:usd)
          end

          @result[report_line.name] = {
            price_idr: price_idr + @origin_facade.results.dig(report_line.name, :price_idr).to_money,
            price_usd: price_usd + @origin_facade.results.dig(report_line.name, :price_usd).to_money.with_currency(:usd)
          }
        end

        private
          def daterange
            return @daterange if @daterange.present?
            start = @end_date.beginning_of_year
            return nil if start.month == @end_date.month

            month_range = (start.month...@end_date.month).to_a
            @daterange = (month_range.first)..(month_range.last), start.year
          end
      end
    end
  end
end
