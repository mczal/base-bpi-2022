module Admin
  module Reports
    module Shows
      class BaseFacade
        attr_reader :results

        def initialize params
          @params = params
          @results = {}
        end

        def start_date
          return @start_date if @start_date.present?
          if !@params[:date].present?
            return @start_date = DateTime.now.localtime.to_date.beginning_of_month
          end

          @start_date = Date.strptime(@params[:date], '%m-%Y').beginning_of_month
        end
        def end_date
          @end_date ||= start_date.end_of_month
        end

        def calculate_accumulation_idr_for report_line
          saved = report_line.saved_report_lines.find_by(month: start_date.month, year: start_date.year)
          if saved.present?
            if @results[report_line.name].present?
              @results[report_line.name][:price_idr] = saved.price_idr
            else
              @results[report_line.name] = {
                price_idr: saved.price_idr
              }
            end

            return @results[report_line.name][:price_idr]
          end

          formula = report_line.formula.dup
          @results.each do |k,v|
            formula = formula.gsub("${#{k}}", v[:price_idr].amount.to_s)
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_idr] = eval(formula).to_money
          else
            @results[report_line.name] = {
              price_idr: eval(formula).to_money
            }
          end

          @results[report_line.name][:price_idr]
        end
        def calculate_accumulation_usd_for report_line
          saved = report_line.saved_report_lines.find_by(month: start_date.month, year: start_date.year)
          if saved.present?
            if @results[report_line.name].present?
              @results[report_line.name][:price_usd] = saved.price_usd
            else
              @results[report_line.name] = {
                price_usd: saved.price_usd
              }
            end

            return @results[report_line.name][:price_usd]
          end

          formula = report_line.formula.dup
          @results.each do |k,v|
            formula = formula.gsub("${#{k}}", v[:price_usd]&.amount.to_s)
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_usd] = eval(formula).to_money.with_currency(:usd)
          else
            @results[report_line.name] = {
              price_usd: eval(formula).with_currency(:usd)
            }
          end

          @results[report_line.name][:price_usd]
        end

        def calculate_value_idr_for report_line
          saved = report_line.saved_report_lines.find_by(month: start_date.month, year: start_date.year)
          if saved.present?
            if @results[report_line.name].present?
              @results[report_line.name][:price_idr] = saved.price_idr
            else
              @results[report_line.name] = {
                price_idr: saved.price_idr
              }
            end

            return @results[report_line.name][:price_idr]
          end

          if !report_line.codes_references.present?
            @results[report_line.name] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
            return @results[report_line.name][:price_idr]
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_idr] = balance_idr(report_line.codes_references, report_line.formula)
          else
            @results[report_line.name] = {
              price_idr: balance_idr(report_line.codes_references, report_line.formula)
            }
          end

          @results[report_line.name][:price_idr]
        end
        def calculate_value_usd_for report_line
          saved = report_line.saved_report_lines.find_by(month: start_date.month, year: start_date.year)
          if saved.present?
            if @results[report_line.name].present?
              @results[report_line.name][:price_usd] = saved.price_usd
            else
              @results[report_line.name] = {
                price_usd: saved.price_usd
              }
            end

            return @results[report_line.name][:price_usd]
          end

          if !report_line.codes_references.present?
            @results[report_line.name] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
            return @results[report_line.name][:price_usd]
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_usd] = balance_usd(report_line.codes_references, report_line.formula)
          else
            @results[report_line.name] = {
              price_usd: balance_usd(report_line.codes_references, report_line.formula)
            }
          end

          @results[report_line.name][:price_usd]
        end

        private
      end
    end
  end
end
