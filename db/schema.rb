# frozen_string_literal: true

ActiveRecord::Migration.create_table :sequences do |t|
  t.string :color, index: true
  t.string :pattern, index: true
  t.string :sorted_pattern, index: true
end
