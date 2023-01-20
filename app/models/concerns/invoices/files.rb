# frozen_string_literal: true

module Invoices
  module Files
    extend ActiveSupport::Concern
    def all_files
      return @all_files if @all_files.present?

      @all_files = other_files.to_a
      @all_files << invoice_file if invoice_file.attached?
      @all_files << kwitansi_file if kwitansi_file.attached?
      @all_files << faktur_pajak_file if faktur_pajak_file.attached?
      @all_files << berita_acara_file if berita_acara_file.attached?
      @all_files
    end

    def all_grouped_files
      return @all_grouped_files if @all_grouped_files.present?

      @all_grouped_files = []

      @all_grouped_files << { name: 'Dokumen Lainnya', files: other_files }
      @all_grouped_files << { name: 'Invoice', files: [invoice_file] } if invoice_file.attached?
      @all_grouped_files << { name: 'Kwitansi', files: [kwitansi_file] } if kwitansi_file.attached?
      @all_grouped_files << { name: 'Faktur Pajak', files: [faktur_pajak_file] } if faktur_pajak_file.attached?
      @all_grouped_files << { name: 'Berita Acara', files: [berita_acara_file] } if berita_acara_file.attached?
      @all_grouped_files
    end
  end
end
