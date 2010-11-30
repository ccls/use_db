class CreateGammas < ActiveRecord::Migration
  def self.database_model
    return "Gamma"
  end

  def self.up
    create_table :gammas do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :gammas
  end
end
