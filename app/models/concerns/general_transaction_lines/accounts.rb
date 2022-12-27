# frozen_string_literal: true

module GeneralTransactionLines
  module Accounts extend ActiveSupport::Concern
    def account
      @account ||= Account.find_by(code: self.code)
    end
  end
end
