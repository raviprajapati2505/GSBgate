class ArchivesController < AuthenticatedController
  load_and_authorize_resource

  def show
    send_file(@archive.archive_path, type: 'application/zip', disposition: 'attachment', filename: @archive.archive_file, x_sendfile: false)
  end
end