class CreateProfileQuestions < ActiveRecord::Migration
  def self.up
    create_table :profile_questions do |t|
      t.string :question, :limit => 4000, :null => false
      t.integer :hashed_question, :null => false
      t.boolean :shown, :null => false, :default => false
      t.integer :created_by_user_id, :null => false
      t.timestamps
    end
    
    add_index :profile_questions, :created_by_user_id
    add_index :profile_questions, :shown
    add_index :profile_questions, :hashed_question
  end

  def self.down
    drop_table :profile_questions
  end
end
