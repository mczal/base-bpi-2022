class CreateSavedReportLines < ActiveRecord::Migration[6.1]
  def change
    create_table :saved_report_lines, id: :uuid do |t|
      t.timestamps
      t.integer :month
      t.integer :year
      t.date :date
      t.references :report_line, foreign_key: true, index: true, type: :uuid
      t.monetize :price_idr
      t.monetize :price_usd
    end

    change_column_default :saved_report_lines, :price_usd_currency, 'USD'
  end
end
