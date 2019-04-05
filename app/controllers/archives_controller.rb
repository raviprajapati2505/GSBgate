class ArchivesController < AuthenticatedController
  load_and_authorize_resource

  def show
    # send_file(@archive.archive_path, type: 'application/zip', disposition: 'attachment', filename: @archive.archive_file, x_sendfile: true)
    response.set_header('X-Sendfile', @archive.archive_path)
    response.set_header('Content-Type', 'application/zip')
    response.set_header('Content-Disposition', "attachment; filename=\"#{@archive.archive_file}\"")
    return response
  end
end