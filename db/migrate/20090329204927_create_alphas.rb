class CreateAlphas < ActiveRecord::Migration
  def self.database_model
    return "Alpha"
  end

  def self.up
    create_table :alphas do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :alphas
  end
end
