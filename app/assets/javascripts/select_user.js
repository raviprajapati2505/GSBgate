$(function () {

    $('.select2-ajax').each(function (idx, element) {
        var select_element = $(element);
        var url;
        if (typeof select_element.data('current-user-id') !== undefined) {
            var user_id = select_element.data('current-user-id');
            url = Routes.list_users_sharing_projects_path({user_id: user_id});
        }
        if (url) {
            GSB.load_list_ajax(select_element, '- All users -', url,
                function (el, callback) {
                    return $.ajax({
                        type: 'GET',
                        url: Routes.user_path({id: el.val()}),
                        dataType: 'json',
                        cache: false
                    }).done(function (data) {
                        selection = {id: data.id, text: data.name};
                        callback(selection);
                    });
                }
            );
        }
    });
});