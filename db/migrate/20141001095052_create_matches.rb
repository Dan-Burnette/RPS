class CreateMatches < ActiveRecord::Migration
  def change
    create_table :matches do |t|
      t.integer :user1
      t.integer :user2
      t.integer :winner
    end
  end
end
