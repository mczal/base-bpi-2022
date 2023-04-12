# frozen_string_literal: true

class Contract < ApplicationRecord
  audited
  has_associated_audits
  include PgSearch::Model
  include Contracts::Statuses
  include Contracts::Invoices
  include Contracts::Clients
  include Contracts::SynchronizeToJournalsAfterSave
  include Contracts::MasterBusinessUnits
  include Contracts::SynchronizeToEndedAtAfterSave

  validates :started_at, presence: true
  validates :ref_number, uniqueness: true

  monetize :price_cents

  has_one_attached :contract_file
  has_one_attached :started_with_file
  has_many_attached :other_files
  has_many_attached :other_files
  # has_many_attached :files
  # has_many :invoices
  has_many :bas
  has_many :addendums

  belongs_to :client
  belongs_to :bank
  belongs_to :accrued_debit, class_name: "Account", optional: true
  # belongs_to :accrued_credit, class_name: "Account", optional: true
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


  pg_search_scope :search,
    against: %i[ref_number],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  enum status: {
    draft: 'draft',
    waiting: 'waiting',
    ongoing: 'ongoing',
    finished: 'finished',
    overdue: 'overdue'
  }
  enum started_with_group: {
    spmk: 'spmk',
    bamp: 'bamp'
  }
  enum payment_time_period_group: {
    work_time: 'work_time',
    calendar: 'calendar'
  }
  enum location: {
    site: 'site',
    jakarta: 'jakarta',
  }

  def name_for_select
    "#{ref_number} | #{client.name}"
  end

  def invoices
    @invoices ||= Invoice.where(invoiceable_id: bas.ids, invoiceable_type: 'Ba')
  end
end

