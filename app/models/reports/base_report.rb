require 'fileutils'
require 'prawn'
require 'prawn/table'

class Reports::BaseReport
  include Prawn::View

  FONTS_DIR = '/app/assets/fonts/reports'
  IMAGES_DIR = '/app/assets/images/reports/'

  def newline(amount = 1)
    text "\n" * amount
  end

  def font_path(filename)
    "#{Rails.root}#{FONTS_DIR}/#{filename}"
  end

  def image_path(filename)
    "#{Rails.root}#{IMAGES_DIR}/#{filename}"
  end

  def save_as(file_name)
    FileUtils.mkdir_p(File.dirname(file_name))
    document.render_file(file_name)
  end
end