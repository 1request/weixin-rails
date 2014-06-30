# Add user_id to Customer
 
Account.all.each do |account|
  if Rails.env.production?
    account.user_id = 'sM5hspKjnPWq5or2o' # admin@xin.io
    account.save!
  end

  if Rails.env.development?
    account.user_id = 'R4ifEHCcasrrmSjSh' # puiesabu@gmail.com
    account.save!
  end
end
  