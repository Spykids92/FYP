class CreateGenerators < ActiveRecord::Migration
  def change
    create_table :generators do |t|
      t.integer :primer_length
      t.integer :no_A
      t.integer :no_T
      t.integer :no_G
      t.integer :no_C
      t.float :melting_temp
      t.string :choice
      t.string :random_primer_generated
      t.string :user_seq
      t.string :f_primer
      t.string :r_primer
      t.string :result_choice
      t.references :user
      t.timestamps
    end
         
  end
end
