/**
 * Created by danielsb on 15/10/2015.
 */

$(function () {
    var projects_list = $('.select2-project-ajax');
    if (projects_list.length > 0) {
        GSB.load_list_ajax(projects_list, '- All projects -', Routes.list_projects_path(),
            function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.project_path({id: el.val()}),
                    dataType: 'json',
                    cache: false
                }).done(function(data) {
                    selection = {id: data.id, text: data.name};
                    callback(selection);
                });
            });
    }
});