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
      ( '<span class="label status-label status-' + status.dasherize + ' pull-right">'\
          'Status: ' + status.humanize + ''\
        '</span>').html_safe
    end
  end

  def audit_log_label(auditable)
    link_to('<span class="label label-lg"><i class="fa fa-lg fa-history"></i></span>'.html_safe, auditable_index_audit_logs_path(auditable.class.name, auditable.id), remote: true, title: 'Click to view the audit log of this page', class: 'pull-right')
  end
end
