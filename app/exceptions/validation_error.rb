class ValidationError < StandardError
  attr_reader :errors

  def initialize(errors)
    @errors = errors
    super("Validation failed: #{errors.join(', ')}")
  end
end
