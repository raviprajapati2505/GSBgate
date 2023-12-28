class ImageUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "../private/projects/#{model.id}/#{mounted_as}"
  end

  def extension_white_list
    %w(jpg jpeg gif png zip)
  end

  def extension_white_list_js
    '.' + self.extension_white_list.join(',.')
  end
end
