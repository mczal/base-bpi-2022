module Admin
  module Reports
    class ShowFacade
      def initialize params
        @params = params
        @results = {}
      end

      def start_date
        return @start_date if @start_date.present?
        if !@params[:start_date].present?
          return @start_date = DateTime.now.localtime.to_date.beginning_of_year
        end

        @start_date = Date.strptime(@params[:start_date], '%d/%m/%Y')
      end
      def end_date
        return @end_date if @end_date.present?
        if !@params[:end_date].present?
          return @end_date = DateTime.now.localtime.to_date.beginning_of_year
        end

        @end_date = Date.strptime(@params[:end_date], '%d/%m/%Y')
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
          @results[report_line.name][:price_idr] = balance_idr(report_line.codes_references)
        else
          @results[report_line.name] = {
            price_idr: balance_idr(report_line.codes_references)
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
          @results[report_line.name][:price_usd] = balance_usd(report_line.codes_references)
        else
          @results[report_line.name] = {
            price_usd: balance_usd(report_line.codes_references)
          }
        end

        @results[report_line.name][:price_usd]
      end

      private
        def balance_idr codes
          @balance_idr = debit_balance_idr(codes) - credit_balance_idr(codes)
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

        def balance_usd codes
          @balance_usd = debit_balance_usd(codes) - credit_balance_usd(codes)
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
