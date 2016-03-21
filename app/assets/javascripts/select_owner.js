/**
 * Created by danielsb on 21/03/2016.
 */

$(function() {
    $('.select2-ajax').each(function(idx, element) {
        $(this).on('change', function(e) {
            $('#project_owner').val($(this).select2('data').text);
        });
        var select_element = $(element);
        var url = Routes.owners_path();
        GSAS.load_list_ajax(select_element, '- Select a predefined property owner -', url,
            function(el, callback) {
                return $.ajax({
                    type: 'GET',
                    url: Routes.owner_path({id: el.val()}),
                    dataType: 'json',
                    cache: false
                }).done(function(data) {
                    selection = {id: data.id, text: data.name};
                    callback(selection);
                });
            }
        );
    });
});