class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :ncbi_ref_seq
      t.text :genome_seq
      t.text :genome_sample
      t.integer :binding_times
      t.integer :amp_frags
      t.integer :seqpos1, :array => true
      t.integer :seqpos2, :array => true
      t.references :generator
      t.timestamps
    end
    add_index :results, :generator_id
  end
end