/**
 * Created by danielsb on 16/10/2015.
 */

$(function () {
    var project_team_member_list = $('.select2-project-team-member');
    if (project_team_member_list.length > 0) {
        GSAS.load_list(project_team_member_list, '- Unassigned -');
    }
});