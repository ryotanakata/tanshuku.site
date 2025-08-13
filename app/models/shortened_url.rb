class ShortenedUrl < ApplicationRecord
  validates :original_url, presence: true
  validates :short_code, presence: true, uniqueness: true, length: { is: 6 }
end
