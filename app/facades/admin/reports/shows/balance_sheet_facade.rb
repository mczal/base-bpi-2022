module Admin
  module Reports
    module Shows
      class BalanceSheetFacade < ::Admin::Reports::Shows::BaseFacade
        attr_accessor :income_statement_facade, :income_statement_facade_status

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

          if report_line.name == 'Laba (Rugi) Tahun Berjalan'
            calculate_income_statement_facade

            income_statement_accumulated_value = income_statement_facade
              .accumulated_facade
              .result['LABA (RUGI) SETELAH PAJAK'][:price_idr]
            if @results[report_line.name].present?
              @results[report_line.name][:price_idr] = income_statement_accumulated_value
            else
              @results[report_line.name] = {
                price_idr: income_statement_accumulated_value
              }
            end

            return @results[report_line.name][:price_idr]
          end

          previous_date = (start_date - 1.month)
          previous_saved = report_line.saved_report_lines.find_by(month: previous_date.month, year: previous_date.year)
          while !previous_saved.present?
            previous_date = (previous_date - 1.month)
            previous_saved = report_line.saved_report_lines.find_by(month: previous_date.month, year: previous_date.year)
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_idr] = previous_saved.price_idr
          else
            @results[report_line.name] = {
              price_idr: previous_saved.price_idr
            }
          end

          if !report_line.codes_references.present?
            if !@results[report_line.name][:price_idr].present?
              @results[report_line.name][:price_idr] = 0.to_money
            end
            if !@results[report_line.name][:price_usd].present?
              @results[report_line.name][:price_usd] = 0.to_money.with_currency(:usd)
            end
            # @results[report_line.name] = {
              # price_idr: 0.to_money,
              # price_usd: 0.to_money.with_currency(:usd)
            # }
            return @results[report_line.name][:price_idr]
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_idr] = (
              @results[report_line.name][:price_idr] +
              balance_idr(report_line.codes_references, report_line.formula)
            )
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

          if report_line.name == 'Laba (Rugi) Tahun Berjalan'
            calculate_income_statement_facade

            income_statement_accumulated_value = income_statement_facade
              .accumulated_facade
              .result['LABA (RUGI) SETELAH PAJAK'][:price_usd]
            if @results[report_line.name].present?
              @results[report_line.name][:price_usd] = income_statement_accumulated_value
            else
              @results[report_line.name] = {
                price_usd: income_statement_accumulated_value
              }
            end

            return @results[report_line.name][:price_usd]
          end

          previous_date = (start_date - 1.month)
          previous_saved = report_line.saved_report_lines.find_by(month: previous_date.month, year: previous_date.year)
          while !previous_saved.present?
            previous_date = (previous_date - 1.month)
            previous_saved = report_line.saved_report_lines.find_by(month: previous_date.month, year: previous_date.year)
          end
          if @results[report_line.name].present?
            @results[report_line.name][:price_usd] = previous_saved.price_usd
          else
            @results[report_line.name] = {
              price_usd: previous_saved.price_usd
            }
          end

          if !report_line.codes_references.present?
            if !@results[report_line.name][:price_idr].present?
              @results[report_line.name][:price_idr] = 0.to_money
            end
            if !@results[report_line.name][:price_usd].present?
              @results[report_line.name][:price_usd] = 0.to_money.with_currency(:usd)
            end
            # @results[report_line.name] = {
              # price_idr: 0.to_money,
              # price_usd: 0.to_money.with_currency(:usd)
            # }
            return @results[report_line.name][:price_usd]
          end

          if @results[report_line.name].present?
            @results[report_line.name][:price_usd] = (
              @results[report_line.name][:price_usd] +
              balance_usd(report_line.codes_references, report_line.formula)
            )
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
                  (date >= '#{start_date}' AND date <= '#{end_date}')
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
                  (date >= '#{start_date}' AND date <= '#{end_date}')
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
                  (date >= '#{start_date}' AND date <= '#{end_date}')
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
                  (date >= '#{start_date}' AND date <= '#{end_date}')
                GROUP BY credit_usd_currency
              EOS
            ).first&.credit_usd.to_money.with_currency(:usd)
          end

          def calculate_income_statement_facade
            return if income_statement_facade_status.to_s == 'calculated'

            @income_statement_facade = ::Admin::Reports::Shows::IncomeStatementFacade.new(@params)
            report = Report.income_statement.html.first
            report.report_lines.each do |report_line|
              next if report_line.title?
              if report_line.value?
                income_statement_facade.calculate_value_idr_for(report_line).amount.floor.to_money
                income_statement_facade.calculate_value_usd_for(report_line).amount.floor(2).to_money.with_currency(:usd)
              end
              if report_line.accumulation?
                income_statement_facade.calculate_accumulation_idr_for(report_line).amount.floor.to_money
                income_statement_facade.calculate_accumulation_usd_for(report_line).amount.floor(2).to_money.with_currency(:usd)
              end
              income_statement_facade.accumulated_facade.calculate_value_for(report_line)
            end
            @income_statement_facade_status = 'calculated'
          end
      end
    end
  end
end
