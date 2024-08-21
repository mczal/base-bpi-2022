class GeneralTransaction < ApplicationRecord
  audited
  include PgSearch::Model
  include Audited::Logs
  include Approvable::AfterHooks
  include GeneralTransactions::Approvals
  include GeneralTransactions::AssignDefaultValues
  include GeneralTransactions::Price
  include GeneralTransactions::Statuses
  include GeneralTransactions::Revokes
  include PdfPrintable
  extend GeneralTransactions::NumberEvidenceRetrievers

  belongs_to :company
  belongs_to :transactionable, polymorphic: true, optional: true
  has_many :general_transaction_lines, dependent: :destroy
  has_many :approvals, as: :approvable, dependent: :destroy
  has_one_attached :printout
  has_many_attached :files

  validate :closed_book

  enum rates_source: {
    bank_of_indonesia: 'bank_of_indonesia',
    ministry_of_finance: 'ministry_of_finance',
    custom: 'custom'
  }
  enum rates_group: {
    fixed_rates: 'fixed_rates',
    end_of_period_rates: 'end_of_period_rates'
  }
  enum input_option: {
    idr: 'idr',
    usd: 'usd',
    no_automatic_rates_adjustment: 'no_automatic_rates_adjustment' # new per 240821: input custom usd ataupun idr tanpa di convert secara otomatis
  }
  enum status: {
    draft: 'draft',
    waiting_for_approval: 'waiting_for_approval',
    accepted: 'accepted',
    rejected: 'rejected',
  }
  enum location: {
    site: 'site',
    jakarta: 'jakarta',
  }
  enum source: {
    import: 'import',
    original: 'original',
    ba: 'ba',
    invoice_approved: 'invoice_approved',
    invoice_paid: 'invoice_paid',
    calculator: 'calculator',

    invoice_direct_external_paid: 'invoice_direct_external_paid',
    invoice_direct_internal_paid: 'invoice_direct_internal_paid'
  }

  accepts_nested_attributes_for :general_transaction_lines

  pg_search_scope :search,
    against: %i[number_evidence],
    using: {
      tsearch: { prefix: true, any_word: true, negation: true }
    }

  def closed_book
    closed_journals = ClosedJournal.where("date >= ?", self.date)
    if closed_journals.present?
      self.errors.add :base, "Jurnal sudah ditutup"
      return false
    end

    return true
  end

  def rate_instance
    @rate_instance ||= Rate.find_by(id: self.fixed_rates_options['id'])
  end
  def rate_money
    @rate_money ||= rate_instance&.middle.to_money
  end
  def journals
    @journals ||= Journal.where(
      journalable_type: 'GeneralTransactionLine',
      journalable_id: general_transaction_lines.ids
    )
  end

  def rates_source_name
    return @rates_source_name if @rates_source_name.present?

    if self.bank_of_indonesia?
      return @rates_source_name = 'BI JISDOR'
    end
    if self.ministry_of_finance?
      return @rates_source_name = 'KEMENKEU'
    end
    @rates_source_name = ''
  end



  def client
    if transactionable_type == 'Ba'
      return @client = transactionable.contract.client
    elsif transactionable_type == 'Invoice'
      return @client = transactionable.ba.contract.client
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @client = transactionable.client
    end
  end
  def po_kontrak
    if transactionable_type == 'Ba'
      return @po_kontrak = transactionable.contract.ref_number
    elsif transactionable_type == 'Invoice'
      return @po_kontrak = transactionable.ba.contract.ref_number
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @po_kontrak = ''
    end
  end
  def tanggal_po_kontrak
    if transactionable_type == 'Invoice'
      return @tanggal_po_kontrak = transactionable.ba.contract.started_at
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @tanggal_po_kontrak = ''
    end
  end
  def nomor_invoice
    if transactionable_type == 'Invoice'
      return @nomor_invoice = transactionable.ref_number
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @nomor_invoice = transactionable.ref_number
    end
  end
  def nilai_kontrak
    if transactionable_type == 'Invoice'
      return @nilai_kontrak = transactionable.ba.contract.price.to_money
    end
  end
  def nilai_invoice
    if transactionable_type == 'Invoice'
      return @nilai_invoice = transactionable.ba.price.to_money
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @nilai_invoice = transactionable.price.to_money
    end
  end
  def mata_uang
    if transactionable_type == 'Invoice'
      return @mata_uang = transactionable.ba.price_currency
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @nilai_invoice = transactionable.price_currency
    end
  end
  def deskripsi
    if transactionable_type == 'Invoice'
      return @perihal = transactionable.ba.description
    elsif transactionable_type == 'InvoiceDirectExternal'
      return @perihal = transactionable.description
    end
  end
end
