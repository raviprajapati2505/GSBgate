class ProfilePicUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "../public/uploads/#{mounted_as}"
  end

  def extension_whitelist
    %w(jpeg jpg png)
  end
end