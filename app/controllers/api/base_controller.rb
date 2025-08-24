class Api::BaseController < ActionController::API
  before_action :authenticate_user!, except: [:get_current_user]
  before_action :configure_permitted_parameters, if: :devise_controller?

  respond_to :json

  def get_current_user
    if user_signed_in?
      render json: current_user.to_json_response, status: :ok
    else
      render json: {
        error: "User is not authenticated"
      }, status: :unauthorized
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[email password])
  end
end
