class CreateWeixinImages < ActiveRecord::Migration
  def change
    create_table :weixin_images do |t|
      t.string :image
      t.timestamps :uploaded_at

      t.timestamps
    end
  end
end
