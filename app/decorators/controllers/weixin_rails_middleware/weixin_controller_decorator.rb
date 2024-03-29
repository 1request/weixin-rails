# encoding: utf-8
# 1, @weixin_message: 获取微信所有参数.
# 2, @weixin_public_account: 如果配置了public_account_class选项,则会返回当前实例,否则返回nil.
# 3, @keyword: 目前微信只有这三种情况存在关键字: 文本消息, 事件推送, 接收语音识别结果
WeixinRailsMiddleware::WeixinController.class_eval do

  def reply
    @account = Account.where(gh_id: @weixin_message.ToUserName).first
    @client ||= WeixinAuthorize::Client.new(@account.app_id, @account.app_secret)

    @customer = Customer.where(fromUser: @weixin_message.FromUserName).first
    unless @customer
      id = BSON::ObjectId.new
      @customer = Customer.create(_id: id.to_s, account_id: @account._id, fromUser: @weixin_message.FromUserName) 
      
      @customer.user_info = @client.user(@weixin_message.FromUserName).result
      @customer.save
    end

    render xml: send("response_#{@weixin_message.MsgType}_message", {})
  end

  private
    def create_message(content_type=nil, options={})
      message = Message.where(:weixin_msg_id => @weixin_message.MsgId).first
      unless message
        # Create message
        message = Message.create(
          :account_id => @account._id,
          :customer_id => @customer._id, 
          :message_type => "customer", 
          :content_type => content_type,
          :weixin_msg_id => @weixin_message.MsgId)

        # Download media from weixin
        remote_media_url = options[:remote_media_url] || @client.download_media_url(@weixin_message.MediaId)
        message.remote_media_url = remote_media_url
        message.save

        # Set media URL
        message.message = options.has_key?(:version) ? message.media_url(options[:version]) : message.media_url
        message.save
        @customer.count = @customer.count + 1
        @customer.last_message_at = Time.at(@weixin_message.CreateTime).utc
        @customer.save
      end
      return message
    end

    def response_text_message(options={})
      message = Message.where(:weixin_msg_id => @weixin_message.MsgId).first
      unless message
        Message.create(
          :account_id => @account._id,
          :customer_id => @customer._id, 
          :message_type => 'customer', 
          :message => @weixin_message.Content,
          :content_type => 'text',
          :weixin_msg_id => @weixin_message.MsgId)
        @customer.count = @customer.count + 1
        @customer.last_message_at = Time.at(@weixin_message.CreateTime).utc
        @customer.save
      end

      reply_text_message("")
    end

    # <Location_X>23.134521</Location_X>
    # <Location_Y>113.358803</Location_Y>
    # <Scale>20</Scale>
    # <Label><![CDATA[位置信息]]></Label>
    def response_location_message(options={})
      @lx    = @weixin_message.Location_X
      @ly    = @weixin_message.Location_Y
      @scale = @weixin_message.Scale
      @label = @weixin_message.Label

      message = Message.where(:weixin_msg_id => @weixin_message.MsgId).first
      unless message
        Message.create(
          :account_id => @account._id,
          :customer_id => @customer._id, 
          :message_type => 'customer', 
          :message => "#{@lx}, #{@ly}",
          :content_type => 'location',
          :weixin_msg_id => @weixin_message.MsgId)
        @customer.count = @customer.count + 1
        @customer.last_message_at = Time.at(@weixin_message.CreateTime).utc
        @customer.save
      end

      reply_text_message("")
    end

    # <PicUrl><![CDATA[this is a url]]></PicUrl>
    # <MediaId><![CDATA[media_id]]></MediaId>
    def response_image_message(options={})
      #@media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      #reply_image_message(generate_image(@media_id))
      create_message("image", {:remote_media_url => @weixin_message.PicUrl})
      reply_text_message("")
    end

    # <Title><![CDATA[公众平台官网链接]]></Title>
    # <Description><![CDATA[公众平台官网链接]]></Description>
    # <Url><![CDATA[url]]></Url>
    def response_link_message(options={})
      @title = @weixin_message.Title
      @desc  = @weixin_message.Description
      @url   = @weixin_message.Url
      reply_text_message("回复链接信息")
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <Format><![CDATA[Format]]></Format>
    def response_voice_message(options={})
      #@media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      #@format   = @weixin_message.Format

      # 如果开启了语音翻译功能，@keyword则为翻译的结果
      # reply_text_message("回复语音信息: #{@keyword}")
      #reply_voice_message(generate_voice(@media_id))
      create_message("voice", {:version => :mp3})
      reply_text_message("")
    end

    # <MediaId><![CDATA[media_id]]></MediaId>
    # <ThumbMediaId><![CDATA[thumb_media_id]]></ThumbMediaId>
    def response_video_message(options={})
      #@media_id = @weixin_message.MediaId # 可以调用多媒体文件下载接口拉取数据。
      # 视频消息缩略图的媒体id，可以调用多媒体文件下载接口拉取数据。
      #@thumb_media_id = @weixin_message.ThumbMediaId
      #reply_text_message("回复视频信息")
      create_message("video")
      reply_text_message("")
    end

    def response_event_message(options={})
      event_type = @weixin_message.Event
      send("reply_#{event_type.downcase}_event")
    end

    private

      # 关注公众账号
      def reply_subscribe_event
        if @keyword.present?
          # 扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送
          return reply_text_message("扫描带参数二维码事件: 1. 用户未关注时，进行关注后的事件推送, keyword: #{@keyword}")
        end
        reply_text_message("关注公众账号")
      end

      # 取消关注
      def reply_unsubscribe_event
        Rails.logger.info("取消关注")
      end

      # 扫描带参数二维码事件: 2. 用户已关注时的事件推送
      def reply_scan_event
        reply_text_message("扫描带参数二维码事件: 2. 用户已关注时的事件推送, keyword: #{@keyword}")
      end

      def reply_location_event # 上报地理位置事件
        @lat = @weixin_message.Latitude
        @lgt = @weixin_message.Longitude
        @precision = @weixin_message.Precision
        reply_text_message("Your Location: #{@lat}, #{@lgt}, #{@precision}")
      end

      # 点击菜单拉取消息时的事件推送
      def reply_click_event
        reply_text_message("你点击了: #{@keyword}")
      end

      # 点击菜单跳转链接时的事件推送
      def reply_view_event
        Rails.logger.info("你点击了: #{@keyword}")
      end

end
