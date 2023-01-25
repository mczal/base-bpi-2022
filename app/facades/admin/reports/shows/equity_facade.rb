module Admin
  module Reports
    module Shows
      class EquityFacade
        def initialize params
          @params = params
        end

        def calculate x,y
          return result[x][y] if result[x][y].present?
          if x == :saldo_awal && y == :modal_saham
            report_line = ReportLine.find_by(name: 'Modal Saham')
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :saldo_awal && y == :saldo_laba_rugi
            report_line = ReportLine.find_by(name: 'Laba (Rugi) Tahun Lalu')
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :laba_rugi_tahun_berjalan && y == :saldo_laba_rugi
            report_line = ReportLine.find_by(name: 'Laba (Rugi) Tahun Berjalan')
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
              }
            end
            return result[x][y] = {
              price_idr: 0.to_money,
              price_usd: 0.to_money.with_currency(:usd)
            }
          end
          if x == :other_comprehensive_income && y == :saldo_laba_rugi
            report_line = ReportLine.find_by(name: 'Other Comprehensive Income')
            saved = report_line.saved_report_lines.find_by(
              month: end_date.month,
              year: end_date.year
            )
            if saved.present?
              return result[x][y] = {
                price_idr: saved.price_idr,
                price_usd: saved.price_usd
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
      end
    end
  end
end

