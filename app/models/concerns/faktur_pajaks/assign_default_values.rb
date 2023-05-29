module FakturPajaks
  module AssignDefaultValues extend ActiveSupport::Concern
    included do
      before_create :assign_default_values
    end

    def assign_default_values
      ::FakturPajakFactory.assign_from_hash_link(self)
    end
  end
end
