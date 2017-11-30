json.comments @comments do |comment|
  json.comment comment.comment
  json.date date(comment.created_at)
  json.user do
    json.id comment.user.id
    json.real_name comment.user.real_name
    json.photo_url user_photo_url(comment.user)
    json.url url_for(comment.user)
  end
  json.url url_for(comment)
  json.mine comment.user == current_user
end
json.next_page_url @comments.next_page && polymorphic_url([@resource, Comment], :page => @comments.next_page)