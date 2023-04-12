# Requirements :
# install zbar in MacOs with : brew install zbar
# install zbar in ubuntu with : sudo apt-get install libzbar-dev

module FakturPajaks
  class ScannerPdfService < ::BaseService
    def initialize params
      @params = params
      @file = ActiveStorage::Blob.find_signed(params[:signed])
    end

    def action
      pdf_to_image
      read_file_from_tmp

      if !@status
        error_messages << "Failed to scan file."
        return false
      end

      faktur_pajak.result = result
    end

    def faktur_pajak
      @faktur_pajak ||= FakturPajak.new
    end

    private
      def result
        @result ||= @stdout.split("QR-Code:").second.gsub("\n","")
      end

      def read_file_from_tmp
        @stdout, @stderr, @status = Open3.capture3("zbarimg #{image_path}")
      end

      def pdf_to_image
        @file.open(tmpdir: Rails.root.join('tmp')) do |f|
          image_list = Magick::ImageList.new(f.path)
          image = image_list.first
          image.format = "png"

          image.crop(20, 420, 100, 100).write(image_path)
          new_image =  Magick::Image.read(image_path).first
          new_image.resize(800, 800).write(image_path)
        end
      end

      def image_path
        @image_path ||= Rails.root.join('tmp', @file.filename.to_s.gsub(".pdf",".png").parameterize).to_s
      end

      # def file_path
        # @file_path ||= Rails.root.join('tmp', @file.original_filename.parameterize).to_s
      # end
  end
end


