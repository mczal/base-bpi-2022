class CreateFakturPajaks < ActiveRecord::Migration[6.1]
  def up
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

      t.monetize :jumlah_dpp
      t.monetize :jumlah_ppn
      t.monetize :jumlah_ppn_bm

      t.string :npwp_lawan_transaksi
      t.string :nama_lawan_transaksi
      t.string :alamat_lawan_transaksi
      t.string :status_approval
      t.string :status_faktur
      t.string :referensi

      t.string :faktur_link
      t.json :raw_result_from_link, default: {}
    end


    change_column_default :faktur_pajaks, :jumlah_dpp_currency, 'IDR'
    change_column_default :faktur_pajaks, :jumlah_ppn_currency, 'IDR'
    change_column_default :faktur_pajaks, :jumlah_ppn_bm_currency, 'IDR'
  end

  def down
    drop_table :faktur_pajaks
  end
end
