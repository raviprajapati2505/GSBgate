$(function() {

    $('.chosen-select').chosen({

    });

    $('#permissions-grid').dataTable({
        "columnDefs": [
            {"orderable": false, "targets": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] }
        ]
    });

    $('.manager-permission input').on('ifChecked', function() {
        var checkbox = $(this).closest('tr').children('.category-permission').find('input');
        checkbox.iCheck('disable');
        checkbox.iCheck('check');
    });
    $('.manager-permission input').on('ifUnchecked', function() {
        var checkbox = $(this).closest('tr').children('.category-permission').find('input');
        checkbox.iCheck('enable');
    });

    //$('.manager-permission input').change(function () {
    //    if ($(this).is(':checked'))
    //        $(this).closest('tr').children('.category-permission').children().prop('disabled', true).prop('checked', true);
    //    else
    //        $(this).closest('tr').children('.category-permission').children().prop('disabled', false);
    //});
});