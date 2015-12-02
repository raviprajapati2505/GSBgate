/**
 * Created by DANIELSB on 5/11/2015.
 */
$(function () {
    $('#_certification_path_id').change(function () {
        $('.select2-criterion-ajax').val('');
        refresh_criterion_list($('#_project_id').val(), $(this).val());
    });
    refresh_criterion_list($('#_project_id').val(), $('#_certification_path_id').val());
});

function refresh_criterion_list(project_id, certification_path_id) {
    if (project_id == '' || certification_path_id == '') {
        $('#select-criterion').hide();
    }
    else {
        $('#select-criterion').show();
        var element = $('.select2-criterion-ajax');
        GSAS.load_list_ajax(element, '- All criteria -', Routes.list_project_certification_path_scheme_mix_criteria_path({project_id: project_id, certification_path_id: certification_path_id}),
            function(el, callback) {
                ids = el.val() != null ? el.val().split(';') : [null,null];
                return $.ajax({
                    type: 'GET',
                    url: Routes.project_certification_path_scheme_mix_scheme_mix_criterion_path(project_id, certification_path_id, ids[0], ids[1]),
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