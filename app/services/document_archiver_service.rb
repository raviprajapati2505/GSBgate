class DocumentArchiverService
  include Singleton
  require 'zip'

  CLEAN_OLDER_THAN = 1.day
  PAGE_SIZE = 100

  # Creates a file archive of all approved documents in a certification path
  def create_archive(certification_path, temp_file)
    # Create the zipped output stream
    Zip::OutputStream.open(temp_file) do |zos|
      # Loop over all approved documents in the certification path
      certification_path.scheme_mix_criteria_documents.approved.each do |smcd|
        category_name = smcd.scheme_mix_criterion.scheme_criterion.scheme_category.name
        criterion_code = smcd.scheme_mix_criterion.scheme_criterion.code

        file_name = category_name + '/' + criterion_code + '/' + smcd.document.id.to_s + '_' + smcd.name
        file_path = smcd.path

        # Add the document to the archive
        zos.put_next_entry(file_name)
        zos << IO.read(file_path)
      end
    end

    # archive_path
    temp_file
  end

  # Creates a file archive of all user comments for a certification path
  def create_user_comments_archive(certification_path, temp_file)
    # Create the zipped output stream
    Zip::OutputStream.open(temp_file.path) do |zos|
      zos.put_next_entry('user_comments.csv')
      # CSV column headers
      zos << ['timestamp', 'user', 'comment'].to_csv
      page = 0
      begin
        page += 1
        audit_logs = AuditLog
                         .where(project_id: certification_path.project.id, certification_path: certification_path)
                         .where.not(user_comment: nil).order(created_at: :DESC)
                         .paginate page: page, per_page: PAGE_SIZE
        audit_logs.each do |audit_log|
          zos << [audit_log.created_at, audit_log.user.email, audit_log.user_comment].to_csv
        end
      end while audit_logs.size == PAGE_SIZE
    end
    temp_file
  end

end