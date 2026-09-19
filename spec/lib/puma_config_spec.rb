require "rails_helper"
require Rails.root.join("lib", "puma_config")

RSpec.describe PumaConfig do
  describe ".solid_queue_in_puma?" do
    context "when SOLID_QUEUE_IN_PUMA is not set" do
      it "returns true in production (Railway has no separate worker process)" do
        expect(described_class.solid_queue_in_puma?({ "RAILS_ENV" => "production" })).to eq(true)
      end

      it "returns false in development" do
        expect(described_class.solid_queue_in_puma?({ "RAILS_ENV" => "development" })).to eq(false)
      end

      it "returns false in test" do
        expect(described_class.solid_queue_in_puma?({ "RAILS_ENV" => "test" })).to eq(false)
      end
    end

    context "when SOLID_QUEUE_IN_PUMA is explicitly set" do
      it "honors an explicit false in production" do
        env = { "RAILS_ENV" => "production", "SOLID_QUEUE_IN_PUMA" => "false" }
        expect(described_class.solid_queue_in_puma?(env)).to eq(false)
      end

      it "honors an explicit true in development" do
        env = { "RAILS_ENV" => "development", "SOLID_QUEUE_IN_PUMA" => "true" }
        expect(described_class.solid_queue_in_puma?(env)).to eq(true)
      end
    end
  end
end
