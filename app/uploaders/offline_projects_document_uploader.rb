class OfflineProjectsDocumentUploader < CarrierWave::Uploader::Base
  storage :file

  def store_dir
    "../private/offline/projects/#{model.id}/#{mounted_as}"
  end

  def extension_white_list
    %w(7z ace ai bmp cab cdr doc docx dwg eml eps gif gz
    indd jpeg jpg mcd mdb pdf png pps pptx psd pub qxd
    rar rtf sea tgz tif ttf txt xls xlsx zip)
  end

  def extension_white_list_js
    '.' + self.extension_white_list.join(',.')
  end
end