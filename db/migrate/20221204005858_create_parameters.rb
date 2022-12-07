class CreateParameters < ActiveRecord::Migration[7.0]
  def change
    create_table :parameters do |t|
      t.float :from
      t.float :to
      t.float :m
      t.float :k
      t.integer :n_s
      t.integer :n_g

      t.timestamps
    end
  end
end
