# frozen_string_literal: true

class AddGpgPublicKeyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :public_key, :string, default: ' '
  end
end
