/**
 * Created by DANIELSB on 27/10/2015.
 */

$(function () {
    setInterval(function() {
        refreshTaskCount();
    }, 60000);
});

function refreshTaskCount() {
    $('.task-counter').each(function() {
        var user_id = $(this).data('user');
        var project_id = $(this).data('project');
        if (!isNaN(user_id)) {
            if (!isNaN(project_id)) {
                var search = {user_id: user_id, project_id: project_id};
            } else {
                var search = {user_id: user_id};
            }
            $.ajax({
                url: Routes.count_tasks_path(search),
                method: 'GET',
                datatype: 'json',
                context: this
            }).done(function (count) {
                if (!isNaN(count)) {
                    $(this).text(count.toString());
                } else {
                    $(this).text('0');
                }
            });
        }
    });
}