module FakturPajaks
  module Html extend ActiveSupport::Concern
    def pretty_hash
      result = "<table id='FakturPajakTable'><tbody>"
      res_data = hash_from_xml['resValidateFakturPm'].map do |k,v|
        if v.is_a?(String)
          <<-EOS
          <tr>
            <td>
              #{k}
            </td>
            <td>
              #{%w(jumlahDpp jumlahPpn jumlahPpnBm).include?(k) ? "#{v.to_money.with_currency(:idr).format}" : v}
            </td>
          </tr>
          EOS
        elsif v.is_a?(Hash)
          t_tmp = []
          t_tmp << <<-EOS
          <tr>
            <td colspan="2">
              #{k}
            </td>
          </tr>
          EOS
          v.each do |k2,v2|
            t_tmp << <<-EOS
            <tr>
              <td>
                <div class="pl-5">
                  #{k2}
                </div>
              </td>
              <td>
                #{%w(hargaSatuan hargaTotal dpp ppn).include?(k2) ? "#{v2.to_money.with_currency(:idr).format}" : v2}
              </td>
            </tr>
            EOS
          end

          t_tmp.join('')
        elsif v.is_a?(Array)
          t_tmp = []
          t_tmp << <<-EOS
          <tr>
            <td colspan="2">
              #{k}
            </td>
          </tr>
          EOS
          zzz = 1
          v.each do |entry|
            xxx = 1
            entry.each do |k2,v2|
              t_tmp << <<-EOS
              <tr>
                <td>
                  <div class="pl-5 #{'font-weight-bolder' if xxx == 1}">
                    #{(zzz.to_s + '.') if xxx == 1} #{k2}
                  </div>
                </td>
                <td>
                  #{%w(hargaSatuan hargaTotal dpp ppn).include?(k2) ? "#{v2.to_money.with_currency(:idr).format}" : v2}
                </td>
              </tr>
              EOS
              xxx += 1
            end
            zzz += 1
          end
          t_tmp.join('')
        end
      end.join('')

      <<-EOS
      #{result}
      #{res_data}
      </tbody></table>
      EOS
    end

    def hash_from_xml
      return @hash_from_xml if @hash_from_xml.present?

      uri = URI(self.faktur_link)
      result = Net::HTTP.get_response(uri)
      @hash_from_xml = Hash.from_xml(result.body)
    end
  end
end
