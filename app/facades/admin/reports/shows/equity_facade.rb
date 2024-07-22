module Admin
  module Reports
    module Shows
      class EquityFacade
        attr_accessor :report

        def initialize params
          @params = params
        end

        def calculate x,y
          return result[x][y] if result[x][y].present?
          if x == :saldo_awal && y == :modal_saham
            report_line = ReportLine.joins(:report)
              .where('reports.display': :html)
              .where(name: 'Modal Saham')
              .first
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            else
              bsf_result = balance_sheet_facade.results['Modal Saham']
              return result[x][y] = {
                price_idr: bsf_result[:price_idr],
                price_usd: bsf_result[:price_usd]
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :saldo_awal && y == :saldo_laba_rugi
            report_line = ReportLine.joins(:report)
              .where('reports.display': :html)
              .where(name: 'Laba (Rugi) Tahun Lalu')
              .first
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            else
              bsf_result = balance_sheet_facade.results['Laba (Rugi) Tahun Lalu']
              return result[x][y] = {
                price_idr: bsf_result[:price_idr],
                price_usd: bsf_result[:price_usd]
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :laba_rugi_tahun_berjalan && y == :saldo_laba_rugi
            report_line = ReportLine.joins(:report)
              .where('reports.display': :html)
              .where(name: 'Laba (Rugi) Tahun Berjalan')
              .first
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            else
              bsf_result = balance_sheet_facade.results['Laba (Rugi) Tahun Berjalan']
              return result[x][y] = {
                price_idr: bsf_result[:price_idr],
                price_usd: bsf_result[:price_usd]
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :other_comprehensive_income && y == :saldo_laba_rugi
            report_line = ReportLine.joins(:report)
              .where('reports.display': :html)
              .where(name: 'Other Comprehensive Income')
              .first
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            else
              bsf_result = balance_sheet_facade.results['Other Comprehensive Income']
              return result[x][y] = {
                price_idr: bsf_result[:price_idr],
                price_usd: bsf_result[:price_usd]
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end

          result[x][y] = {
            price_idr: 0.to_money,
            price_usd: 0.to_money.with_currency(:usd)
          }
        end

        def accumulation_x x
          return acc_x[x] if acc_x.dig(x).present?

          a = result[x].map{|k,v| v.map{|k2,v2| v2}}
          f = a.filter{|x|x.present?}
          idr = f.sum{|x|x[0]}
          usd = f.sum{|x|x[1]}
          acc_x[x] = {
            price_idr: idr,
            price_usd: usd
          }
        end
        def acc_x
          @acc_x ||= {}
        end
        def accumulation_y y
          return acc_y[y] if acc_y.dig(y).present?

          a = result.map{|k,v| v[y]}.filter{|x|x.present?}
          idr = a.sum{|x|x[:price_idr]}
          usd = a.sum{|x|x[:price_usd]}
          acc_y[y] = {
            price_idr: idr,
            price_usd: usd
          }
        end
        def acc_y
          @acc_y ||= {}
        end

        def accumulation_z
          @acc_z ||= {
            price_idr: acc_x.sum{|k,v|v[:price_idr]},
            price_usd: acc_x.sum{|k,v|v[:price_usd]}
          }
        end

        def result
          @result ||= {
            saldo_awal: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            },
            tambahan_modal_saham: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            },
            tambahan_setoran_modal_lainnya: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            },
            laba_rugi_tahun_berjalan: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            },
            other_comprehensive_income: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            },
            saldo_akhir: {
              modal_saham: {},
              setoran_modal_lainnya: {},
              saldo_laba_rugi: {},
              jumlah: {}
            }
          }
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

        private
          def balance_sheet_facade
            return @balance_sheet_facade if @balance_sheet_facade.present?
            @balance_sheet_facade = Admin::Reports::Shows::BalanceSheetFacade.new(@params)
            report = Report.html.balance_sheet.first
            report.report_lines.each.with_index(1) do |report_line,i|
              next if report_line.title?
              if report_line.value?
                @balance_sheet_facade.calculate_value_idr_for(report_line)
                @balance_sheet_facade.calculate_value_usd_for(report_line)
              elsif report_line.accumulation?
                @balance_sheet_facade.calculate_accumulation_idr_for(report_line)
                @balance_sheet_facade.calculate_accumulation_usd_for(report_line)
              end
            end

            @balance_sheet_facade
          end
      end
    end
  end
end
