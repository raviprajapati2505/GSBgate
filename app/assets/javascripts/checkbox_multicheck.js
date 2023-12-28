$(function () {
    // Check all children
    $('.checkbox_parent').on('ifChecked', function() {
        $('.checkbox_child_' + $(this).val()).iCheck('check');
    });

    // Uncheck all children
    $('.checkbox_parent').on('ifUnchecked', function() {
        $('.checkbox_child_' + $(this).val()).iCheck('uncheck');
    });
});