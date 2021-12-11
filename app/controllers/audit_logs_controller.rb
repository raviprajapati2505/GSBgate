class AuditLogsController < AuthenticatedController
  require 'csv'

  before_action :set_auditable, except: [:index, :export, :unlink_smc_comments_form, :unlink_smc_comments]
  before_action :get_audit_log_associated_records, only: [:unlink_smc_comments_form, :unlink_smc_comments]
  load_and_authorize_resource

  def index
    @page_title = 'Audit log'

    @audit_logs = @audit_logs.includes(:user, :project)
    @certification_paths_optionlist = []
    empty_filters = {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'audit_log_type' => 'all'}

    if params[:reset].present?
      session[:audit] = empty_filters
    else
      if params[:button].present?
        session[:audit] = empty_filters
      else
        session[:audit] ||= empty_filters
      end

      session[:audit] = set_session_filters(session[:audit], params)
      @audit_logs = filter_audit_logs(@audit_logs, session[:audit])
    end

    @audit_logs = @audit_logs.page(params[:page]).per(12)
  end

  def export
    session[:audit] ||= EMPTY_FILTERS
    @audit_logs = @audit_logs.includes(:user, :project)
    @audit_logs = filter_audit_logs(@audit_logs, session[:audit])
    max_logs_to_export = 100000

    if @audit_logs.count > max_logs_to_export
      redirect_back(fallback_location: audit_logs_path, alert: "You have selected more than #{max_logs_to_export} audit logs. Please narrow your selection.")
    else
      # Generate CSV
      csv_string = CSV.generate(headers: true, col_sep: ';') do |csv|
        csv << ['Date/time', 'User', 'User comment', 'System message', 'Project', 'Certification']
        page = 0
        logs_per_page = 100
        begin
          page += 1
          audit_logs = @audit_logs.page(page).per(logs_per_page)
          audit_logs.each do |audit_log|
            csv << [audit_log.created_at, audit_log.user.full_name, audit_log.user_comment, ActionController::Base.helpers.strip_tags(audit_log.system_message), audit_log.project.present? ? "#{audit_log.project.name} (#{audit_log.project.code})" : '', audit_log.certification_path.present? ? audit_log.certification_path.name : '']
          end
        end while audit_logs.size == logs_per_page
      end

      send_data csv_string, filename: "audit_logs_export_#{Time.now.to_i}.csv"
    end
  end

  def auditable_index
    @project = @auditable.get_project
    projects_user = ProjectsUser.for_project(@auditable.get_project).for_user(current_user).first
    if projects_user.nil?
      @audit_logs = AuditLog.for_auditable(@auditable).page(params[:page]).per(6)
    elsif projects_user.gsas_trust_team?
      @audit_logs = AuditLog.for_auditable(@auditable).page(params[:page]).per(6)
    else
      @audit_logs = AuditLog.for_auditable(@auditable).where(audit_log_visibility_id: AuditLogVisibility::PUBLIC).page(params[:page]).per(6)
    end
    @only_user_comments = false
  end

  def auditable_index_comments
    @project = @auditable.get_project
    @is_certifier = false
    projects_user = ProjectsUser.for_project(@project).for_user(current_user).first
    if projects_user.nil?
      @audit_logs = AuditLog.for_auditable(@auditable).with_user_comment.page(params[:page]).per(6)
    elsif projects_user.gsas_trust_team?
      @audit_logs = AuditLog.for_auditable(@auditable).with_user_comment.page(params[:page]).per(6)
      @is_certifier = projects_user.certifier?
    else
      @audit_logs = AuditLog.for_auditable(@auditable).where(audit_log_visibility_id: AuditLogVisibility::PUBLIC).with_user_comment.page(params[:page]).per(6)
    end
    @only_user_comments = true
  end

  def auditable_create
    if params[:audit_log][:user_comment].present?
      @auditable = create_audit_logs(@auditable)

      if params[:scheme_mix_criteria].present?
        params[:scheme_mix_criteria].each do |smc_param|
          smc_id = smc_param[:scheme_mix_criterion_id].to_i rescue nil
          smc = SchemeMixCriterion.find(smc_id)
          create_audit_logs(smc)
        end
      end

      if @auditable.audit_log_errors.blank?
        redirect_back(fallback_location: root_path, notice: 'Your comment was successfully added to the audit log.')
      else
        @auditable.audit_log_errors.messages.each do |field, errors|
          redirect_back(fallback_location: root_path, alert: errors.first)
          return
        end
      end
    else
      redirect_back(fallback_location: root_path, alert: 'Please fill out the comment field.')
    end
  end

  def unlink_smc_comments_form    
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def unlink_smc_comments
    @certification_path = @scheme_mix&.certification_path
    @project = @certification_path&.project

    if params[:audit_logs].present?
      audit_logs_ids = @audit_logs&.ids
      params[:audit_logs].each { |al| audit_logs_ids.delete(al[:audit_log_id].to_i) }
      audit_logs_ids.delete(params[:audit_log_id].to_i)

      if AuditLog.where("id IN (?)", audit_logs_ids).destroy_all
        flash[:notice] = "Comments are successfully unlinked!"
      else
        flash[:alert] = "Comments are failed to unlink."
      end
    end

    redirect_back(fallback_location: project_certification_path_scheme_mix_scheme_mix_criterion_path(@project&.id, @certification_path&.id, @scheme_mix&.id, @auditable&.id))
  end

  def download_attachment
    begin
      send_file @audit_log.attachment_file.path, x_sendfile: false
    rescue ActionController::MissingFile
      redirect_back(fallback_location: root_path, alert: 'This document is no longer available for download. This could be due to a detection of malware.')
    end
  end

  private
  
  def set_auditable
    auditable_class = Object.const_get params[:auditable_type]
    @auditable = auditable_class.find(params[:auditable_id])

    #todo: check this with authorize!(auditable_index)
    unless auditable_class.included_modules.include?(Auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end

    unless can?(:read, @auditable)
      raise CanCan::AccessDenied.new('Not Authorized to read audit logs for this model.', :read, AuditLog)
    end
  end

  def create_audit_logs(auditable)
    return unless auditable.present?
    # auditable.audit_log.find_or_create_by(user_comment: params[:audit_log][:user_comment], attachment_file: params[:audit_log][:attachment_file], visibility: params[:audit_log][:audit_log_visibility])
    auditable.audit_log_user_comment = params[:audit_log][:user_comment]
    auditable.audit_log_attachment_file = params[:audit_log][:attachment_file]
    auditable.audit_log_visibility = params[:audit_log][:audit_log_visibility]
    auditable.touch

    return auditable
  end

  def get_audit_log_associated_records
    @audit_log = AuditLog.find(params[:audit_log_id])
    @auditable = @audit_log&.auditable
    @scheme_mix = @auditable&.scheme_mix

    @smc_categories = SchemeCategory.joins(scheme_criteria: [scheme_mix_criteria: :audit_logs]).where(audit_logs: {
      auditable_type: "SchemeMixCriterion",
      user_comment: @audit_log&.user_comment,
      project_id: @audit_log&.project_id,
      user_id: @audit_log&.user_id,
      certification_path_id: @audit_log&.certification_path_id}
    ).distinct

    @audit_logs = AuditLog.where(
      auditable_type: "SchemeMixCriterion",
      user_comment: @audit_log&.user_comment,
      project_id: @audit_log&.project_id,
      user_id: @audit_log&.user_id,
      certification_path_id: @audit_log&.certification_path_id
    ).distinct
  end

  def set_session_filters(session_filters, new_filters)
    # Text filter
    session_filters['text'] = new_filters[:text] if new_filters[:text].present?

    # User filter
    session_filters['user_id'] = new_filters[:user_id] if (new_filters[:user_id].present? && (new_filters[:user_id].to_i > 0))

    # Project filter
    session_filters['project_id'] = new_filters[:project_id] if (new_filters[:project_id].present? && (new_filters[:project_id].to_i > 0))

    # Certification path filter
    session_filters['certification_path_id'] = new_filters[:certification_path_id] if (new_filters[:certification_path_id].present? && (new_filters[:certification_path_id].to_i > 0))

    # Date from filter
    if new_filters[:date_from].present?
      session_filters['date_from'] = new_filters[:date_from]
      session_filters['time_from'] = new_filters[:time_from]
    end

    # Date to filter
    if new_filters[:date_to].present?
      session_filters['date_to'] = new_filters[:date_to]
      session_filters['time_to'] = new_filters[:time_to]
    end

    # Audit log type filter
    session_filters['audit_log_type'] = new_filters[:audit_log_type] if new_filters[:audit_log_type].present?

    session_filters
  end

  def filter_audit_logs(audit_logs, session_filters)
    # Text filter
    if session_filters['text'].present?
      audit_logs = audit_logs.where('(system_message ILIKE ?) OR (user_comment ILIKE ?)' , "%#{session_filters['text']}%", "%#{session_filters['text']}%")
    end

    # User filter
    if session_filters['user_id'].present?
      audit_logs = audit_logs.where(user_id: session_filters['user_id'].to_i)
    end

    # Project filter
    if session_filters['project_id'].present?
      audit_logs = audit_logs.where(project_id: session_filters['project_id'].to_i)
    end

    # Certification path filter
    if session_filters['certification_path_id'].present?
      audit_logs = audit_logs.where(certification_path_id: session_filters['certification_path_id'].to_i)
    end

    # Date from filter
    if session_filters['date_from'].present?
      begin
        audit_logs = audit_logs.where('audit_logs.created_at >= ?', DateTime.strptime(session_filters['date_from'] + ' ' + session_filters['time_from'] + ':00+03:00', t('time.formats.filter')).utc)
      rescue ArgumentError
        flash[:alert] = 'The date/time from fields contained invalid data.'
      end
    end

    # Date to filter
    if session_filters['date_to'].present?
      begin
        audit_logs = audit_logs.where('audit_logs.created_at <= ?', DateTime.strptime(session_filters['date_to'] + ' ' + session_filters['time_to'] + ':59+03:00', t('time.formats.filter')).utc)
      rescue ArgumentError
        flash[:alert] = 'The date/time to fields contained invalid data.'
      end
    end

    # Audit log type filter
    case session_filters['audit_log_type']
      when 'user_comment'
        audit_logs = audit_logs.where.not(user_comment: nil)
      when 'attachment'
        audit_logs = audit_logs.where.not(attachment_file: nil)
    end

    audit_logs
  end
end
