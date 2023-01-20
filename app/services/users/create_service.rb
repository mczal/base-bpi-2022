module Users
  class CreateService < ::BaseService
    def initialize params, company
      @params = params
      @company = company
    end

    def user
      @user ||= User.new(attributes)
    end

    private
      def action
        user.save!
        assign_roles
      end

      def assign_roles
        return unless @params[:role].present?
        @params[:role].each do |x|
          user.add_role(x)
        end
      end

      def attributes
        @attributes ||= @params.require(:user)
          .permit(:email, :password)
          .merge({company: @company})
      end
  end
end
