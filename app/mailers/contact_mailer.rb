class ContactMailer < ApplicationMailer
  
  def contact(user_id, data)
    @user = User.find(user_id)
    @data = data

    subject = "Gamerankr Contact form from: #{@user.real_name} id:#{@user.id}"
    mail(:to => "michae" + "leco#{""}nomy@gmail.com", :subject => subject)
  end
end