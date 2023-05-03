# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                 :uuid             not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  email              :string           not null
#  encrypted_password :string(128)      not null
#  confirmation_token :string(128)
#  remember_token     :string(128)      not null
#  company_id         :uuid
#  name               :string
#  phone_number       :string
#
class User < ApplicationRecord
  rolify
  include Clearance::User

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
