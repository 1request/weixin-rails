# config/initialize/ffmpeg.rb
FFMPEG.ffmpeg_binary = '/usr/local/bin/ffmpeg'
FFMPEG::Transcoder.timeout  = 60 * 10
unless Rails.env.development?
  FFMPEG.logger = Logger.new(File.join(Rails.root, 'log/ffmpeg_transcoder.log'))
end
