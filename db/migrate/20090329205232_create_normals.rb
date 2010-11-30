class CreateNormals < ActiveRecord::Migration
  def self.up
    create_table :normals do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :normals
  end
end
