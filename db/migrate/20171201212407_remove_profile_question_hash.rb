class RemoveProfileQuestionHash < ActiveRecord::Migration[5.1]
  def change
    remove_index :profile_questions, :hashed_question
    remove_column :profile_questions, :hashed_question
    add_index :profile_questions, :question, :unique => true
  end
end
