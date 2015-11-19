/**
 * Created by danielsb on 18/11/2015.
 */

$(function() {
    var user_id = $('#user_id').val();
    $('#project_id').change(function() {
        $('#checkbox-list-notification-types .icheckbox_square-green input[type=checkbox]').iCheck('check');
        refresh_notification_list(user_id, $(this).val());
    });
    refresh_notification_list(user_id, $('#project_id').val());
});

function refresh_notification_list(user_id, project_id) {
    if (project_id == '') {
        $('#checkbox-list-notification-types').hide();
    }
    else {
        $.ajax({
            type: 'GET',
            url: Routes.list_notifications_user_path(user_id, {project_id: project_id}),
            dataType: 'json'
        }).done(function(data) {
            $.each(data, function(index, value) {
                $('#checkbox-list-notification-types .icheckbox_square-green input[type=checkbox][value=' + value.id + ']').iCheck('uncheck');
            });
            $('#checkbox-list-notification-types').show();
        });
    }
}