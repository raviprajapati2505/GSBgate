class ActualProjectImagesController < AuthenticatedController
  load_and_authorize_resource :project
  before_action :set_image_record, only: [:destroy, :show]

  def create
    respond_to do |format|
      if params.has_key?(:image)
        @actual_project_image = @project.actual_project_images.new(actual_image_params)

        @actual_project_image.certification_path = set_certificate

        if @actual_project_image.save
          format.html { redirect_back(fallback_location: root_path, notice: 'The image was successfully uploaded.') }
          format.json { render json: @actual_project_image }
        else
          format.html { redirect_back(fallback_location: root_path, alert: 'Image failed to upload.') }
          format.json { render json: @actual_project_image['actual_image'].to_s, status: :unprocessable_entity }
        end
      else
        format.html { redirect_back(fallback_location: project_path(@project), alert: 'Image must be present!') }
        format.json { render json: @image_record&.to_s, status: :unprocessable_entity }
      end
    end
  end

  def show
    begin
      send_file @image_record.actual_image.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This image is no longer available for download. This could be due to a detection of malware.')
    end
  end

  def destroy
    respond_to do |format|
      directories = @image_record.actual_image.store_dir.split('/')
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

  def set_certificate
    certification_path = CertificationPath.with_project(@project)
    certification_path.last if certification_path.any?
  end

  def set_image_record
    @image_record = @project.actual_project_images.find(params[:id])
  end

  def actual_image_params
    params.require(:image).permit(:actual_image)
  end
end
