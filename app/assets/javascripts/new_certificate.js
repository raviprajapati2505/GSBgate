//# sourceURL=new_certificate.js
$(function () {
    // Initialize the select2 boxes
    $('#gsb_version').select2({
        placeholder: "Select the version",
        minimumResultsForSearch: -1,
    });
    $('#assessment_method').select2({
        placeholder: "Select the version",
        minimumResultsForSearch: -1,
    });
    $('#certification_path_development_type').select2({
        placeholder: "Select the development type",
        minimumResultsForSearch: -1,
    });
    $('select.single-scheme-select').select2({
        placeholder: "Select the scheme",
    });
    $('select.mixed-scheme-select').select2({
        placeholder: "Select and add one or more schemes",
    });

    calculate_total_weight();

    function calculate_total_weight() {
        var total = 0;
        $('table.schemes input.weight').each(function (idx, el) {
            var elem = $(el);
            total += parseInt(elem.val(), 10);
        });
        $('span.scheme-mixed-total').text(total);
        if(total == 100){
            $('div.total-row').addClass('text-success');
            $('div.total-row').removeClass('text-danger');
            $('div.schemes-group input.weight').parent().removeClass('has-error');
        }else{
            $('div.total-row').removeClass('text-success');
            $('div.total-row').addClass('text-danger');
            $('div.schemes-group input.weight').parent().addClass('has-error');
        }
        return total;
    }

    // Javascript validation
    function validate(){
        var valid = true;

        // reset UI
        $('div.form-group').removeClass('has-error');
        $('div.schemes-group .input-group').removeClass('has-error');
        $('div.schemes-group .input-group span.help-block').remove();

        // No validation needed, for Final Design Certificate
        var certification_type = $('#certification_path_certification_type').val();
        if ([10, 11, 12, 13, 14, 15, 16, 17, 18, 19].includes(certification_type)) {
            valid = ("" != $('#certification_path_expires_at').val());
            if(!valid){
                $('div.duration-group').addClass('has-error');
            }
        } else {
            // Determine the selected development type
            if ($('select.single-scheme-select').length) {
                valid = ("" != $('select.single-scheme-select').val());
                if (!valid) {
                    $('div.scheme-single-group').addClass('has-error');
                }
            } else if ($('select.mixed-scheme-select').length) {
                var total = calculate_total_weight();
                if (total != 100) {
                    valid = false;
                } else {
                    // none of the scheme mixes can have 0% weight
                    $('table.schemes input.weight').each(function (idx, el) {
                        var elem = $(el);
                        var value = parseInt(elem.val(), 10);
                        if (value == 0) {
                            valid = false;
                            elem.parent().addClass('has-error');
                        } else {
                            elem.parent().removeClass('has-error');
                        }
                    });
                }

                // Search for schemes with same name
                var scheme_rows = $('table.schemes tbody tr');
                scheme_rows.each(function (index, object) {
                    var curr_scheme_id = $(object).find('input[type="hidden"]').val();
                    // Get all scheme rows with the same scheme name (or scheme id)
                    var identical_scheme_rows = $('table.schemes input[type="hidden"][value=' + curr_scheme_id + ']').parents('tbody tr');
                    // Check if more rows exist with an identical scheme name
                    if (identical_scheme_rows.length > 1) {
                        var curr_name_input = $(object).find('input.name');
                        // The custom name is required now
                        if (curr_name_input.val() == '') {
                            valid = false;
                            curr_name_input.parent().addClass('has-error');
                            curr_name_input.parent().append('<span class="help-block">This field cannot be blank.</span>');
                            return true;
                        }
                        // Custom names must be unique over all rows with the same scheme name
                        identical_scheme_rows.each(function (index, object2) {
                            var name_input = $(object2).find('input.name');
                            if ((curr_name_input.data('id') != name_input.data('id')) && (curr_name_input.val() == name_input.val())) {
                                valid = false;
                                curr_name_input.parent().addClass('has-error');
                                curr_name_input.parent().append('<span class="help-block">The custom name must be unique among rows with same scheme name.</span>');
                                return true;
                            }
                        });
                    }
                });
            } else {
                valid = false;
                $('#certification_path_development_type').parent().addClass('has-error');
            }
        }
        return valid;
    }

    // Do JS validation before submitting
    $('form.new_certification_path').submit(function (event) {
        var valid = validate();
        if (!valid) {
            event.preventDefault();
            return false;
        }
    });

    $('select.single-scheme-select').on("change", function (e) {
        validate();
    });

    $('select.mixed-scheme-select').on("change", function (e) {
        validate();
    });

    $('#certification_path_expires_at').on("change", function (e) {
        validate();
    });

    var next_id = 0;

    // Add a scheme from the mixed select to the table
    $('button.add_scheme').click(function () {
        var scheme_select = $('select.mixed-scheme-select');
        // Get selected element
        var scheme_data = scheme_select.select2('data');
        if (scheme_data) {
            var scheme_id = scheme_data.id;
            var scheme_name = scheme_data.text;
            // Clear selection
            scheme_select.val(null);
            next_id++;
            // Create fields
            var scheme_col = scheme_name;
            scheme_col += '<input type="hidden" value="' + scheme_id + '" name="certification_path[schemes][][scheme_id]">';
            var name_col = '<div class="input-group"><input class="form-control name" value="" name="certification_path[schemes][][custom_name]" data-id="' + next_id + '"></div>';
            var weight_col = '<div class="input-group"><input class="form-control weight" type="number" value="0" min="0" max="100" step="1" required name="certification_path[schemes][][weight]"><span class="input-group-addon">%</span></div>';
            var action_col = '<button type="button" class="btn btn-sm remove_scheme" data-scheme-id="' + scheme_id +'" data-scheme-name="' + scheme_name +'"><i title="Remove scheme" class="fa fa-trash"></i></button>';
            var scheme_row = '<tr><td>' + scheme_col + '</td><td>' + name_col + '</td><td>' + weight_col + '</td><td>' + action_col + '</td></tr>';
            $('table.schemes').append(scheme_row);
            validate();
        }
    });

    $('table.schemes>tbody').on('change', 'input.name', function () {
        validate();
    });

    // ReCalculate the total weight
    $('table.schemes>tbody').on('change', 'input.weight', function () {
        validate();
    });

    // Remove a scheme from the table, but add it back to the mixed select
    $('table.schemes>tbody').on('click', 'button.remove_scheme', function () {
        // Remove the row
        $(this).closest('tr').remove();
        validate();
    });

    $('#gsb_version').change(function() {
        var project_id = $('#certification_path_project_id').val();
        var certification_type = $('#certification_path_certification_type').val();
        var pcr_track = $('#certification_path_pcr_track').is(":checked");
        var gsb_version = $('#gsb_version').val();
        var assessment_method = $('#assessment_method').val();
        $.ajax({
           type: 'POST',
            url: Routes.apply_certification_path_path(project_id, certification_type),
            dataType: 'script',
            cache: false,
            data: {
                gsb_version: gsb_version,
                certification_path: {
                    pcr_track: pcr_track,
                },
                assessment_method: assessment_method
            },
        });
    });

    $('#assessment_method').change(function() {
        var project_id = $('#certification_path_project_id').val();
        var certification_type = $('#certification_path_certification_type').val();
        var pcr_track = $('#certification_path_pcr_track').is(":checked");
        var assessment_method = $('#assessment_method').val();
        $.ajax({
           type: 'POST',
            url: Routes.apply_certification_path_path(project_id, certification_type),
            dataType: 'script',
            cache: false,
            data: {
                assessment_method: assessment_method,
                certification_path: {
                    pcr_track: pcr_track,
                },
            },
        });
    });
    
    $('#certification_path_development_type').change(function() {
        var project_id = $('#certification_path_project_id').val();
        var certification_type = $('#certification_path_certification_type').val();
        var pcr_track = $('#certification_path_pcr_track').is(":checked");
        var gsb_version = $('#gsb_version').val();
        var development_type = $('#certification_path_development_type').val();
        var assessment_method = $('#assessment_method').val();
        $.ajax({
            type: 'POST',
            url: Routes.apply_certification_path_path(project_id, certification_type),
            dataType: 'script',
            cache: false,
            data: {
                gsb_version: gsb_version,
                certification_path: {
                    pcr_track: pcr_track,
                    development_type: development_type,
                },
                assessment_method: assessment_method
            },
        });
    });
});