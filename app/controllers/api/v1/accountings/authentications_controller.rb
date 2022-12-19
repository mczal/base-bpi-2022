# frozen_string_literal: true

module Api
  module V1
    module Accountings
      class AuthenticationsController < Api::ApplicationController
        include Api::Authorizable
        skip_before_action :verify_authenticity_token
        before_action :verify_authorization_token, only: :get_account
        before_action :validate_token, only: [:create_user, :signed_in_user]

        def get_account
          @user = User.find_by_email(@email)
          if @user.present?
            return render json: {
              url: login_sia_url(token: generated_token)
            }, status: :ok
          end

          render json: {
            url: register_sia_url(token: generated_token)
          }, status: :ok
        end

        def create_user
          @user = User.find_by_email(@email)
          if @user.blank?
            new_user_service = Authentication::CreateService.new(@email, params)
            unless new_user_service.run
              return redirect_to register_sia_path(token: params[:token]), alert: new_user_service.full_error_messages_html
            end
          end

          @user ||= new_user_service.user
          sign_in(@user)
          redirect_to root_path, notice: "Akun berhasil dibuat."
        end

        def signed_in_user
          user = User.find_by_email(@email)
          if user.present?
            sign_in(user)
            return redirect_to root_path, notice: "Login berhasil"
          end

          return redirect_to root_path, notice: "Login gagal"
        end

      end
    end
  end
end
