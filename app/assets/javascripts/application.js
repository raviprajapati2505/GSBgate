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
 *= require slimScroll/jquery.slimscroll
 *= require inspinia
 *= require effective_datatables
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
 *= require html5sortable/html5sortable
 *= require leaflet
 *= require leaflet-draw
 *= require proj4
 *= require three.js/three.js
 *= require cocoon
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
        $(this).prev().find('.category-accordion-icon i.fa').toggleClass('fa-caret-square-o-right').toggleClass('fa-caret-square-o-down');
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
    if (window.location.hash && ($(window.location.hash).length > 0)) {
        $('html, body').animate({
            scrollTop: $(window.location.hash).offset().top
        }, 1000, function() {
            $(window.location.hash).addClass('flash animated');
            $(window.location.hash).find('a.collapsed').trigger('click');
        });
    }

    // Audit log modal (click add comment button)
    $('body').on('click', '.audit-log-modal .add-comment-button', function() {
        $(this).hide();
        $('.audit-log-modal .feed-activity-list').hide();
        $('.audit-log-modal .comment-form').show();
    });

    // Audit log modal (toggle duplicate comment button visibility)
    $('body').on('mouseenter', '.audit-log-modal .user-comment', function() {
        $(this).find('.duplicate-comment-button').show();
    });
    $('body').on('mouseleave', '.audit-log-modal .user-comment', function() {
        $(this).find('.duplicate-comment-button').hide();
    });

    // Audit log modal (click duplicate comment button)
    $('body').on('click', '.audit-log-modal .duplicate-comment-button', function() {
        $('.audit-log-modal .add-comment-button').hide();
        $('.audit-log-modal .feed-activity-list').hide();
        $('.audit-log-modal .comment-form').show();
        $('.audit-log-modal #audit_log_user_comment').val($(this).data('comment'));
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
    if ($('.sortable').length > 0) {
        GSAS.setSortableListPositions();
        sortable('.sortable');
        var url = $('.sortable:first').data('url');
        $('.sortable').each(function() {
            $(this).get(0).addEventListener('sortupdate', function(e) {
                updated_sortorder = [];

                GSAS.setSortableListPositions();

                $('.sortable > .panel.panel-default').each(function(i) {
                    updated_sortorder.push({ id: $(this).data('id'), display_weight: i+1 });
                });

                $.ajax({
                    type: "PUT",
                    url: url,
                    cache: false,
                    data: { sort_order: updated_sortorder }
                });
            });
        });
    }

    // Enable delete button after a word is typed in a confirmation text box
    $('body').on('keyup', '#confirm_deletion', function() {
        $("#delete-button").prop('disabled', ($(this).val() != 'delete'));
    });

    // Enable deny button after a word is typed in a confirmation text box
    $('body').on('keyup', '#confirm_deny', function() {
        $("#deny-button").prop('disabled', ($(this).val() != 'deny'));
    });

    // Certificate type and Service provider 2 in project form
    $('.project-form').on('change', '#project_certificate_type', function(event, wasTriggered) {
        if ($(this).val() == 3) {
            $('.project-form .design-fields').show();
        } else {
            $('.project-form .design-fields').hide();
        }
    });
    $('.project-form #project_certificate_type').trigger('change', true);

    // Building type group & building type dropdowns in project form
    $('.project-form').on('change', '#project_building_type_group_id', function(event, wasTriggered) {
        $('.project-form #building-type-select select option').hide();

        if ($(this).val() == '') {
            $('.project-form #building-type-select').hide();
            $('.project-form .district-fields').hide();
        }
        else {
            $(".project-form #building-type-select option[data-building-type-group-id=" + $(this).val() + "]").show();
            $('.project-form #building-type-select').show();
            if ($(this).val() == 8) {
                $('.project-form .district-fields').show();
            } else {
                $('.project-form .district-fields').hide();
            }
        }

        if (!wasTriggered) {
            $('.project-form #building-type-select option:first').show().prop('selected', true);
        }
    });
    $('.project-form #project_building_type_group_id').trigger('change', true);

    // Turn document table in standard jQuery DataTable for sorting
    $('.document-table').DataTable({
        buttons: [],
        paging: false,
        info: false,
        order: [[3, "desc"]],
        columnDefs: [{
            "targets": 6,
            "orderable": false
        }],
        searching: false
    });

    $('.cert-doc-table').DataTable({
        buttons: [],
        paging: false,
        info: false,
        order: [[3, "desc"]],
        columnDefs: [{
            "targets": 4,
            "orderable": false
        }],
        searching: false
    })
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
    // Find and process tooltips (that weren't processed yet)
    processTooltips: function () {
        $('[data-toggle="tooltip"]').not('.tooltip-processed').tooltip();
        $('[data-toggle="tooltip"]').not('.tooltip-processed').on('click', function() {
            $(this).tooltip('hide');
        });
        $('[data-toggle="tooltip"]').not('.tooltip-processed').addClass('tooltip-processed');
    },
    setSortableListPositions: function() {
        $('.sortable > .panel.panel-default').each(function(i) {
            $(this).attr("data-pos", i+1);
        })
    },
    // Find and process iCheck checkboxes or radios (that weren't processed yet)
    processiCheck: function() {
        // iCheck all checkboxes & radio buttons
        $('input[type=checkbox], input[type=radio]').not('input[readonly]').not('.icheck-processed').addClass('icheck-processed').iCheck({
            checkboxClass: 'icheckbox_square-green',
            radioClass: 'iradio_square-green'
        });
        $('input[type=checkbox][readonly], input[type=radio][readonly]').not('.icheck-processed').addClass('icheck-processed').iCheck({
            checkboxClass: 'icheckbox_square-green',
            radioClass: 'iradio_square-green'
        }).iCheck('disable');
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
