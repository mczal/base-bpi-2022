# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  include Clearance::User
  has_one_attached :avatar
  belongs_to :company
end
