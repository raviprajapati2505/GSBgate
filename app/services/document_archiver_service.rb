class DocumentArchiverService
  include Singleton
  require 'zip'
  require 'csv'

  PAGE_SIZE = 100

  # Creates a file archive of all approved documents in a certification path and related audit logs
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

      zos.put_next_entry('audit_logs.csv')
      # CSV column headers
      zos << ['timestamp', 'user', 'user_comment', 'system_message'].to_csv
      page = 0
      begin
        page += 1
        audit_logs = AuditLog
                         .where(project_id: certification_path.project.id)
                         .where('audit_logs.certification_path_id = ? or audit_logs.certification_path_id is null', certification_path.id)
                         .order(created_at: :ASC)
                         .paginate page: page, per_page: PAGE_SIZE
        audit_logs.each do |audit_log|
          zos << [audit_log.created_at, audit_log.user.email, audit_log.user_comment, audit_log.system_message].to_csv
        end
      end while audit_logs.size == PAGE_SIZE
    end

    temp_file
  end

end