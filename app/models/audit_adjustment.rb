class AuditAdjustment < ApplicationRecord
  audited
  include PgSearch::Model
  include Audited::Logs
  include Approvable::AfterHooks
  include AuditAdjustments::Approvals
  include AuditAdjustments::ValidateSinglePeriods
  include AuditAdjustments::AssignDefaultValues
  include AuditAdjustments::Price
  include GeneralTransactions::Statuses
  extend GeneralTransactions::NumberEvidenceRetrievers

  has_many :audit_adjustment_lines, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many_attached :files

  enum status: {
    draft: 'draft',
    waiting_for_approval: 'waiting_for_approval',
    accepted: 'accepted',
    rejected: 'rejected',
  }

  accepts_nested_attributes_for :audit_adjustment_lines

  pg_search_scope :search,
    against: %i[date],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def journals
    @journals ||= Journal.where(
      journalable_type: 'AuditAdjustmentLine',
      journalable_id: audit_adjustment_lines.ids
    )
  end

  def account_count
    @account_count ||= begin
      audit_adjustment_lines.uniq{|x|x.account_id}.count
   end
  end
end
