module ReportLines
  module Prices extend ActiveSupport::Concern
    def price_idr
      if %w(title break accumulation).include?(self.group)
        return ''
      end
      5000000.to_money
    end

    def price_usd
      if %w(title break accumulation).include?(self.group)
        return ''
      end
      5000000.to_money
    end
  end
end
