class DocumentArchiverService
  include Singleton
  require 'zip'

  CLEAN_OLDER_THAN = 1.day
  PAGE_SIZE = 100

  # Creates a file archive of all approved documents in a certification path
  def create_archive(certification_path)
    archive_path = Rails.root.join('private', 'projects', certification_path.project_id.to_s, 'certification_paths', certification_path.id.to_s, 'archives', sanitize_filename(certification_path.project.name + ' - ' + certification_path.name) + ' - ' + Time.new.strftime(I18n.t('time.formats.filename'))  + '.zip')

    # Create the archive directory
    FileUtils.mkdir_p(File.dirname(archive_path))

    # Clean up old archives
    cleanup_dir(File.dirname(archive_path), CLEAN_OLDER_THAN)

    # Create an empty archive
    Zip::File.open(archive_path, Zip::File::CREATE) do |archive|
      # Loop over all approved documents in the certification path
      certification_path.scheme_mix_criteria_documents.approved.each do |smcd|
        category_name = smcd.scheme_mix_criterion.scheme_criterion.scheme_category.name
        criterion_code = smcd.scheme_mix_criterion.scheme_criterion.code

        file_name = category_name + '/' + criterion_code + '/' + smcd.document.id.to_s + '_' + smcd.name
        file_path = smcd.path

        # Add the document to the archive
        archive.add(file_name, file_path)
      end
    end

    archive_path
  end

  # Creates a file archive of all user comments for a certification path
  def create_user_comments_archive(certification_path, temp_file)
    # Create the zipped output stream
    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry('user_comments.json')
      zos << '['
      first_object = true
      page = 0
      begin
        page += 1
        audit_logs = AuditLog
                         .where(project_id: certification_path.project.id, certification_path: certification_path)
                         .where.not(user_comment: nil).order(created_at: :DESC)
                         .paginate page: page, per_page: PAGE_SIZE
        audit_logs.each do |audit_log|
          zos << ',' unless first_object
          first_object = false
          zos << {timestamp: audit_log.created_at, user: audit_log.user.email, comment: audit_log.user_comment}.to_json
        end
      end while audit_logs.size == PAGE_SIZE
      zos << ']'
    end
    temp_file
  end

  private
  def cleanup_dir(path, older_than)
    Dir.glob("#{path}/*").each do |file|
      File.delete(file) if (File.mtime(file) < Time.now - older_than)
    end
  end

  def sanitize_filename(name)
    name.gsub!(/[^a-zA-Z0-9\.\-\+_ ]/, '_')
    name = "_#{name}" if name =~ /^\.+$/
    name
  end
end