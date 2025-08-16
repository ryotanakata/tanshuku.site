class RedirectLog < ApplicationRecord
  belongs_to :shortened_url

  validates :shortened_url, presence: true

  scope :recent, -> { where("created_at > ?", 30.days.ago) }
  scope :by_date, ->(date) { where("DATE(created_at) = ?", date) }
  scope :japanese_only, -> { where.not(ip_address: nil) }
end
