class RemoveUploadedAtFromWeixinImage < ActiveRecord::Migration
  def change
    remove_column :weixin_images, :uploaded_at, :timestamps
  end
end
