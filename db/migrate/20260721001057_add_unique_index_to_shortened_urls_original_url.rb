class AddUniqueIndexToShortenedUrlsOriginalUrl < ActiveRecord::Migration[8.0]
  def change
    add_index :shortened_urls, :original_url, unique: true, name: "idx_shortened_urls_original_url_unique"
  end
end
