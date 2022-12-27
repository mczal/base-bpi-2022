# frozen_string_literal :true
module DateHelper
  def readable_month date
    return "-" unless date.present?
    I18n.l(date, format: '%^B %Y')
  end

  def readable_month_2 date
    return "-" unless date.present?
    I18n.l(date, format: '%B %Y')
  end

  def readable_month_3 date
    return "-" unless date.present?
    I18n.l(date, format: '%B')
  end

  def readable_date date
    return "-" unless date.present?
    I18n.l(date, format: '%A, %d %B %Y')
  end

  def readable_date_2 date
    return "-" unless date.present?
    I18n.l(date, format: '%d %B %Y')
  end

  def readable_date_3 date
    return "-" unless date.present?
    I18n.l(date, format: '%d/%m/%Y')
  end

  def readable_date_4 date
    return "-" unless date.present?
    I18n.l(date, format: '%d %b %Y')
  end

  def readable_timestamp date
    return "-" unless date.present?
    I18n.l(date, format: '%A, %d %B %Y %H:%M')
  end

  def readable_timestamp_2 date
    return "-" unless date.present?
    I18n.l(date, format: '%d %B %Y %H:%M')
  end

  def readable_timestamp_3 date
    return "-" unless date.present?
    I18n.l(date, format: '%d %B %Y %H:%M:%S')
  end

  def readable_timestamp_4 date
    return "-" unless date.present?
    I18n.l(date, format: '%d/%m/%Y - %H:%M')
  end

  def readable_timestamp_5 date
    return "-" unless date.present?
    I18n.l(date, format: '%d %b %Y %H:%M')
  end

  def readable_hour date
    return "-" unless date.present?
    I18n.l(date, format: '%H:%M:%S')
  end

  def readable_hour_2 date
    return "-" unless date.present?
    I18n.l(date, format: '%H:%M')
  end

  def html_input_date date
    return '' unless date.present?
    I18n.l(date, format: '%d/%m/%Y')
  end
end

