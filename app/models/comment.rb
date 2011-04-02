class Comment < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :user
  
  validates_presence_of :user, :resource
  validates_length_of :body, :minimum => 1
end
