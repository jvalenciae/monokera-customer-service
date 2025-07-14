module ErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from StandardError, with: :handle_internal_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
  end

  private

  def handle_not_found(exception)
    render_error("Resource not found", exception.message, status: :not_found)
  end

  def handle_validation_error(exception)
    render_error("Validation failed", exception.message, status: :unprocessable_entity)
  end

  def handle_internal_error(exception)
    render_error("Internal server error", "Something went wrong. Please try again later.", status: :internal_server_error)
  end
end
