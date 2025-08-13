class CreateShortenedUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :shortened_urls do |t|
      t.string :original_url
      t.string :short_code

      t.timestamps
    end
    add_index :shortened_urls, :short_code, unique: true
  end
end
