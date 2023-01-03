module Admin
  module Reports
    class ShowFacade
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

      def calculate_value_idr_for report_line
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
        def balance_idr codes, formula
          script = formula.dup
          script = script
            .gsub('${debit}', debit_balance_idr(codes).amount.to_s)
            .gsub('${credit}', credit_balance_idr(codes).amount.to_s)
          @balance_idr = eval(script).to_money
        end
        def debit_balance_idr codes
          @debit_balance_idr = Journal.find_by_sql(
            <<-EOS
              SELECT SUM(debit_idr_cents) as debit_idr_cents, debit_idr_currency
              FROM journals
              WHERE code IN (#{codes.map{|x|"'#{x}'"}.join(',')}) AND
                date BETWEEN '#{start_date}' AND '#{end_date}' AND
                number_evidence ILIKE '%BNI%'
              GROUP BY debit_idr_currency
            EOS
          ).first&.debit_idr.to_money
        end
        def credit_balance_idr codes
          @credit_balance_idr = Journal.find_by_sql(
            <<-EOS
              SELECT SUM(credit_idr_cents) as credit_idr_cents, credit_idr_currency
              FROM journals
              WHERE code IN (#{codes.map{|x|"'#{x}'"}.join(',')}) AND
                date BETWEEN '#{start_date}' AND '#{end_date}' AND
                number_evidence ILIKE '%BNI%'
              GROUP BY credit_idr_currency
            EOS
          ).first&.credit_idr.to_money
        end

        def balance_usd codes, formula
          script = formula.dup
          script = script
            .gsub('${debit}', debit_balance_usd(codes).amount.to_s)
            .gsub('${credit}', credit_balance_usd(codes).amount.to_s)
          @balance_usd = eval(script).to_money.with_currency(:usd)
        end
        def debit_balance_usd codes
          @debit_balance_usd = Journal.find_by_sql(
            <<-EOS
              SELECT SUM(debit_usd_cents) as debit_usd_cents, debit_usd_currency
              FROM journals
              WHERE code IN (#{codes.map{|x|"'#{x}'"}.join(',')}) AND
                date BETWEEN '#{start_date}' AND '#{end_date}' AND
                number_evidence ILIKE '%BNI%'
              GROUP BY debit_usd_currency
            EOS
          ).first&.debit_usd.to_money.with_currency(:usd)
        end
        def credit_balance_usd codes
          @credit_balance_usd = Journal.find_by_sql(
            <<-EOS
              SELECT SUM(credit_usd_cents) as credit_usd_cents, credit_usd_currency
              FROM journals
              WHERE code IN (#{codes.map{|x|"'#{x}'"}.join(',')}) AND
                date BETWEEN '#{start_date}' AND '#{end_date}' AND
                number_evidence ILIKE '%BNI%'
              GROUP BY credit_usd_currency
            EOS
          ).first&.credit_usd.to_money.with_currency(:usd)
        end
    end
  end
end
