# frozen_string_literal: true

class User < ApplicationRecord
  rolify
  include Clearance::User
  include Users::ApprovalAsNotifications

  has_one_attached :avatar
  belongs_to :company

  def roles_name
    @roles_name ||= roles.select(:name).pluck(:name)
  end

  def formatted_phone
    formatted_phone = phone_number.clone
    if phone_number.first == '0'
      formatted_phone[0] = '2'
      formatted_phone.insert 0, '6'
      formatted_phone.insert 0, '+'
      return formatted_phone
    end

    if phone_number.first(2) == '62'
      formatted_phone.insert 0, '+'
      return formatted_phone
    end

    formatted_phone
  end

  def readable_name
    @readable_name ||= "#{self.name} (#{self.email})"
  end
end
