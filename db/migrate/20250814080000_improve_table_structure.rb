class ImproveTableStructure < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :redirect_logs, :shortened_urls
    add_foreign_key :redirect_logs, :shortened_urls, on_delete: :cascade, name: "fk_redirect_logs_shortened_url_id"
    add_index :shortened_urls, :original_url
    change_column :shortened_urls, :original_url, :string, null: false, limit: 2048
    change_column :shortened_urls, :short_code, :string, null: false, limit: 6
  end
end
