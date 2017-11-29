class SandboxEmailInterceptor
  def self.delivering_email(message)
    message.to = ['michaelecono' +'my@gmail.com']
  end
end