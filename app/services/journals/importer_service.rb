# frozen_string_literal: true

module Journals
  class ImporterService < ::BaseService
    FIELD_MAP = {
      :number => 0,
      :date => 1,
      :number_evidence => 2,
      :penerima => 3,
      :description => 4,
      :account_code => 5,
      :debit_idr => 6,
      :credit_idr => 7,
      :rates_value => 8,
      :debit_usd => 9,
      :credit_usd => 10,
    }

    def initialize file
      @file = file
    end

    def action
      sheet_jakarta.each_with_index do |row,i|
        next if i == 0 || !is_row_valid?(row)
        find_or_initialize_by_and_save(row, :jakarta)
      end
      if @gt_params.present?
        params = ActionController::Parameters.new({general_transaction: @gt_params})
        service = ::GeneralTransactions::CreateService.new(params, company)
        service.run
        @gt_params = nil
      end

      #########################################################
      #########################################################

      sheet_site.each_with_index do |row,i|
        next if i == 0 || !is_row_valid?(row)
        find_or_initialize_by_and_save(row, :site)
      end
      if @gt_params.present?
        params = ActionController::Parameters.new({general_transaction: @gt_params})
        service = ::GeneralTransactions::CreateService.new(params, company)
        service.run
        @gt_params = nil
      end
    end

    private
      def find_or_initialize_by_and_save(row, location)
        number_evidence = get_number_evidence(row)
        if @gt_params.present? && @gt_params[:number_evidence] == number_evidence # for still same

          if get_debit_idr(row) != 0 || get_debit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :debit)
          end
          if get_credit_idr(row) != 0 || get_credit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :credit)
          end

        elsif !@gt_params.present? # for new
          @gt_params = gt_params(row, location)

          @gt_params[:general_transaction_lines_attributes] = []
          if get_debit_idr(row) != 0 || get_debit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :debit)
          end
          if get_credit_idr(row) != 0 || get_credit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :credit)
          end
          # @gt_params[:general_transaction_lines_attributes] = [line_params(row)]

        elsif @gt_params[:number_evidence] != number_evidence  # for changed
          params = ActionController::Parameters.new({general_transaction: @gt_params})
          service = ::GeneralTransactions::CreateService.new(params, company)
          service.run
          @gt_params = nil

          @gt_params = gt_params(row, location)

          @gt_params[:general_transaction_lines_attributes] = []
          if get_debit_idr(row) != 0 || get_debit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :debit)
          end
          if get_credit_idr(row) != 0 || get_credit_usd(row) != 0
            @gt_params[:general_transaction_lines_attributes] << line_params_with_specified_group(row, :credit)
          end
          # @gt_params[:general_transaction_lines_attributes] = [line_params(row)]
        end
      end

      def gt_params row, location
        {
          date: get_date(row),
          number_evidence: get_number_evidence(row),
          location: location,
          input_option: :idr,
          rates_source: nil,
          rates_group: :fixed_rates,
          source: :import,
          status: :accepted,
          fixed_rates_options: {
            id: nil
          },
        }
      end

      def line_params_with_specified_group row, group
        account = get_account(row)
        if group == :debit
          price_idr = get_debit_idr(row)
          price_usd = get_debit_usd(row)
        elsif group == :credit
          price_idr = get_credit_idr(row)
          price_usd = get_credit_usd(row)
        end
        {
          group: group,
          code: account.code,
          is_master_business_units_enabled: false,
          master_business_unit_id: nil,
          master_business_unit_location_id: nil,
          master_business_unit_area_id: nil,
          master_business_unit_activity_id: nil,
          description: get_description(row),
          price_idr: price_idr,
          price_usd: price_usd,
          rate: get_rates_value(row),
        }
      end

      def line_params row
        account = get_account(row)
        {
          group: get_group(row),
          code: account.code,
          is_master_business_units_enabled: false,
          master_business_unit_id: nil,
          master_business_unit_location_id: nil,
          master_business_unit_area_id: nil,
          master_business_unit_activity_id: nil,
          description: get_description(row),
          price_idr: get_price_idr(row),
          price_usd: get_price_usd(row),
          rate: get_rates_value(row),
        }
      end

      def get_account row
        Account.find_by(code: get_account_code(row))
      end

      def get_price_idr row
        group = get_group(row)
        if group == :debit
          return get_debit_idr(row)
        elsif group == :credit
          return get_credit_idr(row)
        end
      end
      def get_price_usd row
        group = get_group(row)
        if group == :debit
          return get_debit_usd(row)
        elsif group == :credit
          return get_credit_usd(row)
        end
      end
      def get_group row
        if get_debit_idr(row) != 0 || get_debit_usd(row) != 0
          return :debit
        elsif get_credit_idr(row) != 0 || get_credit_usd(row) != 0
          return :credit
        end
      end

      def get_date row
        Date.strptime(row[FIELD_MAP[:date]].to_s.strip,'%Y-%m-%d')
      end
      def get_rates_value row
        row[FIELD_MAP[:rates_value]].to_f
      end
      def get_credit_usd row
        row[FIELD_MAP[:credit_usd]].to_f
      end
      def get_debit_usd row
        row[FIELD_MAP[:debit_usd]].to_f
      end
      def get_credit_idr row
        row[FIELD_MAP[:credit_idr]].to_f
      end
      def get_debit_idr row
        row[FIELD_MAP[:debit_idr]].to_f
      end
      def get_description row
        row[FIELD_MAP[:description]].to_s.strip
      end
      def get_penerima row
        row[FIELD_MAP[:penerima]].to_s.strip
      end
      def get_account_code row
        row[FIELD_MAP[:account_code]].to_s.strip.split('.')[0]
      end
      def get_number_evidence row
        row[FIELD_MAP[:number_evidence]].to_s.strip
      end

      def sheet_jakarta
        @sheet_jakarta ||= xlsx.sheet('BUKU JURNAL')
      end
      def sheet_site
        @sheet_site ||= xlsx.sheet('BUKU JURNAL Site')
      end

      def xlsx
        @xlsx ||= Roo::Spreadsheet.open(@file)
      end

      def is_row_valid? row
        account_code_exist = get_account_code(row).present?
        account_exist = get_account(row)

        if account_code_exist && get_account_code(row).to_s.to_i != 0 && !account_exist
          puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> #{row}"
          binding.pry
        end

        account_code_exist && account_exist
      end

      def company
        @company ||= Company.find_by(slug: 'bpi')
      end
  end
end
