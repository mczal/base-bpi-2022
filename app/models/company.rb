class Company < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :general_transactions, dependent: :destroy
  has_many :general_transaction_lines, dependent: :destroy
  has_many :journals, dependent: :destroy
  has_many :reports, dependent: :destroy

  validates :name, :codename, presence: true
  validates :slug, presence: true, uniqueness: true
  before_save :set_slug

  def set_slug
    return if slug.present?
    self.slug = self.name.parameterize
  end

  def self.bpi
    Company.find_by slug: :bpi
  end
end
