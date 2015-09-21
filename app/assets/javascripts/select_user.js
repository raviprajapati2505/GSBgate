$(function () {
    var unauthorized_users_list = $('.select2-ajax[data-project-id]');
    if (unauthorized_users_list.length > 0) {
        unauthorized_users_list.select2({
            placeholder: "Type the first letters of the email address",
            width: "100%",
            ajax: {
                url: Routes.list_unauthorized_users_path({project_id: $('.select2-ajax').data('project-id')}),
                dataType: 'json',
                quietMillis: 250,
                data: function (term, page) {
                    return {
                        q: term,
                        page: page
                    };
                },
                results: function (data, page) {
                    var more = (page * 25) < data.total_count;
                    return {
                        results: data.items,
                        more: more
                    };
                },
                cache: false
            }
        });
    }

    var users_sharing_projects_list = $('.select2-ajax[data-user-id]');
    if (users_sharing_projects_list.length > 0) {
        users_sharing_projects_list.select2({
            placeholder: "Type the first letters of the email address",
            width: "100%",
            ajax: {
                url: Routes.list_users_sharing_projects_path({user_id: $('.select2-ajax').data('user-id')}),
                dataType: 'json',
                quietMillis: 250,
                data: function (term, page) {
                    return {
                        q: term,
                        page: page
                    };
                },
                results: function (data, page) {
                    var more = (page * 25) < data.total_count;
                    return {
                        results: data.items,
                        more: more
                    };
                },
                cache: false
            }
        });
    }
});