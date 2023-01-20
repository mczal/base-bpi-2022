# frozen_string_literal: true

module Invoices
  module SynchronizeToGeneralTransaction
    extend ActiveSupport::Concern
    include ::RatesHelper
    included do
      after_create :create_general_transaction
      after_update :update_general_transaction
      after_destroy :destroy_general_transaction
    end

    def create_general_transaction
      transaction = GeneralTransaction.new
      transaction.assign_attributes(
        date: date,
        description: description,
        type_transaction: external? ? 'journal' : 'expense',
        number_evidence: account.number_evidence_pretext,
        cash_account_id: external? ? '' : debt_account_id,
        client_id: client_id,
        company_id: company_id,
        invoice_id: id,
        source: 'invoice'
      )
      transaction.general_transaction_lines.new(line_attributes) if external?

      transaction.general_transaction_lines.new(line_attributes_debit_internal) if internal?
      transaction.general_transaction_lines.new(line_attributes_credit_internal) if internal?

      transaction.status = 'pending'
      transaction._rates = {
        middle: current_rates_of_bank_of_indonesia.middle.to_f,
        rate_id: current_rates_of_bank_of_indonesia.id
      }

      transaction.save!
    end

    def update_general_transaction
      transaction = GeneralTransaction.find_or_initialize_by(invoice_id: id)
      transaction.general_transaction_lines.destroy_all

      transaction.general_transaction_lines.new(line_attributes) if external?

      transaction.general_transaction_lines.new(line_attributes_debit_internal) if internal?
      transaction.general_transaction_lines.new(line_attributes_credit_internal) if internal?

      transaction.status = 'pending'
      transaction._rates = {
        middle: current_rates_of_bank_of_indonesia.middle.to_f,
        rate_id: current_rates_of_bank_of_indonesia.id
      }

      transaction.save!
    end

    def destroy_general_transaction
      transaction = GeneralTransaction.find_by(invoice_id: id)
      transaction.destroy if transaction.present?
    end

    def line_attributes
      {
        account_id: cash_account_id,
        description: description,
        price: nominal_dpp,
        tax_account_id: advance? ? tax_advance_account_id : '',
        tax_description: advance? ? "Uang Muka PPN" : '',
        tax_price: advance? ? ppn_price : 0.00,
        tax_type: advance? ? 'ppn' : '',
        tax_rate_id: tax_rate.id,
        type_transaction: 'debit'
      }
    end

    def line_attributes_debit_internal
      {
        account_id: cash_account_id,
        description: description,
        price: price,
      }
    end

    def line_attributes_credit_internal
      {
        account_id: debt_account_id,
        description: description,
        price: price,
      }
    end

    def nominal_dpp
      return price if exclude?

      (price / 1.1).to_f.round.to_money
    end

    def ppn_price
      return (nominal_dpp * 0.1).to_f.floor.to_money if exclude?

      (nominal_dpp * 0.1).to_f.round.to_money
    end

    def pph_price
      (nominal_dpp * (tax_rate.rate/100)).to_f.floor.to_money
    end

    def accounts_payable_price
      nominal_dpp + ppn_price - pph_price
    end

    def tax_cost_account_id
      Account.find_by(code: '42230').id
    end

    def tax_advance_account_id
      Account.find_by(code: '25140').id
    end

    def account
      Account.find_by(id: debt_account_id)
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
