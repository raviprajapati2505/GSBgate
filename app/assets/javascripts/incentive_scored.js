$(function() {
    $('.achieved_score_row select').on('change', function(eventObject) {
        index = $(this).data('index');
        element = $('.achieved_score_dependent_checkbox input[data-index=' + index + ']');
        if ($(this).val() > 0) {
            $(element).iCheck('enable').removeAttr('readonly');
        } else {
            $(element).iCheck('disable').attr('readonly', 'readonly').iCheck('uncheck');
            name = $(element).attr('name');
            $('input[type=hidden][name="' + name + '"]').val(0);
        }
    });
});