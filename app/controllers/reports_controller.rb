# PDF REPORT GENERATION IS DISABLED!
# To re-enable it:
#   - uncomment the routes in /config/routes.rb
#   - uncomment the download buttons in /app/views/certification_paths/show.html.erb
class ReportsController < ApplicationController
  load_and_authorize_resource :project
  load_and_authorize_resource :certification_path, :through => :project, :parent => false

  def download_certificate
    filepath = filepath_for_report 'Certificate'
    # if not File.exists?(filepath)
      report = Reports::CertificateReport.new(@certification_path)
      report.save_as(filepath)
    # end
    send_file filepath, :type => 'application/pdf', :x_sendfile => true
  end

  def download_certificate_coverletter
    filepath = filepath_for_report 'Cover Letter'
    # if not File.exists?(filepath)
      report = Reports::LetterOfConformanceCoverLetter.new(@certification_path)
      report.save_as(filepath)
    # end
    send_file filepath, :type => 'application/pdf', :x_sendfile => true
  end

  def download_certificate_scores
    filepath = filepath_for_report 'Criteria Score v2.1'
    # if not File.exists?(filepath)
      report = Reports::CriteriaScores.new(@certification_path)
      report.save_as(filepath)
    # end
    send_file filepath, :type => 'application/pdf', :x_sendfile => true
  end

  private

  def filepath_for_report(report_name)
    filename = "#{@certification_path.certificate.full_name} #{report_name}.pdf"
    Rails.root.join('private', 'projects', @certification_path.project.id.to_s, 'certification_paths', @certification_path.id.to_s, 'reports', filename)
  end

end