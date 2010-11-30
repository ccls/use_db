class CreateBetas < ActiveRecord::Migration
  def self.database_model
    return "Beta"
  end

  def self.up
    create_table :betas do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :betas
  end
end
