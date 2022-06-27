class UserSubmittalUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "../private/users/#{model.id}/general_submittals/#{mounted_as}"
  end

  def extension_whitelist
    %w(jpeg jpg mcd mdb pdf png pps pptx psd pub qxd
    rar txt xls xlsx zip)
  end
end