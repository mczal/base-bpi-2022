# == Schema Information
#
# Table name: reports
#
#  id         :uuid             not null, primary key
#  name       :string
#  order      :integer
#  shown      :boolean
#  company_id :uuid             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  group      :string
#
class Report < ApplicationRecord
  belongs_to :company

  has_many :report_lines, dependent: :destroy
  has_many :report_references, dependent: :destroy

  enum group: {
    cash_flow: 'cash_flow',
    cash_flow_xlsx: 'cash_flow_xlsx',

    income_statement: 'income_statement',
    income_statement_xlsx: 'income_statement_xlsx',

    balance_sheet: 'balance_sheet',
    balance_sheet_xlsx: 'balance_sheet_xlsx',

    other: 'other',
  }

  enum display: {
    html: 'html',
    xlsx: 'xlsx',
  }

  def name_x
    return @name_x if @name_x.present?

    return @name_x = self.name if html?
    if self.name == 'LAPORAN POSISI KEUANGAN'
      return @name_x = 'Neraca'
    end
    if self.name == 'LAPORAN PENDAPATAN KOMPREHENSIF'
      return @name_x = 'Laba Rugi'
    end
    if self.name == 'LAPORAN ARUS KAS'
      return @name_x = 'Arus Kas'
    end
  end

  def short_eng_name
    return @short_eng_name if @short_eng_name.present?

    if self.name == 'Neraca'
      return @short_eng_name = 'BS'
    end
    if self.name == 'Laba Rugi'
      return @short_eng_name = 'IS'
    end
    if self.name == 'Arus Kas'
      return @short_eng_name = 'CF'
    end
  end

  def name_without_idr_or_usd
    @name_without_idr_or_usd ||= self.name.split('-').first.strip
  end

  def name_for_worksheet
    return @name_for_worksheet if @name_for_worksheet.present?

    if self.income_statement_xlsx?
      return @name_for_worksheet = 'IS PS'
    end
    if self.balance_sheet_xlsx?
      return @name_for_worksheet = 'NERACA PS'
    end
    if self.cash_flow_xlsx?
      return @name_for_worksheet = 'CF PS'
    end
  end

  def idr_version
    if self.balance_sheet_xlsx?
      return Report.balance_sheet_xlsx.find_by('name ILIKE ?', "%IDR%")
    end
    if self.income_statement_xlsx?
      return Report.income_statement_xlsx.find_by('name ILIKE ?', "%IDR%")
    end
  end

  def usd_version
    if self.balance_sheet_xlsx?
      return Report.balance_sheet_xlsx.find_by('name ILIKE ?', "%USD%")
    end
    if self.income_statement_xlsx?
      return Report.income_statement_xlsx.find_by('name ILIKE ?', "%USD%")
    end
  end
end
