# frozen_string_literal: true

module AccountBeginningBalances
  class ImporterV2Service < ::BaseService
    FIELD_MAP = {
      :account_code => 3,
      :account_name => 4,
      :balance_idr => 5,
      :balance_usd => 6,
    }

    def initialize file
      @file = file
    end

    def action
      sheet.each_with_index do |row,i|
        next if i == 0 || !is_row_valid?(row)
        find_or_initialize_by(row)
      end

      params = ActionController::Parameters.new({general_transaction: gt_params})
      service = ::GeneralTransactions::CreateService.new(params, company)
      service.run
    end

    private
      def find_or_initialize_by(row)
        account = get_account(row)
        balance_idr = price_idr(row).to_f
        balance_usd = price_usd(row).to_f
        if balance_idr > 0 && balance_usd > 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :debit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_idr: balance_idr,
            price_usd: balance_usd
          }
          return
        end
        if balance_idr < 0 && balance_usd < 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :credit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_idr: (balance_idr * -1),
            price_usd: (balance_usd * -1)
          }
          return
        end

        if balance_idr > 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :debit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_idr: balance_idr
          }
        end
        if balance_idr < 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :credit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_idr: (balance_idr * -1)
          }
        end
        if balance_usd > 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :debit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_usd: balance_usd
          }
        end
        if balance_usd < 0
          gt_params[:general_transaction_lines_attributes] << {
            group: :credit,
            code: account.code,
            is_master_business_units_enabled: false,
            master_business_unit_id: nil,
            master_business_unit_location_id: nil,
            master_business_unit_area_id: nil,
            master_business_unit_activity_id: nil,
            description: 'Saldo Akhir 2023 (Audited)',
            price_usd: (balance_usd * -1)
          }
        end
      end

      def gt_params
        @gt_params ||= {
          date: Date.strptime('31-12-2023','%d-%m-%Y'),
          number_evidence: '[Saldo Akhir Des 2023 Audited]',
          location: :jakarta,
          input_option: :idr,
          rates_source: nil,
          rates_group: :fixed_rates,
          source: :import,
          status: :accepted,
          fixed_rates_options: {
            id: nil
          },
          general_transaction_lines_attributes: []
        }
      end

      def get_account row
        Account.find_by(code: account_code(row))
      end
      def price_idr row
        row[FIELD_MAP[:balance_idr]].to_f.to_money
      end
      def price_usd row
        row[FIELD_MAP[:balance_usd]].to_f.to_money.with_currency(:usd)
      end
      def account_code row
        row[FIELD_MAP[:account_code]].to_s.strip.split('.')[0]
      end

      def sheet
        @sheet ||= xlsx.sheet('Saldo Awal 2024 - TB')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        get_account(row).present?
      end

      def company
        @company ||= Company.find_by(slug: 'bpi')
      end
  end
end
