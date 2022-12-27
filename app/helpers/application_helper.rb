# frozen_string_literal: true

module ApplicationHelper
  def current_company
    if current_user.present?
      @current_company ||= current_user.company
    end
  end

  def months_for_select
    [
      ['Januari 01', 1],
      ['Februari 02', 2],
      ['Maret 03', 3],
      ['April 04', 4],
      ['Mei 05', 5],
      ['Juni 06', 6],
      ['Juli 07', 7],
      ['Agustus 08', 8],
      ['September 09', 9],
      ['Oktober 10', 10],
      ['November 11', 11],
      ['Desember 12', 12],
    ]
  end

  def years_for_select
    [2022, 2023, 2024, 2025, 2026]
  end
end
