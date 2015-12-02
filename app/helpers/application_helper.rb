module ApplicationHelper
  def is_active_controller(controller_name)
    params[:controller] == controller_name ? "active" : nil
  end

  def is_active_action(action_name)
    params[:action] == action_name ? "active" : nil
  end

  def use_gmaps_for(filename)
    content_for(:js) do
      javascript_include_tag 'https://maps.google.com/maps/api/js?v=3.13&sensor=false&libraries=geometry',
                             'https://google-maps-utility-library-v3.googlecode.com/svn/tags/markerclustererplus/2.0.14/src/markerclusterer_packed.js',
                             'maps/_gmaps',
                             "maps/#{filename}"
    end
  end

  def tooltip(title)
    if title.blank?
      ''
    else
      ("<span class=\"tooltip-icon\" data-toggle=\"tooltip\" data-placement=\"top\" title=\"#{title}\">#{fa_icon('question-circle', {size: 'sm'})}</span>").html_safe
    end
  end

  # Wraps the block param, with a link to th given path, if we have read access to the given model
  # If we do not have read access, just render the block
  def can_link_to(path, model, options = {})
    if can? :read, model
      link_to path, options do
        if block_given?
          capture do
            yield
          end
        end
      end
    else
      if block_given?
        capture do
          yield
        end
      end
    end
  end

  def fa_icon(name, text = nil, icon_options = nil)
    options = {size: 'lg'}
    options = options.merge(icon_options) if icon_options.present? && icon_options.is_a?(Hash)
    options = options.merge(text) if icon_options.nil? && text.is_a?(Hash)
    text_suffix= "&nbsp;&nbsp;&nbsp;#{text}" if text.is_a?(String)
    tooltip_attributes = "title=\"#{options[:tooltip]}\" data-toggle=\"tooltip\"" if options.has_key?(:tooltip)
    "<i class=\"fa fa-#{name} fa-#{options[:size]} #{options[:class]}\" #{tooltip_attributes}></i>#{text_suffix}".html_safe
  end

  def audit_log_label(auditable)
    if can?(:auditable_index, AuditLog) && can?(:read, auditable)
      link_to(auditable_index_audit_logs_path(auditable.class.name, auditable.id), remote: true, title: 'Click to view the audit log of this resource.', class: 'pull-right') {
        "<span class=\"label label-lg\">#{fa_icon('history')}</span>".html_safe
      }
    end
  end

  def round_score(score)
    score.round(3) if score.present?
  end

  def sum_score_hashes(score_hashes)
    score_hashes.inject(Hash.new()) { |total, score| total.merge(score) { |k, a, b| a + b } }
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
        category = criterion.scheme_category
        scheme = category.scheme
        certificate = scheme.certificate
      when SchemeCriterionText.name.demodulize
        criterion_text = model
        criterion = criterion_text.scheme_criterion
        category = criterion.scheme_category
        scheme = category.scheme
        certificate = scheme.certificate
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
      breadcrumbs[:names] << projects_user.user.email
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

    # Only used for mail
    if certificate.present?
      breadcrumbs[:names] << certificate.name
      breadcrumbs[:paths] << scheme_criteria_path() + '?certificate_id=' + certificate.id.to_s
      if scheme.present?
        breadcrumbs[:names] << scheme.name
        breadcrumbs[:paths] << scheme_criteria_path() + '?certificate_id=' + certificate.id.to_s + '&scheme_name=' + scheme.name
        if category.present?
          breadcrumbs[:names] << category.name
          breadcrumbs[:paths] << scheme_criteria_path() + '?certificate_id=' + certificate.id.to_s + '&scheme_name=' + scheme.name + '&category_name=' + category.name
          if criterion.present?
            breadcrumbs[:names] << criterion.full_name
            breadcrumbs[:paths] << scheme_criterion_path(criterion)
            if criterion_text.present?
              breadcrumbs[:names] << criterion_text.name
              if criterion_text.id.present?
                breadcrumbs[:paths] << edit_scheme_criterion_text_path(criterion_text)
              else
                breadcrumbs[:paths] << new_scheme_criterion_text_path(scheme_criterion: criterion)
              end
            end
          end
        end
      end
    end

    return breadcrumbs
  end

  def scores_legend
    legend = <<END
<ul class="list-unstyled list-inline">
  <li>#{fa_icon('square', 'Max. Attainable score', {class: 'progress-bar-max'})}</li>
  <li>#{fa_icon('square', 'Targeted score', {class: 'progress-bar-targeted'})}</li>
  <li>#{fa_icon('square', 'Submitted score', {class: 'progress-bar-submitted'})}</li>
  <li>#{fa_icon('square', 'Achieved score', {class: 'progress-bar-achieved'})}</li>
</ul>
END
    legend.html_safe
  end
end
