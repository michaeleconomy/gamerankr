class RemoveAmazonDescriptions < ActiveRecord::Migration[5.1]
  def up
  	AmazonPort.update_all(description: nil)
  end
end
