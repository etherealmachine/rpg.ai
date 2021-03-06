# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_18_015459) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.integer "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "backgrounds", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.json "description"
    t.json "proficiencies"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_backgrounds_on_source_id"
  end

  create_table "character_classes", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.integer "hit_die"
    t.json "proficiencies"
    t.string "spell_ability"
    t.json "levels"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_character_classes_on_source_id"
  end

  create_table "character_equipment", id: false, force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "item_id", null: false
    t.boolean "equipped"
    t.integer "charges"
    t.json "notes"
  end

  create_table "character_feats", id: false, force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "feat_id", null: false
    t.integer "level"
  end

  create_table "character_levels", id: false, force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "character_class_id", null: false
    t.integer "level"
  end

  create_table "character_spells", id: false, force: :cascade do |t|
    t.integer "character_id", null: false
    t.integer "spell_id", null: false
    t.boolean "memorized"
  end

  create_table "characters", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.integer "initiative"
    t.integer "hit_points"
    t.decimal "gold"
    t.json "conditions"
    t.integer "monster_id"
    t.integer "race_id"
    t.integer "background_id"
    t.json "proficiencies"
    t.string "alignment"
    t.json "abilities"
    t.json "spell_slots"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["background_id"], name: "index_characters_on_background_id"
    t.index ["monster_id"], name: "index_characters_on_monster_id"
    t.index ["race_id"], name: "index_characters_on_race_id"
    t.index ["user_id"], name: "index_characters_on_user_id"
  end

  create_table "feats", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.string "prerequisite"
    t.json "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_feats_on_source_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.boolean "magical"
    t.boolean "attunement"
    t.boolean "stealth"
    t.string "rarity"
    t.integer "range"
    t.integer "range_2"
    t.integer "strength"
    t.string "damage"
    t.string "damage_2"
    t.decimal "value"
    t.decimal "weight"
    t.integer "armor_class"
    t.string "damage_type"
    t.json "description"
    t.json "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_items_on_source_id"
  end

  create_table "monsters", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.string "description"
    t.decimal "challenge_rating"
    t.integer "armor_class"
    t.string "armor_description"
    t.string "hit_points"
    t.integer "passive_perception"
    t.string "size"
    t.integer "speed"
    t.string "alignment"
    t.json "types"
    t.json "languages"
    t.json "abilities"
    t.json "skills"
    t.json "senses"
    t.json "saves"
    t.json "resistances"
    t.json "vulnerabilities"
    t.json "immunities"
    t.json "traits"
    t.json "actions"
    t.json "reactions"
    t.json "legendaries"
    t.json "spell_slots"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_monsters_on_source_id"
  end

  create_table "monsters_spells", id: false, force: :cascade do |t|
    t.integer "monster_id", null: false
    t.integer "spell_id", null: false
  end

  create_table "races", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.json "traits"
    t.json "abilities"
    t.json "proficiencies"
    t.string "size"
    t.integer "speed"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_races_on_source_id"
  end

  create_table "random_tables", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.string "roll"
    t.json "columns"
    t.json "table"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_random_tables_on_source_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.integer "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_sources_on_user_id"
  end

  create_table "spells", force: :cascade do |t|
    t.string "name"
    t.integer "source_id"
    t.integer "level"
    t.string "casting_time"
    t.string "duration"
    t.string "range"
    t.string "components"
    t.json "classes"
    t.string "school"
    t.boolean "ritual"
    t.json "description"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["source_id"], name: "index_spells_on_source_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.string "tagger_type"
    t.integer "tagger_id"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["context"], name: "index_taggings_on_context"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_id", "taggable_type", "context"], name: "taggings_taggable_context_idx"
    t.index ["taggable_id", "taggable_type", "tagger_id", "context"], name: "taggings_idy"
    t.index ["taggable_id"], name: "index_taggings_on_taggable_id"
    t.index ["taggable_type"], name: "index_taggings_on_taggable_type"
    t.index ["tagger_id", "tagger_type"], name: "index_taggings_on_tagger_id_and_tagger_type"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tilemap_layers", force: :cascade do |t|
    t.integer "tilemap_id"
    t.integer "tilemap_layer_id"
    t.string "name"
    t.integer "width"
    t.integer "height"
    t.string "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tilemap_id"], name: "index_tilemap_layers_on_tilemap_id"
    t.index ["tilemap_layer_id"], name: "index_tilemap_layers_on_tilemap_layer_id"
  end

  create_table "tilemap_objects", force: :cascade do |t|
    t.integer "tilemap_id"
    t.integer "tilemap_layer_id"
    t.string "name"
    t.integer "x"
    t.integer "y"
    t.integer "width"
    t.integer "height"
    t.string "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"tilemap\"", name: "index_tilemap_objects_on_tilemap"
    t.index ["tilemap_id"], name: "index_tilemap_objects_on_tilemap_id"
    t.index ["tilemap_layer_id"], name: "index_tilemap_objects_on_tilemap_layer_id"
  end

  create_table "tilemap_tiles", force: :cascade do |t|
    t.integer "tilemap_id"
    t.integer "tilemap_layer_id"
    t.integer "x"
    t.integer "y"
    t.integer "tilemap_tileset_id"
    t.integer "index"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"tilemap\"", name: "index_tilemap_tiles_on_tilemap"
    t.index ["tilemap_id"], name: "index_tilemap_tiles_on_tilemap_id"
    t.index ["tilemap_layer_id"], name: "index_tilemap_tiles_on_tilemap_layer_id"
    t.index ["tilemap_tileset_id"], name: "index_tilemap_tiles_on_tilemap_tileset_id"
  end

  create_table "tilemap_tilesets", force: :cascade do |t|
    t.integer "tilemap_id"
    t.integer "tileset_id"
    t.string "source"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"tilemap\"", name: "index_tilemap_tilesets_on_tilemap"
    t.index ["tilemap_id"], name: "index_tilemap_tilesets_on_tilemap_id"
    t.index ["tileset_id"], name: "index_tilemap_tilesets_on_tileset_id"
  end

  create_table "tilemaps", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "description"
    t.string "orientation"
    t.integer "width"
    t.integer "height"
    t.integer "hexsidelength"
    t.string "staggeraxis"
    t.string "staggerindex"
    t.integer "tilewidth"
    t.integer "tileheight"
    t.string "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"user\"", name: "index_tilemaps_on_user"
    t.index ["user_id"], name: "index_tilemaps_on_user_id"
  end

  create_table "tileset_tiles", force: :cascade do |t|
    t.integer "tileset_id"
    t.integer "index"
    t.string "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["tileset_id"], name: "index_tileset_tiles_on_tileset_id"
  end

  create_table "tilesets", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "description"
    t.integer "margin"
    t.integer "spacing"
    t.integer "tilewidth"
    t.integer "tileheight"
    t.string "properties"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index "\"user\"", name: "index_tilesets_on_user"
    t.index ["user_id"], name: "index_tilesets_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "api_token", default: "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "provider"
    t.string "uid"
    t.string "token"
    t.integer "expires_at"
    t.boolean "expires"
    t.string "refresh_token"
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "taggings", "tags"
  add_foreign_key "tilemap_layers", "tilemaps", on_delete: :cascade
  add_foreign_key "tilemap_objects", "tilemap_layers", on_delete: :cascade
  add_foreign_key "tilemap_objects", "tilemaps", on_delete: :cascade
  add_foreign_key "tilemap_tiles", "tilemap_layers", on_delete: :cascade
  add_foreign_key "tilemap_tiles", "tilemap_tilesets", on_delete: :cascade
  add_foreign_key "tilemap_tiles", "tilemaps", on_delete: :cascade
  add_foreign_key "tilemap_tilesets", "tilemaps", on_delete: :cascade
  add_foreign_key "tilemaps", "users", on_delete: :cascade
  add_foreign_key "tileset_tiles", "tilesets", on_delete: :cascade
  add_foreign_key "tilesets", "users", on_delete: :cascade
end
