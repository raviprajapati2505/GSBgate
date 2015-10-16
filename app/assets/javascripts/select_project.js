/**
 * Created by danielsb on 15/10/2015.
 */

$(function () {
    var projects_list = $('.select2-project-ajax');
    if (projects_list.length > 0) {
        projects_list.select2({
            allowClear: true,
            placeholder: "project name",
            width: "100%",
            ajax: {
                url: Routes.list_projects_path(),
                dataType: 'json',
                quietMillis: 250,
                data: function (term, page) {
                    return {
                        q: term,
                        page: page,
                    };
                },
                results: function (data, page) {
                    var more = (page * 2) < data.total_count;
                    return {
                        results: data.items,
                        more: more
                    };
                },
                cache: false
            },
            initSelection: function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.project_path({id: el.val()}),
                    dataType: 'json',
                }).done(function(data) {
                    selection = {id: data.id, text: data.name};
                    callback(selection);
                });
            }
        });
    }
});