module Api
  module Users
    class SessionsController < Devise::SessionsController
      include RackSessionsFix
      respond_to :json

      private

      def respond_with(current_user, _opts = {})
        render json: {
          user: current_user.to_json_response,
          message: "Logged in successfully."
        }, status: :ok
      end

      def respond_to_on_destroy
        if current_user
          render json: {
            message: "Logged out successfully."
          }, status: :ok
        else
          render json: {
            error: "Couldn't find an active session."
          }, status: :unauthorized
        end
      end
    end
  end
end
