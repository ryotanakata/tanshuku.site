# Configure overseas blocking middleware
require_relative '../../app/middleware/block_overseas_middleware'
Rails.application.config.middleware.use BlockOverseasMiddleware
