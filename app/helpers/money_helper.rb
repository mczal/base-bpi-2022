# frozen_string_literal: true

module MoneyHelper
  def number_to_currency_negative_format(amount)
    number_to_currency(
      amount.to_f,
      unit: 'Rp ',
      separator: ',',
      delimiter: '.',
      precision: 2,
      negative_format: '(%u%n)'
    )
  end

  def number_negative_with_brackets(amount)
    number_to_currency(
      amount.to_f,
      unit: '',
      separator: ',',
      delimiter: '.',
      precision: 2,
      negative_format: '(%u%n)'
    )
  end

  def print_money money, precision:3
    return '-' unless money.present? && money != 0

    # formatted_money = money.format
    # if !formatted_money.match(/,/)
      # number_to_currency(
        # money.amount,
        # precision: precision,
        # unit: money.symbol,
        # negative_format: '(%u%n)'
      # )
    # end

    number_to_currency(
      money.amount,
      precision: precision,
      unit: money.symbol,
      negative_format: '(%u%n)'
    )
  end
end
