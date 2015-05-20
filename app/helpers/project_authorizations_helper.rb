
module ProjectAuthorizationsHelper

  def get_permission(project_id, user_id, category_id, manager)
    permission = ProjectAuthorization.find_by(project_id: project_id, user_id: user_id, category_id: category_id)
    name = "permission[#{user_id}][#{category_id}]"
    if manager
      disabled = 'disabled=\"disabled"'
      checked = 'checked=\"checked\"'
    else
      unless permission.nil? || !permission.read_and_write?
        checked = 'checked=\"checked\"'
      end
    end
    return "<input type=\"checkbox\" name=\"#{name}\" #{checked} #{disabled}>".html_safe
  end

  def get_project_manager_permission(user_id, manager)
    name = "permission[#{user_id}][pm]"
    if manager
      checked = 'checked=\"checked\"'
    end
    return "<input type=\"checkbox\" name=\"#{name}\" #{checked}>".html_safe
  end

  def is_project_manager(project_id, user_id)
    permission = ProjectAuthorization.find_by(project_id: project_id, user_id: user_id, category_id: nil)
    return permission.manage?
  end

end