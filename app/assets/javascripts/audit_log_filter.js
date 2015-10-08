$(function () {
    $('#_project_id').change(function () {
        if ($(this).val() == '') {
            $('#select-certificate').hide();
        }
        else {
            $('#select-certificate').show();
            return $.ajax({
                type: 'GET',
                url: Routes.list_project_certification_paths_path({project_id: $(this).val()}),
                dataType: 'json',
            }).done(function (data) {
                $('#select-certificate select').children('option:not(:first)').remove();
                $.each(data, function(name, id) {
                    $('#select-certificate select').append('<option value="' + id + '">' + name + '</option>');
                });
            });
        }
    });
});
