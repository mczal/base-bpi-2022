# frozen_string_literal: true

module Invoices
  module SynchronizeToTax
    extend ActiveSupport::Concern
    include ::RatesHelper
    included do
      after_create :sync_to_tax
      after_update :sync_to_tax
      after_destroy :destroy_taxes
    end

    def sync_to_tax
      return unless advance? || tax_rate.present?

      taxes = Tax.where(taxable_id: id)
      taxes.destroy_all

      tax_ppn = Tax.create!(
        taxable_id: id,
        category: tax_type.name.parameterize.underscore,
        taxable_type: 'Invoice',
        status: 'unpaid',
        description: "Uang Muka PPN",
        price: ppn_price,
        date: date,
        _rates: tax_rate
      ) if advance?

      tax_pph = Tax.create!(
        taxable_id: id,
        category: tax_type.name.parameterize.underscore,
        taxable_type: 'Invoice',
        status: 'unpaid',
        description: tax_rate.titlecased_name,
        price: pph_price,
        date: date,
        _rates: tax_rates
      ) if tax_rate.present?
    end

    def destroy_taxes
      Tax.where(taxable_id: id).destroy_all
    end

    def tax_rates
      {
        middle: current_rates_of_ministry_of_finance.middle.to_f,
        rate_id: current_rates_of_ministry_of_finance.id
      }
    end

    def nominal_dpp
      return price if exclude?

      (price / 1.1).to_f.round.to_money
    end

    def ppn_price
      return (nominal_dpp * 0.1).to_f.floor.to_money  if exclude?

      (nominal_dpp * 0.1).to_f.round.to_money
    end

    def pph_price
      (nominal_dpp * (tax_rate.rate/100)).to_f.floor.to_money
    end

    def tax_cost_account_id
      Account.find_by(code: '42230').id
    end

    def tax_advance_account_id
      Account.find_by(code: '25140').id
    end

    def tax_debt_account(tax_type_name)
      return Account.find_by(code: '42100').id if tax_type_name == 'pph 21'
      return Account.find_by(code: '42110').id if tax_type_name == 'pph 22'
      return Account.find_by(code: '42120').id if tax_type_name == 'pph 23'
      return Account.find_by(code: '42130').id if tax_type_name == 'pph 25'
      return Account.find_by(code: '42140').id if tax_type_name == 'pph 26'
      return Account.find_by(code: '42150').id if tax_type_name == 'pph 29'
      return Account.find_by(code: '42160').id if tax_type_name == 'pasal 4 ayat 2'
    end
  end
end
