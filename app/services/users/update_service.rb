module Users
  class UpdateService < ::BaseService
    def initialize params, company
      @params = params
      @company = company
    end

    def user
      @user ||= User.find_by(id: @params[:id])
    end

    private
      def action
        user.assign_attributes(attributes)
        user.save!

        assign_roles
      end

      def assign_roles
        return unless @params[:role].present?
        to_be_removed_roles = user.roles_name - @params[:role]
        to_be_added_roles = @params[:role] - user.roles_name

        to_be_removed_roles.each do |x|
          user.remove_role(x)
        end
        to_be_added_roles.each do |x|
          user.add_role(x)
        end
      end

      def attributes
        return @attributes if @attributes.present?

        @attributes = @params.require(:user)
          .permit(:email, :password)
          .merge({company: @company})
        return @attributes if @attributes[:password].present?

        @attributes = @attributes.except(:password)
      end
  end
end
