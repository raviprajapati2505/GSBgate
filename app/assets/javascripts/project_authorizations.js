$(function() {

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