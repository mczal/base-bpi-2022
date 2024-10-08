class CreateFakturPajakLines < ActiveRecord::Migration[6.1]
  def up
    create_table :faktur_pajak_lines, id: :uuid do |t|
      t.timestamps
      t.references :faktur_pajak, index: true, foreign_key: true, type: :uuid
      t.string :nama
      t.integer :jumlah_barang
      t.monetize :harga_satuan
      t.monetize :diskon
      t.monetize :dpp
      t.monetize :ppn
      t.monetize :ppnbm
      t.monetize :harga_total
      t.decimal :tarif_ppnbm
    end


    change_column_default :faktur_pajak_lines, :harga_satuan_currency, 'IDR'
    change_column_default :faktur_pajak_lines, :diskon_currency, 'IDR'
    change_column_default :faktur_pajak_lines, :dpp_currency, 'IDR'
    change_column_default :faktur_pajak_lines, :ppn_currency, 'IDR'
    change_column_default :faktur_pajak_lines, :ppnbm_currency, 'IDR'
    change_column_default :faktur_pajak_lines, :harga_total_currency, 'IDR'
  end

  def down
    drop_table :faktur_pajak_lines
  end
end
