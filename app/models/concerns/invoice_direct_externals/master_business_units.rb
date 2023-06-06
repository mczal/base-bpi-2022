# frozen_string_literal: true

module InvoiceDirectExternals
  module MasterBusinessUnits extend ActiveSupport::Concern
    def master_business_units_string
      return @master_business_units_string if @master_business_units_string.present?
      return @master_business_units_string = '' unless self.is_master_business_units_enabled?

      code = master_business_unit.code
      location = master_business_unit_location.code
      area = master_business_unit_area.code
      activity = master_business_unit_activity.code
      @master_business_units_string = "#{code}#{location}#{area}#{activity}#{self.accrued_debit.code}"
    end

    def master_business_units_for_popover
      return @master_business_units_for_popover if @master_business_units_for_popover.present?
      return @master_business_units_for_popover = '' unless self.is_master_business_units_enabled?

      mbu = master_business_unit
      location = master_business_unit_location
      area = master_business_unit_area
      activity = master_business_unit_activity

      @master_business_units_for_popover = [
        "<div><b>Master Business Unit</b></div><div>Kode: #{mbu.code}</div><div>Deskripsi: #{mbu.description}</div>",
        "<div><b>Master Business Location</b></div><div>Kode: #{location.code}</div><div>Deskripsi: #{location.description}</div>",
        "<div><b>Master Business Area</b></div><div>Kode: #{area.code}</div><div>Deskripsi: #{area.description}</div>",
        "<div><b>Master Business Activity</b></div><div>Kode: #{activity.code}</div><div>Deskripsi: #{activity.description}</div>",
      ].join("<br/>").html_safe
    end
  end
end
