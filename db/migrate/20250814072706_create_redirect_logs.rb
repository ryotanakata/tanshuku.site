class CreateRedirectLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :redirect_logs do |t|
      t.references :shortened_url, null: false, foreign_key: true
      t.string :ip_address, null: false
      t.string :country, null: false
      t.string :city, null: false
      t.string :isp, null: false
      t.string :user_agent, null: false
      t.string :referer, null: false

      t.timestamps
    end

    add_index :redirect_logs, :created_at
    add_index :redirect_logs, :country
    add_index :redirect_logs, [:shortened_url_id, :created_at]
  end
end
