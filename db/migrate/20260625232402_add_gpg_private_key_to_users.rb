# frozen_string_literal: true

class AddGpgPrivateKeyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :private_key, :text, null: false, default: ' '
  end
end
