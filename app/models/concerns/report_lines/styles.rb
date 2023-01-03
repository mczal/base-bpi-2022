module ReportLines
  module Styles extend ActiveSupport::Concern
    def style
      if title?
        return 'background-color:#F3F6F9;font-weight:bold;font-size:15px;'
      end
      if accumulation?
        return 'background-color:#f2dbdb;font-weight:bold;font-size:15px;text-align:right;'
      end

      'font-size:13px;'
    end
  end
end
