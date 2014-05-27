json.array!(@weixin_images) do |weixin_image|
  json.extract! weixin_image, :id, :image
  json.url weixin_image_url(weixin_image, format: :json)
end
