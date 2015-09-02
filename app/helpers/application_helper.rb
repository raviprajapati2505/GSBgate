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
      ('<span class="tooltip-icon" data-toggle="tooltip" data-placement="top" title="' + title + '"><i class="fa fa-question-circle"></i></span>').html_safe
    end
  end

  def status_label(status, can_edit, modal)
    if can_edit
      ( '<a href="#" data-toggle="modal" data-target="#' + modal + '" title="Click to update the status" class="pull-right">'\
          '<span class="label label-lg status-' + status.dasherize + '">'\
            '<i class="fa fa-lg fa-edit"></i>&nbsp;Status: ' + status.humanize + ''\
          '</span>'\
        '</a>').html_safe
    else
      ( '<span class="label label-lg status-label status-' + status.dasherize + ' pull-right">'\
          'Status: ' + status.humanize + ''\
        '</span>').html_safe
    end
  end

  def audit_log_label(auditable)
    link_to('<span class="label label-lg"><i class="fa fa-lg fa-history"></i></span>'.html_safe, auditable_index_audit_logs_path(auditable.class.name, auditable.id), remote: true, title: 'Click to view the audit log of this item', class: 'pull-right')
  end

  def breadcrumbs(model, with_prefix: true)
    breadcrumbs = []

    case model.class.name
      when Project.name.demodulize
        project = model
      when ProjectAuthorization.name.demodulize
        project = model.project
        project_authorization = model
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
      else
        return breadcrumbs
    end

    if with_prefix
      breadcrumbs << link_to('Projects', projects_path)
    end
    if project.present?
      breadcrumbs << link_to(project.name, project_path(project))
    end
    if project_authorization.present?
      breadcrumbs << link_to(project_authorization.user.email, project_authorization_path(project_authorization))
    end
    if certification_path.present?
      breadcrumbs << link_to(certification_path.name, project_certification_path_path(project, certification_path))
    end
    if scheme_mix.present?
      breadcrumbs << link_to(scheme_mix.full_name, project_certification_path_scheme_mix_path(project, certification_path, scheme_mix))
    end
    if scheme_mix_criterion.present?
      breadcrumbs << link_to(scheme_mix_criterion.full_name, project_certification_path_scheme_mix_scheme_mix_criterion_path(project, certification_path, scheme_mix, scheme_mix_criterion))
    end
    if scheme_mix_criterion_document.present?
      breadcrumbs << link_to(scheme_mix_criterion_document.name, project_certification_path_scheme_mix_scheme_mix_criterion_scheme_mix_criteria_document_path(project, certification_path, scheme_mix, scheme_mix_criterion, scheme_mix_criterion_document))
    end

    return breadcrumbs
  end
end
