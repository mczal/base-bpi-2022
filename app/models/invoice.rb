# frozen_string_literal: true

class Invoice < ApplicationRecord
  include Invoices::Statuses
  # include Invoices::Approvals
  # include Approvable::AfterHooks
  include Approvals::Helpers

  # include Invoices::SynchronizeToJournalsAfterSaveForApproved
  include Invoices::SynchronizeToGeneralTransactionsAfterSaveForApproved
  # include Invoices::SynchronizeToJournalsAfterSaveForPaid

  include Invoices::SynchronizeToDebtAgeStartedAtBeforeSave
  include Invoices::SynchronizeToReceivedAtBeforeSave

  belongs_to :invoiceable, polymorphic: true
  belongs_to :pph, class_name: "Account", optional: true
  belongs_to :accrued_credit, class_name: "Account", optional: true
  belongs_to :bank_account, class_name: "Account", optional: true

  has_many :approvals, as: :approvable, dependent: :destroy

  has_one_attached :file
  has_one_attached :receipt_file
  has_one_attached :tax_receipt_file
  has_one_attached :spp_file
  has_many_attached :other_files

  monetize :price_cents
  monetize :fine_cents

  enum ppn_group: {
    include: 'include',
    exclude: 'exclude',
  }, _prefix: :ppn

  enum ppn_cost_group: {
    biaya: 'biaya',
    non_biaya: 'non_biaya',
  }, _prefix: :ppn_cost

  enum status: {
    draft: 'draft',
    ok: 'ok',
    verified: 'verified',
    approved: 'approved',
    rejected: 'rejected',
    paid: 'paid',
  }

  def ppn_biaya_account
    @ppn_biaya_account ||= Account.find_by(code: '25140')
  end

  def ba
    return nil unless invoiceable_type == 'Ba'
    self.invoiceable
  end
  def ba_id
    return nil unless invoiceable_type == 'Ba'
    self.invoiceable_id
  end

  def is_pph_rounded?
    pph_price_original.amount % 1 != 0
  end
  def pph_price_original
    return 0.to_money unless pph_percentage.present?
    @pph_price_original ||= dpp_price * (pph_percentage / 100.0)
  end
  def pph_price
    @pph_price ||= pph_price_original.amount.floor.to_money
  end

  def is_dpp_rounded?
    dpp_price_original.amount % 1 != 0
  end
  def dpp_price_original
    if ppn_exclude?
      return @dpp_price_original = (self.ba.price - fine)
    end
    @dpp_price_original = ((self.ba.price - fine) / (self.ppn + 1)).to_money
  end
  def dpp_price
    @dpp_price ||= dpp_price_original.amount.floor.to_money
  end

  def is_ppn_rounded?
    ppn_price_original.amount % 1 != 0
  end
  def ppn_price
    @ppn_price ||= ppn_price_original.amount.floor.to_money
  end
  def ppn_price_original
    @ppn_price_original ||= (dpp_price * self.ppn).to_money
  end

  def payable_price
    @payable_price ||= (dpp_price.to_money + ppn_price.to_money - pph_price.to_money).to_money
  end

  def ppn
    @ppn ||= self.ppn_percentage.to_f / 100.0
  end
end
