/*
 * This is a manifest file that'll be compiled into application.js, which will include all the files listed below.
 *
 * Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
 * or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
 *
 * It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the compiled file.
 *
 * Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details about supported directives.
 *
 * NOTE: you must explicitly require external libraries here
  *
 *= require jquery
 *= require jquery-ujs
 *= require jquery.steps
 *= require bootstrap
 *= require pace
 *= require metisMenu
 *= require slimScroll
 *= require inspinia
 *= require wicket/wicket
 *= require wicket/wicket-gmap3
 *= require datatables
 *= require datatables-responsive
 *= require datatables-init
 *= require icheck
 *= require chosen
 *= require d3
 *= require score_widget.js
 *= require bootstrap-datepicker
 */

$(function () {
    // Tooltips
    $('[data-toggle="tooltip"]').tooltip();

    // iCheck all checkboxes & radio buttons
    $('input').iCheck();

    // Chosen
    $('.chosen-select').chosen();

    // Datepicker
    $('input[data-provide="datepicker"]').datepicker({
        dateFormat: 'dd/mm/yyyy',
        startDate: '0d',
        todayBtn: true,
        todayHighlight: true
    });

    // Accordion tables
    $('.accordion-body').on('show.bs.collapse', function() {
        $(this).prev().find('i.fa').removeClass('fa-caret-square-o-right').addClass('fa-caret-square-o-down');
    }).on('hidden.bs.collapse', function() {
        $(this).prev().find('i.fa').removeClass('fa-caret-square-o-down').addClass('fa-caret-square-o-right');
    });
});