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

  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  def use_gmaps_for(filename)
    content_for(:js) do
      javascript_include_tag 'https://maps.google.com/maps/api/js?v=3&libraries=geometry',
                             'maps/_gmaps',
                             "maps/#{filename}"
    end
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
    btn_link_to(auditable_index_logs_path(auditable.class.name, auditable.id), disabling: false, remote: true, tooltip: 'View the complete audit log of this resource.', icon: 'mail-reply', size: 'extra_small', style: 'default', class: 'pull-right audit-log')
  end

  def btn_audit_log_comment(auditable)
    btn_link_to(auditable_index_comments_path(auditable.class.name, auditable.id), disabling: false, remote: true, tooltip: 'View or add comments to the audit log of this resource.', icon: 'comment', size: 'extra_small', style: 'default', class: 'audit-log pull-right')
  end

  def btn_audit_log_filtered(status_name, audit_log_params)
    btn_link_to(audit_logs_path(audit_log_params), tooltip: "Click to view the audit logs for all resources that were created during the '#{status_name}' phase.", icon: 'mail-reply-all', size: 'extra_small', style: 'default', class: 'pull-right audit-log')
  end

  def btn_audit_log_comments_filtered(status_name, audit_log_params)
    audit_log_params[:only_user_comments] = true
    btn_link_to(audit_logs_path(audit_log_params), tooltip: "Click to view the audit logs for all resources that were created during the '#{status_name}' phase.", icon: 'comments', size: 'extra_small', style: 'default', class: 'pull-right audit-log')
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
      else
        return breadcrumbs
    end

    if with_prefix
      if criterion.present?
        breadcrumbs[:names] << 'Criteria'
        breadcrumbs[:paths] << scheme_criteria_path
      else
        breadcrumbs[:names] << 'Projects'
        breadcrumbs[:paths] << projects_url
      end
    end
    if project.present?
      breadcrumbs[:names] << project.name
      breadcrumbs[:paths] << project_url(project)
    end
    if projects_user.present?
      breadcrumbs[:names] << projects_user.user.full_name
      breadcrumbs[:paths] << project_user_url(project, projects_user)
    end
    if certification_path.present?
      breadcrumbs[:names] << certification_path.name + ' (' + certification_path.status + ')'
      breadcrumbs[:paths] << project_certification_path_url(project, certification_path)
    end
    if scheme_mix.present?
      breadcrumbs[:names] << scheme_mix.full_name
      breadcrumbs[:paths] << project_certification_path_scheme_mix_url(project, certification_path, scheme_mix)
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
      breadcrumbs[:paths] << scheme_criterion_path(criterion)
    end
    if criterion_text.present?
      breadcrumbs[:names] << criterion_text.name
      if criterion_text.id.present?
        breadcrumbs[:paths] << edit_scheme_criterion_text_path(criterion_text)
      else
        breadcrumbs[:paths] << new_scheme_criterion_text_path(scheme_criterion: criterion)
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
    return breadcrumbs
  end

  def scores_legend
    max = content_tag(:li, ikoen_with_text('square', 'Max. Attainable score', class: 'progress-bar-max'))
    target = content_tag(:li, ikoen_with_text('square', 'Targeted score', class: 'progress-bar-targeted'))
    submit = content_tag(:li, ikoen_with_text('square', 'Submitted score', class: 'progress-bar-submitted'))
    achieved = content_tag(:li, ikoen_with_text('square', 'Achieved score', class: 'progress-bar-achieved'))
    content_tag(:ul, class: 'list-unstyled list-inline') do
      max + target + submit + achieved
    end
  end

  def icon_for_filename filename
    icon_for_ext File.extname(filename)
  end

  def icon_for_ext file_extension
    ext = file_extension.start_with?('.') ? file_extension[1..-1] : file_extension
    FILEICON_EXTENSIONS[ext.downcase] || 'fileicons/file_extension_unknown.png'
  end
end
