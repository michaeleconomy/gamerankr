class ContactMailer < ApplicationMailer
  
  def contact(user_id, data)
    @user = user_id && User.find(user_id)
    @data = data

    from = (@user && @user.email) || "signed_out"
    subject = "GameRankr Contact form from: #{from}"
    mail(:to => "michae" + "leco#{""}nomy@gmail.com", :subject => subject)
  end

  def flag(user_id, resource_id, resource_type, text)
    @user = user_id && User.where(id: user_id).first
    type = FlaggedItem.get_type(resource_type)
    @resource = type && resource_id && type.where(id: resource_id).first
    @text = text
    subject = "Gamerankr - flagged resource - #{resource_type} #{@resource && @resource.to_param}"
    mail(:to => "michae" + "leco#{""}nomy@gmail.com", :subject => subject)
  end
end