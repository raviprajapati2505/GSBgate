class ProjectRenderingImagesController < AuthenticatedController
  load_and_authorize_resource :project
  before_action :set_image_record, only: [:destroy, :show]

  def create
    respond_to do |format|
      if params.has_key?(:image)
        @project_rendering_image = @project.project_rendering_images.new(set_image)
        loc = CertificationPath.with_project(@project).with_certification_type(Certificate.certification_types[:letter_of_conformance])
        if loc.any?
          @project_rendering_image.certification_path = loc.last
        end
        if @project_rendering_image.save
          format.html { redirect_back(fallback_location: root_path, notice: 'The image was successfully uploaded.') }
          format.json { render json: @project_rendering_image }
        else
          format.html { redirect_back(fallback_location: root_path, alert: 'Image failed to upload.') }
          format.json { render json: @project_rendering_image['rendering_image'].to_s, status: :unprocessable_entity }
        end
      end
    end
  end

  def show
    begin
      send_file @image_record.rendering_image.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This image is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def destroy
    respond_to do |format|
      directories = @image_record.rendering_image.store_dir.split('/')
      directories.delete_at(0) # delete '..'
      directories.delete_at(0) # delete 'private' subdirectory
      directory = directories.join('/')
      destroyed_image = @image_record.destroy
      begin
        until directories.empty?
          directory = directories.join('/')
          Dir.delete(Rails.root.to_s + '/private/' + directory)
          directories.pop
        end
      rescue SystemCallError
      end
      format.html { redirect_back(fallback_location: root_path, notice: 'The image was successfully deleted.') }
    end
  end

  private

  def set_image_record
    @image_record = @project.project_rendering_images.find(params[:id])
  end

  def set_image
    params.require(:image).permit(:rendering_image)
  end
end
