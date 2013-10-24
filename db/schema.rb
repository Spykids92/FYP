# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20130708132211) do

  create_table "generators", force: true do |t|
    t.integer  "primer_length"
    t.integer  "no_A"
    t.integer  "no_T"
    t.integer  "no_G"
    t.integer  "no_C"
    t.float    "melting_temp"
    t.string   "choice"
    t.string   "random_primer_generated"
    t.string   "user_seq"
    t.string   "f_primer"
    t.string   "r_primer"
    t.string   "result_choice"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", force: true do |t|
    t.string   "ncbi_ref_seq"
    t.string   "genome_seq"
    t.string   "genome_sample"
    t.integer  "binding_times"
    t.integer  "amp_frags"
    t.integer  "generator_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "results", ["generator_id"], name: "index_results_on_generator_id"

end
