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
 *= require datatables-plugins/integration/bootstrap/3/dataTables.bootstrap
 *= require icheck
 *= require select2
 *= require d3
 *= require d3-tip
 *= require bootstrap-datepicker
 *= require bootstrap-timepicker
 *= require dropzone
 *= require toastr
 *= require js-routes
 *= require ckeditor/init
 *= require html.sortable
 *= require leaflet
 *= require leaflet-draw
 *= require proj4
 *= require three.js/three.js 
 */

$(function () {
    // Override the default confirm dialog by rails
    $.rails.allowAction = function(link) {
        if (link.data("confirm") == undefined) {
            return true;
        }
        $.rails.showConfirmationDialog(link);
        return false;
    };

    $.rails.showConfirmationDialog = function(link) {
        var message = link.data("confirm");
        var modal = $('#confirmationModal');
        $('#confirmationModal .modal-body').html(message);
        $('#confirmationModal .okBtn').on('click', function() {
            link.data("confirm", null);
            link.trigger("click.rails");
            modal.modal('hide');
        });
        modal.modal();
    };


    // Datepicker (only today + future)
    $('.datepicker-future').datepicker({
        format: 'dd/mm/yyyy',
        startDate: '0d',
        todayBtn: true,
        todayHighlight: true
    });

    // Datepicker (only today + past)
    $('.datepicker-past').datepicker({
        format: 'dd/mm/yyyy',
        endDate: '0d',
        todayBtn: true,
        todayHighlight: true
    });

    $('.timepicker').timepicker({
        template: false,
        showMeridian: false,
        defaultTime: '0:00'
    });

    // Accordion tables
    $('.accordion-body').on('show.bs.collapse hidden.bs.collapse', function() {
        $(this).prev().find('i.fa').toggleClass('fa-caret-square-o-right').toggleClass('fa-caret-square-o-down');
    });

    // Clickable table rows
    $('table').on('click', 'tr.clickable', function() {
        window.location = $(this).data('href');
    });

    // Toastr options
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "progressBar": false,
        "positionClass": "toast-bottom-right",
        "onclick": null,
        "showDuration": "400",
        "hideDuration": "1000",
        "timeOut": "10000",
        "extendedTimeOut": "10000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut"
    };

    // Scroll to hash
    if (window.location.hash) {
        $('html, body').animate({
            scrollTop: $(window.location.hash).offset().top
        }, 1000, function() {
            $(window.location.hash).addClass('flash animated');
            $(window.location.hash).find('a.collapsed').trigger('click');
        });
    }

    // Audit log modal
    $('body').on('click', '.audit-log-modal .add-comment-button', function() {
        $(this).hide();
        $('.audit-log-modal .feed-activity-list').hide();
        $('.audit-log-modal .comment-form').show();
    });

    // Flash messages
    GSAS.processFlashMessages();

    // Tooltips
    GSAS.processTooltips();

    // iCheck
    GSAS.processiCheck();

    // After every AJAX call
    $(document).ajaxComplete(function() {
        GSAS.processFlashMessages();
        GSAS.processTooltips();
        GSAS.processiCheck();
    });

    // Sortable lists
    GSAS.setSortableListPositions();
    $('.sortable').sortable();
    $('.sortable').sortable().bind('sortupdate', function() {
        updated_sortorder = [];

        GSAS.setSortableListPositions();

        $('.sortable > .panel.panel-default').each(function(i) {
            updated_sortorder.push({ id: $(this).data('id'), display_weight: i+1 });
        });

        $.ajax({
            type: "PUT",
            url: Routes.sort_scheme_criterion_texts_path(),
            cache: false,
            data: { sort_order: updated_sortorder }
        });
    });
});

// General GSAS functions
var GSAS = {
    // Show flash messages in TOASTR popup
    processFlashMessages: function () {
        $('.flash.flash-success.hidden').each(function () {
            toastr.success($(this).html());
            $(this).remove();
        });

        $('.flash.flash-danger.hidden').each(function () {
            toastr.error($(this).html());
            $(this).remove();
        });
    },
    // Find and process tooltips
    processTooltips: function () {
        $('[data-toggle="tooltip"]').tooltip();
    },
    setSortableListPositions: function() {
        $('.sortable > .panel.panel-default').each(function(i) {
            $(this).attr("data-pos", i+1);
        })
    },
    processiCheck: function() {
        // iCheck all checkboxes & radio buttons
        $('input').iCheck({
            checkboxClass: 'icheckbox_square-green',
            radioClass: 'iradio_square-green'
        });
    },

    //Select2
    load_list_ajax: function (element, placeholder, list_url, initSelectionFnc) {
        element.select2({
            allowClear: true,
            placeholder: placeholder,
            width: "100%",
            ajax: {
                url: list_url,
                dataType: 'json',
                cache: false,
                quietMillis: 250,
                data: function (term, page) {
                    return {
                        q: term,
                        page: page
                    };
                },
                results: function (data, page) {
                    var more = (page * 25) < data.total_count;
                    return {
                        results: data.items,
                        more: more
                    };
                },
                cache: false
            },
            initSelection: initSelectionFnc
        });
    },
    load_list: function (element, placeholder) {
        element.select2({
            allowClear: true,
            placeholder: placeholder,
            width: "100%"
        });
    }
}
