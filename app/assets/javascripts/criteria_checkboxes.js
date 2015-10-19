$(function() {
    // Handle select criteria button click
    $('.show-criteria-checkboxes').click(function(e) {
        $(this).siblings('.criteria-checkboxes').show();
        $(this).hide();
        e.preventDefault();
    });

    // Handle scheme mix criteria lists toggle
    $('ul.criteria-checkboxes li a').click(function (e) {
        $(this).siblings('ul').slideToggle();
        $(this).children('i').toggleClass('fa-caret-square-o-right').toggleClass('fa-caret-square-o-down');
        e.preventDefault();
    });
});
