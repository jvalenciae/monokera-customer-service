module ResponseFormatter
  extend ActiveSupport::Concern

  private

  def render_success(data, status: :ok)
    render json: {
      data: data
    }, status: status and return
  end

  def render_error(error, message, status: :bad_request)
    render json: {
      error: error,
      message: message
    }, status: status and return
  end
end
