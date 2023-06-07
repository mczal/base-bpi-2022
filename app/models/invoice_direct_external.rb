# frozen_string_literal: true

class InvoiceDirectExternal < ApplicationRecord
  include ::InvoiceDirectExternals::Statuses
  include Contracts::Clients
  include ::InvoiceDirectExternals::SynchronizeToGeneralTransactionsAfterSaveForPaid

  belongs_to :client
  belongs_to :bank
  belongs_to :bank_account, class_name: "Account", optional: true
  belongs_to :cost_center, class_name: "Account"
  belongs_to :master_business_unit, optional: true
  belongs_to :master_business_unit_location,
    foreign_key: 'master_business_unit_location_id',
    class_name: 'MasterBusinessUnit',
    optional: true
  belongs_to :master_business_unit_area,
    foreign_key: 'master_business_unit_area_id',
    class_name: 'MasterBusinessUnit',
    optional: true
  belongs_to :master_business_unit_activity,
    foreign_key: 'master_business_unit_activity_id',
    class_name: 'MasterBusinessUnit',
    optional: true

  has_many :approvals, as: :approvable, dependent: :destroy
  has_many :general_transactions, as: :transactionable, dependent: :destroy
  has_one :faktur_pajak, as: :faktur_pajakable, dependent: :destroy

  has_many_attached :other_files

  monetize :price_cents

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
    approved: 'approved',
    rejected: 'rejected',
    paid: 'paid',
  }

  accepts_nested_attributes_for :faktur_pajak

  def ppn_biaya_account
    @ppn_biaya_account ||= Account.find_by(code: '25140')
  end

  def is_dpp_rounded?
   dpp_price_original.amount % 1 != 0
  end
  def dpp_price_original
    if !faktur_pajak_checked? || ppn_exclude?
      return @dpp_price_original = self.price
    end
    @dpp_price_original = ((self.price) / (self.ppn + 1)).to_money
  end
  def dpp_price
    @dpp_price ||= dpp_price_original.amount.floor.to_money
  end

  def is_ppn_rounded?
    ppn_price_original.amount % 1 != 0
  end
  def ppn_price
    @ppn_price ||= begin
      if faktur_pajak_checked?
        ppn_price_original.amount.floor.to_money
      else
        0.to_money
      end
    end
  end
  def ppn_price_original
    @ppn_price_original ||= begin
      if faktur_pajak_checked?
        (dpp_price * self.ppn).to_money
      else
        0.to_money
      end
    end
  end

  def payable_price
    @payable_price ||= (
      dpp_price.to_money\
      + ppn_price.to_money
    ).to_money
  end

  def ppn
    @ppn ||= begin
      if faktur_pajak_checked?
        (self.ppn_percentage.to_f / 100.0).to_d
      else
        0.to_d
      end
    end
  end
end
