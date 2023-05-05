class Reval < ApplicationRecord
  audited
  include PgSearch::Model
  include Audited::Logs
  include Approvable::AfterHooks
  include Revals::Approvals
  include Revals::ValidateSinglePeriods
  include Revals::AssignDefaultValues
  include Revals::Price
  include Revals::Periods
  include GeneralTransactions::Statuses
  extend GeneralTransactions::NumberEvidenceRetrievers

  has_many :reval_lines, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many_attached :files

  enum status: {
    draft: 'draft',
    waiting_for_approval: 'waiting_for_approval',
    accepted: 'accepted',
    rejected: 'rejected',
  }

  accepts_nested_attributes_for :reval_lines

  pg_search_scope :search,
    against: %i[date],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def journals
    @journals ||= Journal.where(
      journalable_type: 'RevalLine',
      journalable_id: reval_lines.ids
    )
  end

  def account_count
    @account_count ||= begin
      reval_lines.uniq{|x| x.account_id}.count
   end
  end
end
