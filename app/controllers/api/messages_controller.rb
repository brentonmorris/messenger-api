module Api
  class MessagesController < Api::BaseController
    def index
      @messages = current_user.messages

      render json: @messages
    end

    def create
      @message = current_user.messages.build(message_params)

      if @message.save
        render json: @message, status: :created, location: @message
      else
        render json: @message.errors, status: :unprocessable_entity
      end
    end

    private

    def message_params
      params.expect(message: [:content, :sender, :recipient])
    end
  end
end
