class FakturPajakLine < ApplicationRecord
  belongs_to :faktur_pajak

  monetize :harga_satuan_cents, with_currency: :idr
  monetize :diskon_cents, with_currency: :idr
  monetize :dpp_cents, with_currency: :idr
  monetize :ppn_cents, with_currency: :idr
  monetize :ppnbm_cents, with_currency: :idr
  monetize :harga_total_cents, with_currency: :idr
end
