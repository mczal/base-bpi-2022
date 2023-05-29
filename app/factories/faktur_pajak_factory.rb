class FakturPajakFactory
  def self.assign_from_hash_link faktur_pajak
    attributes = {}
    faktur_pajak.raw_result_from_link = faktur_pajak.hash_from_xml['resValidateFakturPm']

    faktur_pajak.hash_from_xml['resValidateFakturPm'].each do |k,v|
      if k == 'detailTransaksi'
        attributes['faktur_pajak_lines_attributes'] = []

        if v.is_a?(Hash)
          res = {}
          v.each do |k2,v2|
            res[k2.underscore] = v2
          end
          attributes['faktur_pajak_lines_attributes'] << res
        elsif v.is_a?(Array)
          v.each do |entry|
            res = {}
            entry.each do |k3,v3|
              res[k3.underscore] = v3
            end
            attributes['faktur_pajak_lines_attributes'] << res
          end
        end
      elsif k == 'tanggalFaktur'
        attributes[k.underscore] = Date.strptime(v, '%d/%m/%Y')
      else
        attributes[k.underscore] = v
      end
    end

    faktur_pajak.assign_attributes(attributes)
  end
end
