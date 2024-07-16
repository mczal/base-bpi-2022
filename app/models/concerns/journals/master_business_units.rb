module Journals
  module MasterBusinessUnits extend ActiveSupport::Concern
    def master_business_units_for_popover
      return @master_business_units_for_popover if @master_business_units_for_popover.present?
      return @master_business_units_for_popover = '' unless self.master_business_unit.present?

      mbu = master_business_unit_code
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

    def master_business_unit_code
      return unless self.master_business_unit.present?
      return @master_business_unit_code if @master_business_unit_code.present?

      value = self.master_business_unit[0]
      @master_business_unit_code = MasterBusinessUnit.business_unit.find_by(code: value)
    end

    def master_business_unit_location
      return unless self.master_business_unit.present?
      return @master_business_unit_location if @master_business_unit_location.present?

      value = self.master_business_unit[1..2]
      @master_business_unit_location = MasterBusinessUnit.business_unit_location.find_by(code: value)
    end

    def master_business_unit_area
      return unless self.master_business_unit.present?
      return @master_business_unit_area if @master_business_unit_area.present?

      value = self.master_business_unit[3..7]
      @master_business_unit_area = MasterBusinessUnit.business_unit_area.find_by(code: value)
    end

    def master_business_unit_activity
      return unless self.master_business_unit.present?
      return @master_business_unit_activity if @master_business_unit_activity.present?

      value = self.master_business_unit[8..11]
      @master_business_unit_activity = MasterBusinessUnit.business_unit_activity.find_by(code: value)
    end
  end
end
