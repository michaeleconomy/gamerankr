class CreateUserProfileQuestions < ActiveRecord::Migration
  def self.up
    create_table :user_profile_questions do |t|
      t.integer :user_id, :null => false
      t.integer :profile_question_id, :null => false
      t.string :answer, :limit => 4000, :null => false
      t.timestamps
    end
    
    add_index :user_profile_questions, [:user_id, :profile_question_id],
      :unique => true
    add_index :user_profile_questions, :profile_question_id
  end

  def self.down
    drop_table :user_profile_questions
  end
end
