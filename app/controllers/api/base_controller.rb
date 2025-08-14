module Api
  class BaseController < ApplicationController
    # エラーハンドリング
    rescue_from StandardError, with: :handle_standard_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from ValidationError, with: :handle_validation_error
    rescue_from ShortenedUrlCreationError, with: :handle_creation_error

    private

    def handle_standard_error(exception)
      Rails.logger.error "API Error: #{exception.message}"
      render json: { error: 'Internal server error' }, status: :internal_server_error
    end

    def handle_not_found(exception)
      render json: { error: 'Resource not found' }, status: :not_found
    end

    def handle_parameter_missing(exception)
      render json: { error: "Missing parameter: #{exception.param}" }, status: :bad_request
    end

    def handle_validation_error(exception)
      render json: { errors: exception.errors }, status: :unprocessable_content
    end

    def handle_creation_error(exception)
      render json: { errors: exception.errors }, status: :unprocessable_content
    end
  end
end
