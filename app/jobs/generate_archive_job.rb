class GenerateArchiveJob < ActiveJob::Base
  queue_as :default

  def perform(archive)
    archive.generate!
    DigestMailer.archive_created_email(archive).deliver_now
  end
end
