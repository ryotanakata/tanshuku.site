class ShortenedUrlCreationError < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("Failed to create shortened URL: #{errors.join(', ')}")
  end
end
