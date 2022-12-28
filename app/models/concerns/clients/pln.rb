# frozen_string_literal: true

module Clients
  module Pln extend ActiveSupport::Concern
    def pln
      self.find_by(name: 'PT PLN (PERSERO) KANTOR PUSAT')
    end
    def pt_bpi
      self.find_by(name: 'PT BPI')
    end
  end
end

