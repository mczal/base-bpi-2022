module Clients
  module FormattedNpwp extend ActiveSupport::Concern
    def formatted_npwp
      return @formatted_npwp if @formatted_npwp.present?
      return npwp unless npwp.present?

      res = []
      res << "#{npwp[0] || '_'}#{npwp[1] || '_'}"
      res << "#{npwp[2] || '_'}#{npwp[3] || '_'}#{npwp[4] || '_'}"
      res << "#{npwp[5] || '_'}#{npwp[6] || '_'}#{npwp[7] || '_'}"
      res << "#{npwp[8] || '_'}-#{npwp[9] || '_'}#{npwp[10] || '_'}#{npwp[11] || '_'}"
      res << "#{npwp[12] || '_'}#{npwp[13] || '_'}#{npwp[14] || '_'}"
      @formatted_npwp = res.join('.')
    end
  end
end
