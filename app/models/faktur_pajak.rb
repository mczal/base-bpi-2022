class FakturPajak < ApplicationRecord
  include FakturPajaks::Html
  include FakturPajaks::AssignDefaultValues

  belongs_to :invoice

  has_one_attached :file_png
  has_one_attached :file_pdf

  has_many :faktur_pajak_lines, dependent: :destroy

  accepts_nested_attributes_for :faktur_pajak_lines

  monetize :jumlah_dpp_cents, with_currency: :idr
  monetize :jumlah_ppn_cents, with_currency: :idr
  monetize :jumlah_ppn_bm_cents, with_currency: :idr

  def file
    @file ||= begin
      if file_pdf.attached?
        file_pdf
      else
        file_png
      end
    end
  end
end
