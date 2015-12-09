$(function () {

    $('.select2-ajax').each(function(idx, element){
        var select_element = $(element);
        var url;
        if((typeof select_element.data('project-id') !== 'undefined') && (typeof select_element.data('role') !== 'undefined')){
            var project_id = select_element.data('project-id');
            var role = select_element.data('role');
            url = Routes.available_project_users_path({project_id: project_id, role: role});
        }else if(typeof select_element.data('current-user-id') !== undefined){
            var user_id = select_element.data('current-user-id');
            url = Routes.list_users_sharing_projects_path({user_id: user_id});
        }
        if(url){
            GSAS.load_list_ajax(select_element, '- All users -', url,
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
                }
            );
        }
    });
});