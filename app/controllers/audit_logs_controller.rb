class AuditLogsController < AuthenticatedController
  before_action :set_auditable, except: [:index]
  load_and_authorize_resource

  def index
    @page_title = 'Audit log'

    @audit_logs = @audit_logs.includes(:user, :project)
    @certification_paths_optionlist = []

    if params[:reset].present?
      session[:audit] = {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'audit_log_type' => 'all'}
    else

      if params[:button].present?
        session[:audit] = {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'audit_log_type' => 'all'}
      else
        session[:audit] ||= {'text' => nil, 'user_id' => nil, 'project_id' => nil, 'certification_path_id' => nil, 'date_from' => '', 'time_from' => '0:00', 'date_to' => '', 'time_to' => '0:00', 'audit_log_type' => 'all'}
      end

      # Text filter
      if params[:text].present?
        session[:audit]['text'] = params[:text]
      end
      if session[:audit]['text'].present?
        @audit_logs = @audit_logs.where('(system_message ILIKE ?) OR (user_comment ILIKE ?)' , "%#{session[:audit]['text']}%", "%#{session[:audit]['text']}%")
      end

      # User filter
      if params[:user_id].present? && (params[:user_id].to_i > 0)
        session[:audit]['user_id'] = params[:user_id]
      end
      if session[:audit]['user_id'].present?
        @audit_logs = @audit_logs.where(user_id: session[:audit]['user_id'].to_i)
      end

      # Project filter
      if params[:project_id].present? && (params[:project_id].to_i > 0)
        session[:audit]['project_id'] = params[:project_id]
      end
      if session[:audit]['project_id'].present?
        @audit_logs = @audit_logs.where(project_id: session[:audit]['project_id'].to_i)
      end

      # Certification path filter
      if params[:certification_path_id].present? && (params[:certification_path_id].to_i > 0)
        session[:audit]['certification_path_id'] = params[:certification_path_id]
      end
      if session[:audit]['certification_path_id'].present?
        @audit_logs = @audit_logs.where(certification_path_id: session[:audit]['certification_path_id'].to_i)
      end

      # Date from filter
      if params[:date_from].present?
        session[:audit]['date_from'] = params[:date_from]
        session[:audit]['time_from'] = params[:time_from]
      end
      if session[:audit]['date_from'].present?
        begin
          @audit_logs = @audit_logs.where('audit_logs.created_at >= ?', DateTime.strptime(session[:audit]['date_from'] + ' ' + session[:audit]['time_from'] + ':00+03:00', t('time.formats.filter')).utc)
        rescue ArgumentError
          flash[:alert] = 'The date/time from fields contained invalid data.'
        end
      end

      # Date to filter
      if params[:date_to].present?
        session[:audit]['date_to'] = params[:date_to]
        session[:audit]['time_to'] = params[:time_to]
      end
      if session[:audit]['date_to'].present?
        begin
          @audit_logs = @audit_logs.where('audit_logs.created_at <= ?', DateTime.strptime(session[:audit]['date_to'] + ' ' + session[:audit]['time_to'] + ':59+03:00', t('time.formats.filter')).utc)
        rescue ArgumentError
          flash[:alert] = 'The date/time to fields contained invalid data.'
        end
      end

      # Audit log type filter
      session[:audit]['audit_log_type'] = params[:audit_log_type] if params[:audit_log_type].present?
      case session[:audit]['audit_log_type']
        when 'user_comment'
          @audit_logs = @audit_logs.where.not(user_comment: nil)
        when 'attachment'
          @audit_logs = @audit_logs.where.not(attachment_file: nil)
      end
    end

    @audit_logs = @audit_logs.page(params[:page]).per(12)
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
      @auditable.audit_log_user_comment = params[:audit_log][:user_comment]
      @auditable.audit_log_attachment_file = params[:audit_log][:attachment_file]
      @auditable.audit_log_visibility = params[:audit_log][:audit_log_visibility]
      @auditable.touch

      if @auditable.audit_log_errors.blank?
        redirect_to :back, notice: 'Your comment was successfully added to the audit log.'
      else
        @auditable.audit_log_errors.messages.each do |field, errors|
          redirect_to :back, alert: errors.first
          return
        end
      end
    else
      redirect_to :back, alert: 'Please fill out the comment field.'
    end
  end

  def download_attachment
    begin
      send_file @audit_log.attachment_file.path
    rescue ActionController::MissingFile
      redirect_to :back, alert: 'This document is no longer available for download. This could be due to a detection of malware.'
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
end
