module Admin
  class ActiveStoragesController < ::AdminController
    def upload_document
      resource.send(params[:registered_name]).attach(params[:file])
      resource.save!
      redirect_back fallback_location: admin_root_path
    end

    def remove_document
      ActiveStorage::Attachment.find_by(id: params[:attachment_id]).purge
      redirect_back fallback_location: admin_root_path
    end

    private
      def resource
        @resource ||= eval(params[:resource_type]).find_by(id: params[:resource_id])
      end
  end
end

