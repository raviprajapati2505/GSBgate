module ApplicationHelper
  FILEICON_EXTENSIONS = %w{
    3gp 7z ace ai aif aiff amr asf asx bat bin bmp bup cab cbr cda cdl cdr chm
    dat divx dll dmg doc docx dss dvf dwg eml eps exe fla flv gif gz hqx htm html
    ifo indd iso jar jpeg jpg lnk log m4a m4b m4p m4v mcd mdb mid mov mp2 mp4
    mpeg mpg msi mswmm ogg pdf png pps ppsx ppt pptx ps psd pst ptb pub qbb qbw qxd ram
    rar rm rmvb rtf sea ses sit sitx ss swf tgz thm tif tmp torrent ttf txt
    vcd vob wav wma wmv wps xls xlsx xpi zip
    }.inject({}) do |fileicon_extensions, ext|
    fileicon_extensions[ext] = "fileicons/file_extension_#{ext}.png"
    fileicon_extensions
  end
  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Context

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  def use_gmaps_for(filename)
    content_for(:js) do
      javascript_include_tag 'https://maps.google.com/maps/api/js?key=AIzaSyAvI5XlSDeGPFPWoSiqDybgoDUD17cg3Q0&v=3&libraries=geometry',
                             'maps/_gmaps',
                             "maps/#{filename}"
    end
  end

  # Filter schemes which is only for checklist
  def manage_schemes_options(certification_path, assessment_method)
    schemes = certification_path&.development_type&.schemes&.select("DISTINCT ON (schemes.name) schemes.*")

#    unless current_user.is_system_admin?
      # exclude schemes which were renamed.
#      if assessment_method == 1 && current_user.service_provider.present?
#        allowed_schemes = current_user.valid_user_sp_licences.pluck(:schemes).flatten.uniq
#        schemes = schemes.where("schemes.name IN (:allowed_schemes)", allowed_schemes: allowed_schemes)
#      end
#    end

    if assessment_method == 1 && current_user.service_provider.present?
      schemes_with_only_checklist = ["Energy Centers"]
      schemes = schemes&.where.not(name: schemes_with_only_checklist)
    end

    return schemes
  end

  def tooltip(text, data_options = {})
    ikoen('question-circle', size: :normal, tooltip: text, data: data_options, class: 'tooltip-icon')
  end

  # Wraps the block param, with a link to th given path, if we have read access to the given model
  # If we do not have read access, just render the block
  def can_link_to(path, model, options = {})
    _content = capture do
      yield
    end if block_given?
    if can? :read, model
      return link_to path, options do
        _content
      end
    else
      return _content
    end
  end

  def audit_log_label(auditable)
    if can?(:auditable_index, AuditLog) && can?(:read, auditable)
      btn_audit_log(auditable) + btn_audit_log_comment(auditable)
    end
  end

  def btn_audit_log(auditable)
    btn_link_to(auditable_index_logs_path(auditable.class.name, auditable.id), disabling: false, remote: true, tooltip: 'View the complete audit log of this resource.', icon: 'mail-reply', size: 'extra_small', style: 'primary', class: 'pull-right audit-log')
  end

  def btn_audit_log_comment(auditable)
    btn_link_to(auditable_index_comments_path(auditable.class.name, auditable.id), disabling: false, remote: true, tooltip: 'View or add comments to the audit log of this resource.', icon: 'comment', size: 'extra_small', style: 'primary', class: 'audit-log pull-right')
  end

  def btn_audit_log_filtered(status_name, audit_log_params)
    btn_link_to(audit_logs_path(audit_log_params), tooltip: "Click to view the audit logs for all resources that were created during the '#{status_name}' phase.", icon: 'mail-reply-all', size: 'extra_small', style: 'primary', class: 'pull-right audit-log')
  end

  def btn_audit_log_comments_filtered(status_name, audit_log_params)
    audit_log_params[:only_user_comments] = true
    btn_link_to(audit_logs_path(audit_log_params), tooltip: "Click to view the audit logs for all resources that were created during the '#{status_name}' phase.", icon: 'comments', size: 'extra_small', style: 'primary', class: 'pull-right audit-log')
  end

  # generates a button_tag with save icon and save text, that can be used within forms
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_save(options = {}, &block)
    btn_tag({icon: 'save', text: 'Save'}.merge(options), &block)
  end

  # generates a button_tag to dismiss a modal, with only a small close icon
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_close_modal(options = {}, &block)
    btn_tag({class: 'close', icon: 'times', size: 'extra_small', style: 'white', data: {dismiss: 'modal'}, aria: {label: 'close'}}.merge(options), &block)
  end

  # generates a button link to the target, with a cancel icon and text
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_cancel_to(target, options = {}, &block)
    btn_link_to(target, {icon: 'times', text: 'Cancel', style: 'white'}.merge(options), &block)
  end

  # generates a button link to the target, with only a download icon
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_download(target, options = {}, &block)
    btn_link_to(target, {icon: 'download', disabling: false}.merge(options), &block)
  end

  # generates a button_tag
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_tag(options = {}, &block)
    btn_component(:button, options, &block)
  end

  # generates a button link
  #
  # :options: are documented at ApplicationHelper#btn_component
  def btn_link_to(target, options = {}, &block)
    btn_component(:link, {target: target}.merge(options), &block)
  end

  def btn_link_to_if(permission: false, target: '', icon: '', text: '')
    if permission
      btn_link_to(target, icon: icon, text: text)
    end
  end

  # generates a component with bootstrap button classes added to it
  # - receives a disabled-with attribute, to avoid double click issues
  # - uses default values for style and size
  # - optionally can be given a fontawesome icon name
  # - optionally can be given a text or content block
  # - supports all default available attributes for the component (e.g. value, remote, data, ....)
  #
  # :component_type: should be either :button or :link
  # :options: a hash to configure the button
  # * :style a bootstrap button style
  #   * primary (default)
  #   * white
  #   * danger
  #   * ...
  #
  # * :size the size of the button
  #   * normal (default)
  #   * large
  #   * small
  #   * extra_small
  #
  # * :tooltip a bootstrap tooltip to add to the button
  #   when using the tooltip attribute, you cannot explicitly add a title or data-toggle attribute
  #
  # * :icon the fontawesome icon name, without the 'fa-' prefix
  #
  # * :icon_position the fontawesome icon position
  #   * front (default)
  #   * back
  #
  # * :disabling the component will disable other links and buttons during submit, and render itself using a processing mode (using ujs)
  #   * true (default)
  #   * false
  #
  # * :text the text for the button
  #   The button contents can also be passed in as a block
  #
  def btn_component(component_type, options = {}, &block)
    # -- style
    options[:style] ||= 'primary'
    _btn_style = "btn-#{options[:style]}"
    # -- size
    options[:size] ||= 'normal'
    _btn_size = '' if options[:size] == 'normal'
    _btn_size = 'btn-lg' if options[:size] == 'large'
    _btn_size = 'btn-sm' if options[:size] == 'small'
    _btn_size = 'btn-xs' if options[:size] == 'extra_small'
    # -- icon size
    _icon_size = 'normal' if options[:size] == 'small'
    _icon_size = 'normal' if options[:size] == 'extra_small'
    _icon_size ||= 'lg'
    # -- icon position
    options[:icon_position] ||= 'front'
    # -- toolip
    if options.has_key?(:tooltip)
      if options.has_key?(:title) || (options.has_key?(:data) && options[:data].has_key?(:toggle))
        logger.fatal('btn_component: tooltip was not set, because a title or data-toggle attribute was also given')
      else
        options[:title] = options[:tooltip]
        options[:data] ||= {}
        options[:data][:toggle] = 'tooltip'
      end
    end

    # Construct button content
    _content = []
    # -- text
    _content << options[:text] if options.has_key?(:text)
    # -- block
    _content << capture do
      yield
    end if block_given?
    # -- icon
    if options.has_key?(:icon)
      _icon = ikoen(options[:icon], size: _icon_size)
      if options[:icon_position] == 'front'
        _content.unshift(_icon)
      else
        _content << _icon
      end
    end

    # Convert array to space delimited string
    _content = _content.join('&nbsp;&nbsp;')

    # Add the button classes
    options[:class] ||= ''
    options[:class] << " btn #{_btn_style} #{_btn_size}"
    options[:class] = options[:class].split(' ').uniq.join(' ')

    # Add the data classes
    options[:data] ||= {}
    options[:disabling] = true unless options.has_key?(:disabling)
    # -- during 'processing', show the content prefixed with a spinner
    options[:data][:disable_with] ||= "#{ikoen('spinner fa-spin', size: _icon_size)}&nbsp;&nbsp;#{_content}" if options[:disabling] == true

    # Create the options hash to pass to the default url or form helper
    _options = options.except(:icon, :icon_position, :style, :size, :tooltip, :disabling)

    # component_type
    if component_type == :link
      # raise ('test')
      return link_to options[:target], _options.except(:target) do
        _content.html_safe
      end
    end
    if component_type == :button
      return button_tag _options do
        _content.html_safe
      end
    end
  end

  def ikoen_with_text(name, text, options = {})
    "#{ikoen(name, options)}&nbsp;&nbsp;#{text}".html_safe
  end

  def label_span(value = false, label_true = true, label_false = false)
    label = value ? label_true : label_false
    "<span class='label label-rating #{label_class(value)}'>#{label.to_s.titleize}</span>"
  end

  def label_class(value = false)
    value ? 'label-success' : 'label-danger' 
  end

  def commify_values(value)
    value = value.present? ? value&.to_s&.split(/(?=(?:\d{3})+$)/)&.join(",") : ""
    return value
  end

  def is_gsas_trust?(user = nil)
    return false unless user.present?
    ["gsas_trust_admin", "gsas_trust_top_manager", "gsas_trust_manager", "system_admin"].include?(current_user&.role)
  end

  def is_certification_manager?(projects_users, user)
    return false unless (user.present? || projects_users.present?)
    certification_managers_ids = projects_users&.where(role: "certification_manager").pluck(:user_id)
    return certification_managers_ids&.include?(user.id)
  end

  def ikoen(name, options = {})
    # -- size
    options[:size] ||= 'lg'
    _icon_size = " fa-#{options[:size]}" unless options[:size] == 'normal'
    # -- toolip
    if options.has_key?(:tooltip)
      if options.has_key?(:title) || (options.has_key?(:data) && options[:data].has_key?(:toggle))
        logger.fatal('btn_component: tooltip was not set, because a title or data-toggle attribute was also given')
      else
        options[:title] = options[:tooltip]
        options[:data] ||= {}
        options[:data][:toggle] = 'tooltip'
        options[:data][:html] = 'true'
      end
    end
    # -- class
    options[:class] ||= ''
    options[:class] << " fa fa-#{name}"
    options[:class] << _icon_size if _icon_size.present?
    options[:class] = options[:class].split(' ').uniq.join(' ')
    # remove handled attributes
    _options = options.except(:size, :tooltip)
    content_tag(:i, nil, _options)
  end

  def round_score(score)
    score.round(3) if score.present?
  end

  def sum_score_hashes(score_hashes)
    # create a result hash, using the same keys as the input hashes, but with zero values
    total_score = score_hashes[0].dup
    total_score.each{|k,v| total_score[k]=0}
    # Sum the input hashes
    score_hashes.inject(total_score) { |total, score|
      total.each{|k,v|
        # if any input has a nil for a given key, the sum shall be nil also !!
        if (total[k].nil? || score[k].nil?)
          total[k] = nil
        else
          total[k] = total[k] + score[k]
        end
      }
    }
  end

  def breadcrumbs(model, with_prefix: true)
    breadcrumbs = {names: [], paths: []}
    case model.class.name
      when Project.name.demodulize
        project = model
      when 'Offline::Project'
        offline_project = model
      when 'Offline::CertificationPath'
        offline_project = model.offline_project
        offline_certification_path = model
      when 'Offline::SchemeMix'
        offline_project = model.offline_certification_path.offline_project
        offline_certification_path = model.offline_certification_path
        offline_scheme_mix = model
      when ProjectsUser.name.demodulize
        project = model.project
        projects_user = model
      when CertificationPath.name.demodulize
        project = model.project
        certification_path = model
      when SchemeMix.name.demodulize
        project = model.certification_path.project
        certification_path = model.certification_path
        scheme_mix = model
      when SchemeMixCriterion.name.demodulize
        project = model.scheme_mix.certification_path.project
        certification_path = model.scheme_mix.certification_path
        scheme_mix = model.scheme_mix
        scheme_mix_criterion = model
      when SchemeMixCriteriaDocument.name.demodulize
        project = model.scheme_mix_criterion.scheme_mix.certification_path.project
        certification_path = model.scheme_mix_criterion.scheme_mix.certification_path
        scheme_mix = model.scheme_mix_criterion.scheme_mix
        scheme_mix_criterion = model.scheme_mix_criterion
        scheme_mix_criterion_document = model
      when SchemeMixCriterionIncentive.name.demodulize
        project = model.scheme_mix_criterion.scheme_mix.certification_path.project
        certification_path = model.scheme_mix_criterion.scheme_mix.certification_path
        scheme_mix = model.scheme_mix_criterion.scheme_mix
        scheme_mix_criterion = model.scheme_mix_criterion
      when SchemeMixCriterionEpl.name.demodulize
        project = model.scheme_mix_criterion.scheme_mix.certification_path.project
        certification_path = model.scheme_mix_criterion.scheme_mix.certification_path
        scheme_mix = model.scheme_mix_criterion.scheme_mix
        scheme_mix_criterion = model.scheme_mix_criterion
      when SchemeMixCriterionWpl.name.demodulize
        project = model.scheme_mix_criterion.scheme_mix.certification_path.project
        certification_path = model.scheme_mix_criterion.scheme_mix.certification_path
        scheme_mix = model.scheme_mix_criterion.scheme_mix
        scheme_mix_criterion = model.scheme_mix_criterion
      when RequirementDatum.name.demodulize
        project = model.scheme_mix_criteria.take.scheme_mix.certification_path.project
        certification_path = model.scheme_mix_criteria.take.scheme_mix.certification_path
        scheme_mix = model.scheme_mix_criteria.take.scheme_mix
        scheme_mix_criterion = model.scheme_mix_criteria.take
        requirement_datum = model
      when SchemeCriterion.name.demodulize
        criterion = model
        # category = criterion.scheme_category
        # scheme = category.scheme
      when SchemeCriterionText.name.demodulize
        criterion_text = model
        # criterion = criterion_text.scheme_criterion
        # category = criterion.scheme_category
        # scheme = category.scheme
      when CgpCertificationPathDocument.name.demodulize
        certification_path = model.certification_path
        project = certification_path.project
        certification_path_document = model
      when CertifierCertificationPathDocument.name.demodulize
        certification_path = model.certification_path
        project = certification_path.project
        certification_path_document = model
      when User.name.demodulize, ServiceProvider.name.demodulize
        user = model
      when SurveyType.name.demodulize
        survey_type = model
      when SurveyQuestionnaireVersion.name.demodulize
        survey_type = model.survey_type
        survey_questionnaire_version = model
      when ProjectsSurvey.name.demodulize
        project = model.project
        projects_survey = model
      else
        return breadcrumbs
    end

    if with_prefix
      if user.present?
        breadcrumbs[:names] << 'Users'
        breadcrumbs[:paths] << users_path
      elsif criterion.present?
        breadcrumbs[:names] << 'Criteria'
        breadcrumbs[:paths] << scheme_criteria_url
      elsif survey_type.present?
        breadcrumbs[:names] << 'Survey Types'
        breadcrumbs[:paths] << survey_types_path
      elsif offline_project.present?
        breadcrumbs[:names] << 'Offline Projects'
        breadcrumbs[:paths] << offline_projects_path
      else
        breadcrumbs[:names] << 'Projects'
        breadcrumbs[:paths] << projects_url
      end
    end

    if project.present?
      breadcrumbs[:names] << project.name
      breadcrumbs[:paths] << project_url(project)
    end
    if offline_project.present?
      breadcrumbs[:names] << offline_project.name
      breadcrumbs[:paths] << offline_project_path(offline_project)
    end
    if offline_certification_path.present?
      breadcrumbs[:names] << offline_certification_path.name
      breadcrumbs[:paths] << offline_project_certification_path(offline_project, offline_certification_path)
    end
    if projects_user.present?
      breadcrumbs[:names] << projects_user.user.full_name
      breadcrumbs[:paths] << project_user_url(project, projects_user)
    end
    if certification_path.present?
      breadcrumbs[:names] << certification_path.certificate.stage_title + ' (' + certification_path.status + ')'
      breadcrumbs[:paths] << project_certification_path_url(project, certification_path)
    end
    if scheme_mix.present?
      breadcrumbs[:names] << scheme_mix.full_name
      breadcrumbs[:paths] << project_certification_path_scheme_mix_url(project, certification_path, scheme_mix)
    end
    if offline_scheme_mix.present?
      breadcrumbs[:names] << offline_scheme_mix.name
      breadcrumbs[:paths] << offline_project_certification_scheme_path(offline_project, offline_certification_path, offline_scheme_mix)
    end
    if requirement_datum.present?
      breadcrumbs[:names] << scheme_mix_criterion.full_name
      breadcrumbs[:paths] << project_certification_path_scheme_mix_scheme_mix_criterion_url(project, certification_path, scheme_mix, scheme_mix_criterion) + '#requirement-' + requirement_datum.id.to_s
    elsif scheme_mix_criterion.present?
      breadcrumbs[:names] << scheme_mix_criterion.full_name
      breadcrumbs[:paths] << project_certification_path_scheme_mix_scheme_mix_criterion_url(project, certification_path, scheme_mix, scheme_mix_criterion)
    end
    if scheme_mix_criterion_document.present?
      breadcrumbs[:names] << scheme_mix_criterion_document.name
      breadcrumbs[:paths] << project_certification_path_scheme_mix_scheme_mix_criterion_url(project, certification_path, scheme_mix, scheme_mix_criterion) + '#documentation'
    end
    if criterion.present?
      breadcrumbs[:names] << criterion.full_name
      breadcrumbs[:paths] << scheme_criterion_url(criterion)
    end
    if criterion_text.present?
      breadcrumbs[:names] << criterion_text.name
      if criterion_text.id.present?
        breadcrumbs[:paths] << edit_scheme_criterion_text_url(criterion_text)
      else
        breadcrumbs[:paths] << new_scheme_criterion_text_url(scheme_criterion: criterion)
      end
    end
    if certification_path_document.present?
      breadcrumbs[:names] << certification_path_document.name
      case model.class.name
        when CgpCertificationPathDocument.name.demodulize
          breadcrumbs[:paths] << project_certification_path_url(project, certification_path) + '#cgp-documentation'
        when CertifierCertificationPathDocument.name.demodulize
          breadcrumbs[:paths] << project_certification_path_url(project, certification_path) + '#certifier-documentation'
      end
    end
    if user.present?
      breadcrumbs[:names] << user.email
      breadcrumbs[:paths] << user_path(user)
    end
    if survey_type.present?
      breadcrumbs[:names] << survey_type.title
      breadcrumbs[:paths] << survey_type_path(survey_type)
    end
    if survey_questionnaire_version.present?
      breadcrumbs[:names] << "v#{survey_questionnaire_version.version}"
      breadcrumbs[:paths] << survey_type_survey_questionnaire_version_path(survey_type, survey_questionnaire_version)
    end
    return breadcrumbs
  end

  def scores_legend
    max = content_tag(:li, ikoen_with_text('square', 'Max. Attainable', class: 'progress-bar-max'))
    target = content_tag(:li, ikoen_with_text('square', 'Targeted', class: 'progress-bar-targeted'))
    submit = content_tag(:li, ikoen_with_text('square', 'Submitted', class: 'progress-bar-submitted'))
    achieved = content_tag(:li, ikoen_with_text('square', 'Achieved', class: 'progress-bar-achieved'))
    content_tag(:ul, class: 'list-unstyled list-inline') do
      max + target + submit + achieved
    end
  end

  def icon_for_filename filename
    icon_for_ext File.extname(filename) rescue ""
  end

  def icon_for_ext file_extension
    ext = file_extension.start_with?('.') ? file_extension[1..-1] : file_extension
    FILEICON_EXTENSIONS[ext.downcase] || 'fileicons/file_extension_unknown.png'
  end

  def can_update_smc_scores(scheme_mix_criterion)
    can?(:update_targeted_score, @scheme_mix_criterion) || can?(:update_submitted_score, @scheme_mix_criterion) || can?(:update_achieved_score, @scheme_mix_criterion) rescue false
  end

  def certification_assessment_type_title(assessment_type = nil)
    if assessment_type == 1
      "Star Rating Assessment"
    elsif assessment_type == 2
      "Checklist Assessment"
    end
  end

  def licence_options(user = nil)
    return [] unless user.present?
  
    user.remaining_licences.pluck(:display_name, :id)
  end

  def total_CM_score(data)
    final_score = {}
    data.each do |stage|
      final_score = final_score.merge(stage){ |k, final_value, score_value| final_value + score_value }
    end
    final_score.each do |k,v|
      final_score[k] = v / 3.0
    end

    return final_score
  end

  def score_calculation(scheme_mix)
    @project ||= scheme_mix&.certification_path&.project

    # fetch all score records
    @scheme_mix_criteria_scores = scheme_mix&.scheme_mix_criteria_scores
    # check for criteria that violate their minimum_valid_score
    @invalid_criteria_ids = @scheme_mix_criteria_scores
        .select {|score| score[:achieved_score_in_criteria_points].nil? && score[:minimum_valid_score_in_criteria_points] > score[:minimum_score_in_criteria_points] }
        .map{|score| score[:scheme_mix_criteria_id]}
    # group by category
    @scheme_mix_criteria_scores_by_category = @scheme_mix_criteria_scores.group_by{|item| item[:scheme_category_id]}
    # calculate the max and min values for each category, and take the max min of those calculated values
    @scheme_scale = {
        maximum_scale_in_certificate_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:maximum_score_in_certificate_points]}.inject(:+)}.max,
        minimum_scale_in_certificate_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:minimum_score_in_certificate_points]}.inject(:+)}.min,
        maximum_scale_in_scheme_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:maximum_score_in_scheme_points]}.inject(:+)}.max,
        minimum_scale_in_scheme_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:minimum_score_in_scheme_points]}.inject(:+)}.min,
        maximum_scale_in_criteria_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:maximum_score_in_criteria_points]}.inject(:+)}.max,
        minimum_scale_in_criteria_points: @scheme_mix_criteria_scores_by_category.collect{|category_id, scores| scores.collect{|score| score[:minimum_score_in_criteria_points]}.inject(:+)}.min
    }
    @total_scores = scheme_mix.scores

    if scheme_mix.CM_2019? && scheme_mix.certification_path.certification_path_status.name != "Activating"
      @category_w = scheme_mix.scheme_categories.find_by(name: "Water")
      if @category_w
        criteria_w = @category_w&.scheme_mix_criteria
        data = @scheme_mix_criteria_scores_by_category[@category_w&.id]
        @score_data = []
        original_w_scores = sum_score_hashes(data)
        data.each do |d|
          scheme_mix_criterion = SchemeMixCriterion.find(d[:scheme_mix_criteria_id])
          if scheme_mix_criterion.code == 'W.1'
            scheme_mix_criteria_score_w = @scheme_mix_criteria_scores.find{|item| item[:scheme_mix_criteria_id] == scheme_mix_criterion.id }
            # scheme_mix_criteria_score = scheme_mix_criteria_score.merge(category_scale)
            smc_weight_a = scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[0])
            smc_weight_b = scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[1])
                                        
            scheme_mix_criteria_score_for_w_1 = calculate_average(scheme_mix_criterion, scheme_mix_criteria_score_w, smc_weight_a, smc_weight_b)
                      
            @score_data << scheme_mix_criteria_score_for_w_1
          else
            @score_data << d
          end  
        end
        @score_data.each do |s| 
          s.each do |k, v|
            s[k] = v.nil? ? 0 : v 
          end
        end
        modified_scores = sum_score_hashes(@score_data)
        @category_scores_w = modified_scores.merge(@scheme_scale)

        original_w_scores.each { |k, v| original_w_scores[k] = (v == nil) ? 0 : v }
        @total_scores.each { |k, v| @total_scores[k] = (v == nil) ? 0 : v }
        @total_scores.each do |k, v|
          @total_scores[k] = @total_scores[k] + modified_scores[k] - original_w_scores[k]
        end
      end
    end

    return @total_scores
  end

  # to manipulate scores of  E1, W1, M1, M3 and MO1 in final cm certification.
  def final_cm_revised_avg_scores(certification_path, total_scores)
    if certification_path.present? && certification_path&.final_construction? && certification_path&.certificate&.construction_2019? && !certification_path.is_activating?
      project = certification_path&.project

      scheme_categories_names = ["Energy", "Water", "Materials", "Management & Operations", "Management And Operations"]
      
      # CM Stage 3 records

      # scheme mix of all stages.
      cm_stage_1_sm = SchemeMix.joins(certification_path: [:project, :certificate]).find_by("certificates.certification_type = :certification_type AND projects.id = :project_id", certification_type: Certificate.certification_types["construction_certificate_stage1"], project_id: project&.id)
      cm_stage_2_sm = SchemeMix.joins(certification_path: [:project, :certificate]).find_by("certificates.certification_type = :certification_type AND projects.id = :project_id", certification_type: Certificate.certification_types["construction_certificate_stage2"], project_id: project&.id)
      cm_stage_3_sm = SchemeMix.joins(certification_path: [:project, :certificate]).find_by("certificates.certification_type = :certification_type AND projects.id = :project_id", certification_type: Certificate.certification_types["construction_certificate_stage3"], project_id: project&.id)

      # stages sm scores
      cm_stage_1_sm_scores = cm_stage_1_sm&.scheme_mix_criteria_scores
      cm_stage_2_sm_scores = cm_stage_2_sm&.scheme_mix_criteria_scores
      cm_stage_3_sm_scores = cm_stage_3_sm&.scheme_mix_criteria_scores

      scheme_categories_names.each do |scheme_category_name|
        scheme_criteria_names = get_scheme_criteria_names(scheme_category_name)

        scheme_criteria_names.each do |scheme_criterion_name|
          cm_stage_1_required_smc_criterion = SchemeMixCriterion.joins([scheme_mix: [certification_path: :certificate]], scheme_criterion: :scheme_category).find_by("scheme_mixes.id = :scheme_mix_id AND scheme_categories.name = :category_name AND scheme_criteria.name = :scheme_criterion_name AND certificates.certification_type = :certification_type", scheme_mix_id: cm_stage_1_sm&.id, category_name: scheme_category_name, scheme_criterion_name: scheme_criterion_name, certification_type: Certificate.certification_types["construction_certificate_stage1"])

          cm_stage_2_required_smc_criterion = SchemeMixCriterion.joins([scheme_mix: [certification_path: :certificate]], scheme_criterion: :scheme_category).find_by("scheme_mixes.id = :scheme_mix_id AND scheme_categories.name = :category_name AND scheme_criteria.name = :scheme_criterion_name AND certificates.certification_type = :certification_type", scheme_mix_id: cm_stage_2_sm&.id, category_name: scheme_category_name, scheme_criterion_name: scheme_criterion_name, certification_type: Certificate.certification_types["construction_certificate_stage2"])

          cm_stage_3_required_smc_criterion = SchemeMixCriterion.joins([scheme_mix: [certification_path: :certificate]], scheme_criterion: :scheme_category).find_by("scheme_mixes.id = :scheme_mix_id AND scheme_categories.name = :category_name AND scheme_criteria.name = :scheme_criterion_name AND certificates.certification_type = :certification_type", scheme_mix_id: cm_stage_3_sm&.id, category_name: scheme_category_name, scheme_criterion_name: scheme_criterion_name, certification_type: Certificate.certification_types["construction_certificate_stage3"])

          if (cm_stage_1_required_smc_criterion.present? && cm_stage_2_required_smc_criterion.present? && cm_stage_3_required_smc_criterion.present?)

            cm_stage_1_smc_scores = cm_stage_1_sm_scores.find{|item| item[:scheme_mix_criteria_id] == cm_stage_1_required_smc_criterion.id }
            cm_stage_2_smc_scores = cm_stage_2_sm_scores.find{|item| item[:scheme_mix_criteria_id] == cm_stage_2_required_smc_criterion.id }
            cm_stage_3_smc_scores = cm_stage_3_sm_scores.find{|item| item[:scheme_mix_criteria_id] == cm_stage_3_required_smc_criterion.id }

            keys_of_required_scores = total_scores&.select { |key, value| key.to_s.match(/achieved_score/) }.keys

            if scheme_category_name == 'Water' && cm_stage_3_required_smc_criterion&.scheme_criterion&.number == 1 && certification_path.construction_certificate_CM_2019?
              manipulated_cm_stage_1_smc_scores = cm_2019_w1_scores_manipulation(cm_stage_1_required_smc_criterion, cm_stage_1_sm_scores)
              manipulated_cm_stage_2_smc_scores = cm_2019_w1_scores_manipulation(cm_stage_2_required_smc_criterion, cm_stage_2_sm_scores)
              manipulated_cm_stage_3_smc_scores = cm_2019_w1_scores_manipulation(cm_stage_3_required_smc_criterion, cm_stage_3_sm_scores)

              # keys_of_required_scores.each do |k|
              #   total_scores[k] = total_scores[k].to_f - (cm_stage_3_smc_scores[k].to_f + cm_stage_2_smc_scores[k].to_f + cm_stage_1_smc_scores[k].to_f) / 3 if total_scores[k].present?
              # end

              cm_stage_1_smc_scores.each do |k, v|
                cm_stage_1_smc_scores[k] = manipulated_cm_stage_1_smc_scores[k].to_f
              end

              cm_stage_2_smc_scores.each do |k, v|
                cm_stage_2_smc_scores[k] = manipulated_cm_stage_2_smc_scores[k].to_f
              end

              cm_stage_3_smc_scores.each do |k, v|
                cm_stage_3_smc_scores[k] = manipulated_cm_stage_3_smc_scores[k].to_f
              end

              keys_of_required_scores.each do |k|
                total_scores[k] = total_scores[k].to_f + (2*cm_stage_3_smc_scores[k].to_f - (cm_stage_2_smc_scores[k].to_f + cm_stage_1_smc_scores[k].to_f)) / 3 if total_scores[k].present?
              end
            else
             
              keys_of_required_scores.each do |k|
                total_scores[k] = total_scores[k].to_f + (2*cm_stage_3_smc_scores[k].to_f - (cm_stage_2_smc_scores[k].to_f + cm_stage_1_smc_scores[k].to_f)) / 3 if total_scores[k].present?
              end
            end
          end
        end
      end
    end
    
    return total_scores
  end

  def calculate_average(scheme_mix_criteria, scheme_mix_criteria_score, smc_weight_a, smc_weight_b)

    match_total = {}
    smc_weight_a = (smc_weight_a == nil || smc_weight_a == 0) ? 1 : smc_weight_a
    smc_weight_b = (smc_weight_b == nil || smc_weight_b == 0) ? 1 : smc_weight_b

    scheme_mix_criteria_score.each do |k, v|
      v = (v == nil) ? 0 : v

      if k.to_s.include?('_a_')
        key = k.to_s.sub! '_a_', '_b_'
        value = scheme_mix_criteria_score[key.to_sym]
        value = (value == nil) ? 0 : value

        total_score = (v / smc_weight_a) + (value / smc_weight_b)
        total_value = v + value
        if (k.to_s.include?('in_criteria_points') && total_value > 0)
          total_value = (total_value / 2.0).round.to_f
        else
          total_value = ((total_score / 2.0).round(2)) * (smc_weight_a + smc_weight_b)
          scheme_mix_criteria.scheme_mix_criterion_incentives.where(incentive_scored: true).each do |smci|
            incentive_weight = (smci.scheme_criterion_incentive.incentive_weight * 3.0) / 100
            total_value += incentive_weight
          end if ( k.to_s.include?('targeted_score_') || k.to_s.include?('submitted_score_') || k.to_s.include?('achieved_score_') || k.to_s.include?('maximum_score_'))
        end

        main_key = k.to_s.split('_a_').join('_')
        match_total.merge!("#{main_key.to_sym}": total_value)

        match_total.merge!("#{k}": total_value)
        match_total.merge!("#{key.to_sym}": 0.0)

        match_total.each_pair do |k1, v1|
          scheme_mix_criteria_score[k1] = v1
        end
      end
    end
    return scheme_mix_criteria_score
  end

  def merge_incentives(scheme_mix_criterion)
    return (scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[0]) + scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[1]))
  end

  def set_project_country_location(project)
    @city_options = [["Other, Please indicate", "Other"]]
    @is_city_predefined = true
    if project.persisted?
      locations = Location.find_by_country(project&.country)&.list
      if (locations.present? && locations&.include?(project&.city))
        @city_options = locations.map{ |loc| [loc, loc] }.push(["Other, Please indicate", "Other"])
      else
        @is_city_predefined = false
      end
    end
  end

  def set_project_district(project)
    @district_options = [["Other, Please indicate", "Other"]]
    @is_district_predefined = true
    if project.persisted?
      districts = District.find_by_country(project&.country)&.list
      if (districts.present? && districts&.include?(project&.district))
        @district_options = districts.map{ |dis| [dis, dis] }.push(["Other, Please indicate", "Other"])
      else
        @is_district_predefined = false
      end
    end
  end

  def projects_users_count_with_role(project_users, role)
    project_users&.with_role(role)&.count
  end

  def find_rowspan(project_user_count = 0)
    project_user_count += 1
  end

  def cm_2019_w1_scores_manipulation(scheme_mix_criterion, cm_2019_w1_scores)
    scheme_mix_criteria_score_w = cm_2019_w1_scores.find{|item| item[:scheme_mix_criteria_id] == scheme_mix_criterion.id }

    smc_weight_a = scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[0])
    smc_weight_b = scheme_mix_criterion.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[1])

    scheme_mix_criteria_score_for_w1 = calculate_average(scheme_mix_criterion, scheme_mix_criteria_score_w, smc_weight_a, smc_weight_b)

    return scheme_mix_criteria_score_for_w1
  end

  def get_certificate_types_names(user)
    certificate_types_name = Certificate.all.order(:display_weight).map { |certificate| [certificate.stage_title, certificate.stage_title&.delete(",")] }
    
    if user.is_admin?
      certificate_types_name.push(["Recent Stages", "Recent Stages"])
    end

    return certificate_types_name.uniq
  end

  def get_scheme_criteria_names(category_name)
    case category_name
    when 'Energy'
      # for Energy Use - Temporary Buildings
      return ['Energy Use - Temporary Buildings']

    when 'Water'
      #for Domestic Water Use 
      return ['Domestic Water Use']

    when 'Materials'
      # for Materials Diversion from Landfill & Cut & Fill Optimization
      return ['Materials Diversion from Landfill', 'Cut & Fill Optimization']

    when 'Management & Operations', 'Management And Operations'
      # for Waste Management
      return ['Waste Management']
      
    else
      return []
    end
  end

  def get_schemes_names
    # scheme_name = Scheme.pluck(:name).uniq
    # scheme_name.delete("Core + Shell")
    # scheme_name.push("Mixed Use")

    scheme_name = [
      "Commercial",
      "Education",
      "Homes",
      "Hospitality",
      "Interiors",
      "Light Industry",
      "Mosques",
      "Offices",
      "Residential",
      "Workers Accomodation",
      "Energy Centers",
      "Healthcare",
      "Railways",
      "Sports",
      "Districts",
      "Parks",
      "Mixed Use",
      "Neighborhoods",
      "Construction Site",
      "Energy Neutral Mark",
      "Healthy Building Mark",
      "Premium Scheme",
      "Standard Scheme"
    ]

    return scheme_name
  end

  def check_documents_permissions(user_role: nil, project: nil)
    if ["default_role", "record_checker"].exclude?(user_role)
      true
    elsif project.present?
      project.check_documents_permissions
    else
      false
    end
  end
  
  # survey module

  def survey_question_options_report(projects_survey, question)
    option_with_counts = {}

    question.question_options.each.with_index(1) do |option, i|
      option_text = option.option_text

      option_wise_counts = 
        question.
        question_responses.
        with_project_survey(projects_survey.id).
        where("question_responses.value LIKE :value", value: "%#{option_text}%").
        count || 0

      option_with_counts[option_text] = option_wise_counts
    end

    return option_with_counts
  end

  def set_visibility(question_type = '')
    ["fill_in_the_blank"].include?(question_type) ? 'd-none' : ''
  end

  def certification_name_datatable_render(rec, only_certification_name)
    case only_certification_name
      when 'GSAS-D&B'
        '<span class="certi-name-badge badge-db">'+ image_tag('/icons/certi-name-db.png') +'</span><a href='+Rails.application.routes.url_helpers.project_certification_path_path(rec.project_nr, rec.certification_path_id)+'>'+only_certification_name+'</a>'
      when 'GSAS-CM'
        '<span class="certi-name-badge badge-cm">'+ image_tag('/icons/certi-name-cm.png') +'</span><a href='+Rails.application.routes.url_helpers.project_certification_path_path(rec.project_nr, rec.certification_path_id)+'>'+only_certification_name+'</a>'
      when 'GSAS-OP'
        '<span class="certi-name-badge badge-op">'+ image_tag('/icons/certi-name-op.png') +'</span><a href='+Rails.application.routes.url_helpers.project_certification_path_path(rec.project_nr, rec.certification_path_id)+'>'+only_certification_name+'</a>'
    end
  end

  def submission_status_datatable_render(rec)
    only_certification_name = Certificate.find_by_name(rec&.certificate_name)&.only_certification_name
    if rec.certification_path_status_name == "Certificate In Process"
      status = CertificationPath.find(rec&.certification_path_id)&.status
    else
      status = rec.certification_path_status_name
    end
    case only_certification_name
      when 'GSAS-D&B'
        '<span class="certi-sub-status-badge status-badge-db">'+ image_tag('/icons/certi-sub-status-db.png') +'</span>'+status
      when 'GSAS-CM'
        '<span class="certi-sub-status-badge status-badge-cm">'+ image_tag('/icons/certi-sub-status-cm.png') +'</span>'+status
      when 'GSAS-OP'
        '<span class="certi-sub-status-badge status-badge-op">'+ image_tag('/icons/certi-sub-status-op.png') +'</span>'+status
    end
  end

  def certification_name_offline_datatable_render(certification_type)
    case certification_type
      when 'GSAS-D&B'
        '<span class="certi-name-badge badge-db">'+ image_tag('/icons/certi-name-db.png') +'</span>'+certification_type
      when 'GSAS-CM'
        '<span class="certi-name-badge badge-cm">'+ image_tag('/icons/certi-name-cm.png') +'</span>'+certification_type
      when 'GSAS-OP'
        '<span class="certi-name-badge badge-op">'+ image_tag('/icons/certi-name-op.png') +'</span>'+certification_type
    end
  end

  def submission_status_offline_datatable_render(rec)
    only_certification_name = rec.certificate_type
    case only_certification_name
      when 'GSAS-D&B'
        '<span class="certi-sub-status-badge status-badge-db">'+ image_tag('/icons/certi-sub-status-db.png') +'</span>'+rec.certification_status
      when 'GSAS-CM'
        '<span class="certi-sub-status-badge status-badge-cm">'+ image_tag('/icons/certi-sub-status-cm.png') +'</span>'+rec.certification_status
      when 'GSAS-OP'
        '<span class="certi-sub-status-badge status-badge-op"'+ image_tag('/icons/certi-sub-status-op.png') +'</span>'+rec.certification_status
    end
  end

  FONTS_DIR = "/app/assets/fonts/reports"
  IMAGES_DIR = "/app/assets/images/reports/"
 
  def newline(amount = 1)
    text "\n" * amount
  end

  def font_path(filename)
    "#{Rails.root}#{FONTS_DIR}/#{filename}"
  end

  def image_path(filename)
    "#{Rails.root}#{IMAGES_DIR}/#{filename}"
  end

  def save_as(file_name)
    FileUtils.mkdir_p(File.dirname(file_name))
    document.render_file(file_name)
  end

  def projects_users_by_type(team_type)
    case team_type
    when 'project_team'
      "ARRAY_TO_STRING(ARRAY(SELECT project_team_users.name FROM users as project_team_users INNER JOIN projects_users as project_team_project_users ON project_team_project_users.user_id = project_team_users.id  WHERE project_team_project_users.role IN (#{ProjectsUser.roles[:project_team_member]}) AND project_team_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE project_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
    when 'cgp_project_manager'
      "ARRAY_TO_STRING(ARRAY(SELECT cgp_project_managers.name FROM users as cgp_project_managers INNER JOIN projects_users as cgp_project_managers_project_users ON cgp_project_managers_project_users.user_id = cgp_project_managers.id  WHERE cgp_project_managers_project_users.role IN (#{ProjectsUser.roles[:cgp_project_manager]}) AND cgp_project_managers_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE cgp_project_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
    when 'gsas_trust_team'
      "ARRAY_TO_STRING(ARRAY(SELECT gsas_trust_team_users.name FROM users as gsas_trust_team_users INNER JOIN projects_users as gsas_trust_team_project_users ON gsas_trust_team_project_users.user_id = gsas_trust_team_users.id  WHERE gsas_trust_team_project_users.role IN (#{ProjectsUser.roles[:certifier]}) AND gsas_trust_team_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE gsas_trust_team_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
    when 'certification_manager'
      "ARRAY_TO_STRING(ARRAY(SELECT certification_managers.name FROM users as certification_managers INNER JOIN projects_users as certification_managers_project_users ON certification_managers_project_users.user_id = certification_managers.id  WHERE certification_managers_project_users.role IN (#{ProjectsUser.roles[:certification_manager]}) AND certification_managers_project_users.project_id = projects.id AND (SELECT CASE WHEN certificates.certification_type IN (#{Certificate.certification_types['construction_certificate']}, #{Certificate.certification_types['operations_certificate']}, #{Certificate.certification_types['construction_certificate_stage1']}, #{Certificate.certification_types['construction_certificate_stage2']}, #{Certificate.certification_types['construction_certificate_stage3']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['letter_of_conformance']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}) WHEN certificates.certification_type IN (#{Certificate.certification_types['final_design_certificate']}) THEN certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Final Design Certificate']}) ELSE certification_managers_project_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}, #{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) END)), '|||')"
    when 'enterprise_clients'
      "ARRAY_TO_STRING(ARRAY(SELECT enterprise_client_users.name FROM users as enterprise_client_users INNER JOIN projects_users as enterprise_client_project_users ON enterprise_client_project_users.user_id = enterprise_client_users.id  WHERE enterprise_client_project_users.role IN (#{ProjectsUser.roles[:enterprise_client]}) AND enterprise_client_project_users.project_id = projects.id), '|||')"
    end
  end
end
