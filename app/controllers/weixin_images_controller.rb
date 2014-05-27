class WeixinImagesController < ApplicationController
  before_action :set_weixin_image, only: [:show, :edit, :update, :destroy]

  # GET /weixin_images
  # GET /weixin_images.json
  def index
    @weixin_images = WeixinImage.all
    @customers = User.all
    @customer = @customers.first
  end

  # GET /weixin_images/1
  # GET /weixin_images/1.json
  def show
  end

  # GET /weixin_images/new
  def new
    @weixin_image = WeixinImage.new
  end

  # GET /weixin_images/1/edit
  def edit
  end

  # POST /weixin_images
  # POST /weixin_images.json
  def create
    @weixin_image = WeixinImage.new(weixin_image_params)

    respond_to do |format|
      if @weixin_image.save
        format.html { redirect_to @weixin_image, notice: 'Weixin image was successfully created.' }
        format.json { render action: 'show', status: :created, location: @weixin_image }
      else
        format.html { render action: 'new' }
        format.json { render json: @weixin_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /weixin_images/1
  # PATCH/PUT /weixin_images/1.json
  def update
    respond_to do |format|
      if @weixin_image.update(weixin_image_params)
        format.html { redirect_to @weixin_image, notice: 'Weixin image was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @weixin_image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /weixin_images/1
  # DELETE /weixin_images/1.json
  def destroy
    @weixin_image.destroy
    respond_to do |format|
      format.html { redirect_to weixin_images_url }
      format.json { head :no_content }
    end
  end

  def send_image
    client ||= WeixinAuthorize::Client.new("wxe2e163d3337f28ee", "0ce603e4068fd1f8ee5ef324473d5687")
    
    result1 = client.upload_media(params['file_path'], "image")
    #binding.pry

    result2 = client.send_image_custom(params['weixin_id'].strip, result1.result['media_id'])
    binding.pry

    respond_to do |format|
      format.html { redirect_to weixin_images_path }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_weixin_image
      @weixin_image = WeixinImage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def weixin_image_params
      params.require(:weixin_image).permit(:image, :file_path, :weixin_id)
    end
end
