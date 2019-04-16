class Archive < ActiveRecord::Base
  require 'zip'
  require 'csv'

  STORE_DIR = 'private/archives'
  PAGE_SIZE = 100
  CSV_COL_SEPARATOR = ';'

  enum status: { not_generated: 10, generating: 20, generated: 30 }

  belongs_to :subject, polymorphic: true
  belongs_to :user

  def archive_path
    # "#{ENV['SHARED_PATH']}/#{Archive::STORE_DIR}/#{archive_file}"
    "#{File.realpath(Archive::STORE_DIR)}/#{archive_file}"
  end

  def generate!
    raise 'The archive is already being generated.' if generating?
    raise 'The archive is already generated.' if generated?
    raise 'The archive has no subject.' if subject.nil?
    raise 'The archive has no user.' if user.nil?

    generating!

    case subject.class.name.demodulize
      when CertificationPath.name.demodulize
        genereate_certification_path_archive
      when SchemeMixCriterion.name.demodulize
        create_scheme_mix_criterion_archive
    end

    save!
    generated!
  end

  private

  def init
    if self.has_attribute?(:status)
      self.status ||= :not_generated
    end
  end

  def sanitize_filename(name)
    name.gsub!(/[^a-zA-Z0-9\.\-\+_ ]/, '_')
    name = "_#{name}" if name =~ /^\.+$/
    name
  end

  # Creates a file archive of all approved documents in a certification path and related audit logs
  def genereate_certification_path_archive
    certification_path = subject
    zip_name = DateTime.now.strftime('%Y%m%d_%H%M') + '_' + user.id.to_s + '_' + certification_path.id.to_s + '_' + sanitize_filename(certification_path.project.name + '_' + certification_path.name) + '.zip'
    zip_path = "#{Rails.root.to_s}/#{Archive::STORE_DIR}/#{zip_name}"
    csv_path = "#{Rails.root.to_s}/tmp/audit_logs_#{user.id.to_s}_#{certification_path.id}_#{DateTime.now.to_i}.csv"

    # Create the audit logs CSV
    CSV.open(csv_path, 'wb', col_sep: CSV_COL_SEPARATOR) do |csv|
      # CSV column headers
      csv << ['Date/time', 'User', 'User comment', 'System message']
      page = 0
      begin
        page += 1
        audit_logs = AuditLog
                       .where(project_id: certification_path.project.id)
                       .where('audit_logs.certification_path_id = ? OR audit_logs.certification_path_id IS NULL', certification_path.id)
                       .order(created_at: :asc)
                       .page(page).per(PAGE_SIZE)
        audit_logs.each do |audit_log|
          csv << [audit_log.created_at, audit_log.user.full_name, audit_log.user_comment, ActionController::Base.helpers.strip_tags(audit_log.system_message)]
        end
      end while audit_logs.size == PAGE_SIZE
    end

    # Create the ZIP archive
    Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
      # Add the audit logs CSV
      zip.add('audit_logs.csv', csv_path)

      # Loop over all approved documents in the certification path
      certification_path.scheme_mix_criteria_documents.approved.each do |smcd|
        if smcd.document.document_file.present?
          category_name = smcd.scheme_mix_criterion.scheme_criterion.scheme_category.name
          criterion_code = smcd.scheme_mix_criterion.scheme_criterion.code

          file_name = category_name + '/' + criterion_code + '/' + smcd.document.id.to_s + '_' + smcd.name
          file_path = smcd.path

          # Add the document to the archive
          zip.add(file_name, file_path)
        end
      end

      # Loop over all CGP documents in the certification path
      certification_path.cgp_certification_path_documents.each do |ccpd|
        if ccpd.document_file.present?
          file_name = ccpd.id.to_s + '_' + ccpd.name
          file_path = ccpd.path

          # Add the document to the archive
          zip.add(file_name, file_path)
        end
      end

      # Loop over all Certifier documents in the certification path
      certification_path.certifier_certification_path_documents.each do |ccpd|
        if ccpd.document_file.present?
          file_name = ccpd.id.to_s + '_' + ccpd.name
          file_path = ccpd.path

          # Add the document to the archive
          zip.add(file_name, file_path)
        end
      end
    end

    # Clean up the temporary CSV file
    File.delete(csv_path)

    self.archive_file = zip_name
  end

  # Creates a file archive of all approved documents in a scheme mix criterion
  def create_scheme_mix_criterion_archive
    scheme_mix_criterion = subject
    zip_name = DateTime.now.strftime('%Y%m%d_%H%M') + '_' + user.id.to_s + '_' + scheme_mix_criterion.id.to_s + '_' + sanitize_filename(scheme_mix_criterion.name) + '.zip'
    zip_path = "#{Rails.root.to_s}/#{Archive::STORE_DIR}/#{zip_name}"

    # Create the zipped output stream
    Zip::File.open(zip_path, Zip::File::CREATE) do |zip|
      # Loop over all approved documents in the scheme mix criterion
      scheme_mix_criterion.scheme_mix_criteria_documents.approved.each do |smcd|
        if smcd.document.document_file.present?
          file_name = smcd.document.id.to_s + '_' + smcd.name
          file_path = smcd.path

          # Add the document to the archive
          zip.add(file_name, file_path)
        end
      end
    end

    self.archive_file = zip_name
  end
end
