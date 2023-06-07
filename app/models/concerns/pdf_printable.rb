# frozen_string_literal: true

module PdfPrintable extend ActiveSupport::Concern
  include DateHelper

  def refresh_printout! pdf_string
    save_path = Rails.root.join('tmp', "#{self.number_evidence.parameterize}.pdf")
    File.open(save_path, 'wb') do |file|
      file << pdf_string
    end

    pdf_file = open(save_path)
    self.printout.attach(
      io: pdf_file,
      filename: "[#{self.class.to_s}] #{self.number_evidence.parameterize}.pdf"
    )
    self.save!
  end

  # def pdf_revision
    # return @pdf_revision if @pdf_revision.present?

    # all_audits = own_and_associated_audits.map do |audit|
      # {
        # type: audit.auditable_type,
        # version: audit.version,
        # date: readable_timestamp_3(audit.created_at)
      # }
    # end

    # all_versions = all_audits.group_by do |entry|
      # entry[:date]
    # end

    # @pdf_revision = all_versions.keys.count - 1
  # end
end


