class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  validates_presence_of :user, :resource

  validates_length_of :comment, :in => 1..4000
  validates_inclusion_of :resource_type, :in => ["Ranking"]

  after_create_commit {CommentNotificationJob.perform_async(id)}

  self.per_page = 5
end
