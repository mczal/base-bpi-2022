# Requirements :
# install zbar in MacOs with : brew install zbar
# install zbar in ubuntu with : sudo apt-get install libzbar-dev

module FakturPajaks
  class ScannerPngService < ::BaseService
    def initialize params
      @params = params
      @file = ActiveStorage::Blob.find_signed(params[:signed])
    end

    def action
      read_file_from_tmp

      if !@status
        error_messages << "Failed to scan file."
        return false
      end

      faktur_pajak.faktur_link = result
    end

    def faktur_pajak
      @faktur_pajak ||= FakturPajak.new
    end

    private
      def result
        @result ||= @stdout.split("QR-Code:").second.gsub("\n","")
      end

      def read_file_from_tmp
        @file.open(tmpdir: Rails.root.join('tmp')) do |f|
          @stdout, @stderr, @status = Open3.capture3("zbarimg #{f.path}")
        end
      end

      def file_path
        @file_path ||= Rails.root.join('tmp', @file.original_filename.parameterize).to_s
      end
  end
end

