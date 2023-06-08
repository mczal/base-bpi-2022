# frozen_string_literal: true

class InvoiceDirectInternal < ApplicationRecord
  include ::InvoiceDirectExternals::Statuses

  belongs_to :bank_account, class_name: "Account"
  has_many :invoice_direct_internal_lines, dependent: :destroy
  has_many :general_transactions, as: :transactionable, dependent: :destroy

  has_many_attached :other_files

  enum status: {
    draft: 'draft',
    ok: 'ok',
    approved: 'approved',
    rejected: 'rejected',
    paid: 'paid',
  }

  accepts_nested_attributes_for :invoice_direct_internal_lines
end
