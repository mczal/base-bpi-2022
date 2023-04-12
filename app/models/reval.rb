class Reval < ApplicationRecord
  audited
  include PgSearch::Model

  has_many :reval_lines, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_many_attached :files

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
end
