class CreateSpamFilters < ActiveRecord::Migration[7.0]
  def change
    create_table :spam_filters do |t|
      t.string :keyword, null: false
      t.timestamps
    end
  end
end
