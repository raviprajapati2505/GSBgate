//# sourceURL=new_letter_of_conformance.js
$(function () {
    // Initialize the select2 boxes
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

        // Determine the selected development type
        if ($('input.single-use').is(':checked') == true) {
            valid = ("" != $('select.single-scheme-select').val());
            if(!valid){
                $('div.scheme-single-group').addClass('has-error');
            }
        } else if (($('input.mixed-use').is(':checked') == true) || ($('input.mixed-development').is(':checked') == true) || ($('input.mixed-development-in-stages').is(':checked') == true)) {
            var total = calculate_total_weight();
            if (total != 100) {
                valid = false;
                $('div.schemes-group input.weight').parent().addClass('has-error');
            }

            // Search for schemes with same name
            var scheme_rows = $('table.schemes tbody tr');
            scheme_rows.each(function(index, object) {
                var curr_scheme_id = $(object).find('input[type="hidden"]').val();
                // Get all scheme rows with the same scheme name (or scheme id)
                var identical_scheme_rows = $('table.schemes input[type="hidden"][value=' + curr_scheme_id + ']').parents('tbody tr');
                // Check if more rows exist with an identical scheme name
                if (identical_scheme_rows.size() > 1) {
                    var curr_name_input = $(object).find('input.name');
                    // The custom name is required now
                    if (curr_name_input.val() == '') {
                        valid = false;
                        curr_name_input.parent().addClass('has-error');
                        curr_name_input.parent().append('<span class="help-block">This field cannot be blank.</span>');
                        return true;
                    }
                    // Custom names must be unique over all rows with the same scheme name
                    identical_scheme_rows.each(function(index, object2) {
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
            $('div.development-type-group').addClass('has-error');
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

    // Toggle UI between Single and Mixed mode
    $('input.single-use').on('ifChecked', function (event) {
        $('div.scheme-single-group').show();
        $('div.scheme-mixed-group').hide();
        validate();
    });
    $('input.mixed').on('ifChecked', function (event) {
        $('div.scheme-single-group').hide();
        $('div.scheme-mixed-group').show();
        validate();
    });

    $('select.single-scheme-select').on("change", function (e) {
        validate();
    });

    $('select.mixed-scheme-select').on("change", function (e) {
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

    $('#certification_path_certificate_id').change(function() {
        var project_id = $('#certification_path_project_id').val();
        var certificate_id = $(this).val();
        $.ajax({
           type: 'POST',
            url: Routes.apply_certification_path_path(project_id, certificate_id),
            dataType: 'script',
            cache: false
        });
    });
});