$(function() {
    $('.manager-permission input').change(function () {
        if ($(this).is(':checked'))
            $(this).closest('tr').children('.category-permission').children().prop('disabled', true).prop('checked', true);
        else
            $(this).closest('tr').children('.category-permission').children().prop('disabled', false);
    });
});