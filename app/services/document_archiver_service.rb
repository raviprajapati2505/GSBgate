class DocumentArchiverService
  include Singleton
  require 'zip'

  # Creates a file archive of a list of SchemeMixCriteriaDocument models
  def create_archive(scheme_mix_criteria_documents)
    archive_path = 'private/archives/' + DateTime.now.to_i.to_s + '.zip'

    Zip::File.open(archive_path, Zip::File::CREATE) do |archive|
      scheme_mix_criteria_documents.each do |smcd|
        category_name = smcd.scheme_mix_criterion.scheme_criterion.criterion.category.name
        criterion_code = smcd.scheme_mix_criterion.scheme_criterion.code

        file_name = category_name + '/' + criterion_code + '/' + smcd.document.id.to_s + '_' + smcd.document.document_file.file.filename
        file_path = smcd.document.document_file.file.path

        archive.add(file_name, file_path)
      end
    end

    return archive_path
  end
end