class CreateFakturPajaks < ActiveRecord::Migration[6.1]
  def change
    create_table :faktur_pajaks, id: :uuid do |t|
      t.timestamps
      t.references :invoice, index: true, foreign_key: true, type: :uuid

      t.string :kd_jenis_transaksi
      t.string :fg_pengganti
      t.string :nomor_faktur
      t.date :tanggal_faktur
      t.string :npwp_penjual
      t.string :nama_penjual
      t.string :alamat_penjual

      t.string :npwp_lawan_transaksi
      t.string :nama_lawan_transaksi
      t.string :status_approval
      t.string :status_faktur
      t.string :referensi

      t.string :faktur_link
      t.json :raw_result_from_link, default: {}
    end
  end
end
