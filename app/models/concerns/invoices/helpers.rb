# frozen_string_literal: true

module Invoices
  module Helpers
    extend ActiveSupport::Concern

    def tax_rate
      return @tax_rate if @tax_rate.present?
      @tax_rate = TaxRate.find_by(id:tax_rate_id)
    end

    def tax_type
      tax_rate&.tax_type
    end

    def number_ref_pretext
      count_invoice = Invoice.external.select(:id).count
      running_number = (count_invoice + 1).to_s.rjust(4, '0')
      "BPI/EKS-#{running_number}"
    end

    def number_ref_pretext_internal
      count_invoice = Invoice.internal.select(:id).count
      running_number = (count_invoice + 1).to_s.rjust(4, '0')
      "BPI/INT-#{running_number}"
    end

    def description_html
      <<-EOS
        <div class='mb-2'>
          <div><b>== Invoice ==</b></div>
          <div><b>Diubah:</b> #{readable_date_4 updated_at}</div>
        </div>
        <b>== Contract ==</b><br/>
        <div>
        #{contract_description_html}
        </div>
      EOS
    end

    def due_date_html
      result = <<-EOS
        #{readable_date_4 due_date}
      EOS
      return result if paid?

      if Date.current > due_date
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#E91E63;font-size:10px;">Lewat #{(due_date - Date.current).to_i} Hari</span>
        EOS
      end

      if Date.current < due_date
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#3F51B5;font-size:10px;">Sisa #{(due_date - Date.current).to_i} Hari</span>
        EOS
      end

      if Date.current == due_date
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#FF9800;font-size:10px;">Hari ini</span>
        EOS
      end

      result
    end

    def description_invoice_html
      <<-EOS
        <div><b>Client:</b>
          <div class='ml-2'>
            #{client_description}
          </div>
        </div>
      EOS
    end

    def description_invoice_internal_html
      <<-EOS
        <div><b>Business Unit:</b>
          <div class='ml-2'>
            <div>#{master_business_unit&.description}</div>
          </div>
        </div>
      EOS
    end

    def due_date_invoice_html
      due_date_invoice = date.to_date + period_of_time
      result = <<-EOS
        #{readable_date_4(due_date_invoice)}
      EOS
      return result if paid?

      if Date.current > due_date_invoice
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#E91E63;font-size:10px;">Lewat #{(due_date_invoice - Date.current).to_i} Hari</span>
        EOS
      end

      if Date.current < due_date_invoice
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#3F51B5;font-size:10px;">Sisa #{(due_date_invoice - Date.current).to_i} Hari</span>
        EOS
      end

      if Date.current == due_date_invoice
        result = <<-EOS
          <div>#{result}</div>
          <span style="color:#FF9800;font-size:10px;">Hari ini</span>
        EOS
      end

      result
    end
  end
end
