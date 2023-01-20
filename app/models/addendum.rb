# frozen_string_literal: true

class Addendum < ApplicationRecord
  audited
  include PgSearch::Model

  before_destroy :revert_changes_to_contract

  has_many_attached :files
  belongs_to :contract

  def pretty_contract_changes_html
    @pretty_contract_changes_html ||= self.contract_changes.map do |k,v|
      if k.match(/price/)
        <<-EOS.strip
          <b>#{I18n.t(k).titlecase}</b><br/>
          <span class="text-danger">#{Money.new(v[0]).format}</span>
          -->
          <span class="text-success font-weight-bold">#{Money.new(v[1]).format}</span>
        EOS
      else
        <<-EOS.strip
          <b>#{I18n.t(k).titlecase}</b><br/>
          <span class="text-danger">#{v[0]}</span>
          -->
          <span class="text-success font-weight-bold">#{v[1]}</span>
        EOS
      end
    end.join("<br/><br/>")
  end

  def revert_changes_to_contract
    if self.contract.addendums.where.not(id: self.id).where('created_at > ?', self.created_at).present?
      throw(:abort)
    end

    self.contract_changes.each do |k,v|
      old_value = v[0]
      if %w(started_at ended_at started_with_date).include?(k)
        eval("self.contract.#{k} = \"#{old_value}\".to_date")
      else
        eval("self.contract.#{k} = \"#{old_value}\"")
      end
    end
    self.contract.save!
  end
end

