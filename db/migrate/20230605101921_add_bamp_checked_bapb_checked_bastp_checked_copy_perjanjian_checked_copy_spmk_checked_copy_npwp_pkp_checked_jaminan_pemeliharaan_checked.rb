class AddBampCheckedBapbCheckedBastpCheckedCopyPerjanjianCheckedCopySpmkCheckedCopyNpwpPkpCheckedJaminanPemeliharaanChecked < ActiveRecord::Migration[6.1]
  def change
    add_column :invoices, :bamp_checked, :boolean, default: false
    add_column :invoices, :bapb_checked, :boolean, default: false
    add_column :invoices, :bastp_checked, :boolean, default: false
    add_column :invoices, :copy_perjanjian_checked, :boolean, default: false
    add_column :invoices, :copy_spmk_checked, :boolean, default: false
    add_column :invoices, :copy_npwp_pkp_checked, :boolean, default: false
    add_column :invoices, :jaminan_pemeliharaan_checked, :boolean, default: false
  end
end
