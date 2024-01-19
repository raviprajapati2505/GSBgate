$(function () {
    $('#project_id').change(function () {
        $('.select2-certificate-ajax').val('');
        refresh_certification_list($(this).val());
    });
    refresh_certification_list($('#project_id').val());
});

function refresh_certification_list(project_id) {
    if (project_id == '') {
        $('#select-certificate').hide();
    }
    else {
        $('#select-certificate').show();
        var element = $('.select2-certificate-ajax');
        GSB.load_list_ajax(element, '- All certificates -', Routes.list_project_certification_paths_path(project_id),
            function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.project_certification_path_path(project_id, el.val()),
                    dataType: 'json',
                    cache: false
                }).done(function(data) {
                    selection = {id: data.id, text: data.name};
                    callback(selection);
                });
            }
        );
    }
}