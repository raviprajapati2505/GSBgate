class ArchivesController < AuthenticatedController
  load_and_authorize_resource

  def show
    # send_file(@archive.archive_path, type: 'application/zip', disposition: 'attachment', filename: @archive.archive_file, x_sendfile: true)
    response.headers['X-Sendfile'] = @archive.archive_path
    response.headers['Content-Length'] = '0'
    response.headers['Content-Type'] = 'application/zip'
    response.headers['Content-Disposition'] = "attachment; filename=\"#{@archive.archive_file}\""
    render nothing: true, status: :ok
  end
end