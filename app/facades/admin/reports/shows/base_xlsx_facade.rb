module Admin
  module Reports
    module Shows
      class BaseXlsxFacade
        def initialize params
          @params = params
          @results = {}
          @source_results = {}
          setup
        end
        def setup
          start_date && end_date
          init_source_facade_calculation
        end

        def calculate_value_idr_for report_line
          formula = report_line.formula.dup
          @source_results.each do |k,v|
            formula = formula.gsub("${#{k}}", v[:price_idr].amount.to_s)
          end
          result = eval(formula).to_money

          if @results[report_line.name].present?
            @results[report_line.name][:price_idr] = result
          else
            @results[report_line.name] = { price_idr: result }
          end

          @results[report_line.name][:price_idr]
        end

        def calculate_value_usd_for report_line
          formula = report_line.formula.dup
          @source_results.each do |k,v|
            formula = formula.gsub("${#{k}}", v[:price_usd].amount.to_s)
          end
          result = eval(formula).to_money.with_currency(:usd)

          if @results[report_line.name].present?
            @results[report_line.name][:price_usd] = result
          else
            @results[report_line.name] = { price_usd: result }
          end

          @results[report_line.name][:price_usd]
        end

        def calculate_accumulation_idr_for report_line
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

        def init_source_facade_calculation
          source_report_lines.each.with_index(1) do |report_line,i|
            next if report_line.title?

            if report_line.value?
              source_facade.calculate_value_idr_for(report_line)
              source_facade.calculate_value_usd_for(report_line)
            elsif report_line.accumulation?
              source_facade.calculate_accumulation_idr_for(report_line)
              source_facade.calculate_accumulation_usd_for(report_line)
            end

            @source_results[report_line.name] = {
              price_idr: source_facade.accumulated_facade.calculate_value_for(report_line)[:price_idr],
              price_usd: source_facade.accumulated_facade.calculate_value_for(report_line)[:price_usd],
            }
          end
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
      end
    end
  end
end

