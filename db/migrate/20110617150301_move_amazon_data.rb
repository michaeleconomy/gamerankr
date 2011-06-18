class MoveAmazonData < ActiveRecord::Migration
  def self.up
    Port.includes(:additional_data).all.each do |p|
      if !p.additional_data && p.asin?
        ap = AmazonPort.create(
          :asin => p.asin,
          :price => p.amazon_price,
          :url => p.amazon_url,
          :image_url => p.amazon_image_url,
          :description => p.amazon_description)
        p.additional_data = ap
        p.save
      end
    end
  end

  def self.down
  end
end
