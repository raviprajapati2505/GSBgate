$(function () {
    var unauthorized_users_list = $('.select2-ajax[data-project-id]');
    if (unauthorized_users_list.length > 0) {
        element = unauthorized_users_list;
        url = Routes.list_unauthorized_users_path({project_id: $('.select2-ajax').data('project-id')});
    }

    var users_sharing_projects_list = $('.select2-ajax[data-current-user-id]');
    if (users_sharing_projects_list.length > 0) {
        element = users_sharing_projects_list;
        url = Routes.list_users_sharing_projects_path({user_id: $('.select2-ajax').data('current-user-id')});
    }

    if ((typeof element !== 'undefined') && (typeof url !== 'undefined')) {

        GSAS.load_list_ajax(element, '- All users -', url,
            function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.user_path({id: el.val()}),
                    dataType: 'json',
                    cache: false
                }).done(function(data) {
                    selection = {id: data.id, text: data.email};
                    callback(selection);
                });
            });
    }
});