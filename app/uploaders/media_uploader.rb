# encoding: utf-8
require 'mini_exiftool'

class MediaUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Video
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/message/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  process :rotate_image, :if => :image? 

  def image?(newfile)
    %w{jpeg png jpg gif bmp}.include?(newfile.extension.downcase)
  end

  def rotate_image #this is my attempted solution
    manipulate! do |img|
      img.tap(&:auto_orient)
    end
  end

  process :rotate_video, :if => :video?

  def video?(newfile)
    %w{mp4}.include?(newfile.extension.downcase)
  end

  def rotate_video
    video = MiniExiftool.new(@file.path)
    orientation = video.rotation

    if orientation == 90
      # rotate video
      Rails.logger.debug "portrait video"
      aspect_ratio = video.imageheight.to_f / video.imagewidth.to_f
      encode_video(:mp4, custom: "-vf transpose=1", aspect: aspect_ratio)
    else
      aspect_ratio = video.imagewidth.to_f / video.imageheight.to_f
      encode_video(:mp4, resolution: :same, aspect: aspect_ratio)
    end

    instance_variable_set(:@content_type, "video/mp4")
    :set_content_type_mp4
  end

  process :set_content_type, :if => :audio? 

  def audio?(newfile)
    self.class.audio?(newfile)
  end

  def self.audio?(newfile)
    %w{amr mp3 ogg}.include?(newfile.extension.downcase)
  end

  def self.need?
    Proc.new{|origin_file, current_version| audio?(origin_file.file) && current_version[:version].to_s != origin_file.file.extension }
  end

  def filename 
    "#{secure_token}.#{file.extension}" if original_filename 
  end 

  def move_to_store
    true
  end

  version :mp3, :if => need? do
    process :encode_video => [:mp3]
    def full_filename (for_file = file.filename)
      for_file[0...for_file.rindex('.')] + '.mp3'
    end
  end

  version :ogg, :if => need? do
    process :encode_video => [:ogg]
    def full_filename (for_file = file.filename)
      for_file[0...for_file.rindex('.')] + '.ogg'
    end
  end

protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
