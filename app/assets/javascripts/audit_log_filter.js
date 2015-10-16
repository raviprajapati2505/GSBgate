$(function () {
    $('#_project_id').change(function () {
        if ($(this).val() == '') {
            $('#select-certificate').hide();
        }
        else {
            $('#select-certificate').show();
            var element = $('.select2-certificate-ajax');
            GSAS.load_list_ajax(element, '- All certificates -', Routes.list_project_certification_paths_path({project_id: $(this).val()}),
                function(el, callback) {
                    return $.ajax({
                        type: 'GET',
                        url: Routes.project_certification_path_path(element.val(), el.val()),
                        dataType: 'json'
                    }).done(function(data) {
                        selection = {id: data.id, text: data.name};
                        callback(selection);
                    })
                }
            );
        }
    });
    $('#_project_id').trigger('change');
});
