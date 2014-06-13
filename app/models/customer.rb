class Customer
  include Mongoid::Document
  include Mongoid::Timestamps

  field :_id, type: String
  field :fromUser, type: String
  field :name, type: String
  field :sex, type: String
  field :language, type: String
  field :headimgurl, type: String
  field :city, type: String
  field :province, type: String
  field :country, type: String
  field :subscribe, type: Boolean
  field :subscribe_time, type: Integer
  field :count, type: Integer, default: 0

  def user_info=(user_info)
    self[:name] = user_info['nickname']
    self[:sex] = 
      case user_info['sex'].to_i
      when 1 then 'M'
      when 2 then 'F'
      else nil 
      end
    self[:language] = user_info['language']
    self[:headimgurl] = user_info['headimgurl']
    self[:city] = user_info['city']
    self[:province] = user_info['province']
    self[:country] = user_info['country']
    self[:subscribe] = user_info['subscribe']
    self[:subscribe_time] = user_info['subscribe_time']
  end
end
