# patch Custmoer.last_message_at

Customer.all.each do |customer|
  last_message = Message.where(customer_id: customer._id).order(created_at: :desc).first
  customer.last_message_at = last_message.created_at
  customer.save!
end