class BaseDocumentController < AuthenticatedController

  def create
    raise NotImplementedError
  end

  def destroy
    respond_to do |format|
      directories = @controller_model.document_file.store_dir.split('/')
      directories.delete_at(0) # delete '..'
      directories.delete_at(0) # delete 'private' subdirectory
      directory = directories.join('/')
      filepath = Rails.root.to_s + '/private/' + directory + '/' + @controller_model.name
      # delete physical file
      begin
        File.delete(filepath)
      rescue Errno::ENOENT
      end
      # delete empty directories
      begin
        until directories.empty?
          directory = directories.join('/')
          Dir.delete(Rails.root.to_s + '/private/' + directory)
          directories.pop
        end
      rescue SystemCallError
      end
      # delete database record
      @controller_model.destroy
      format.html { redirect_to :back, notice: 'The document was successfully deleted.' }
    end
  end

  def show
    begin
      send_file @controller_model.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_to :back, alert: 'This document is no longer available for download. This could be due to a detection of malware.'
    end
  end
end