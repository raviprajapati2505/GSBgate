//# sourceURL=new_letter_of_conformance.js
$(function () {
    // Initialize the select2 boxes
    $('select.single-scheme-select').select2({
        placeholder: "Select the scheme",
    });

    $('select.mixed-scheme-select').select2({
        placeholder: "Select and add one or more schemes",
    });

    // Validate the form
    validate();

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
            $('div.schemes-group').removeClass('has-error');
        }else{
            $('div.total-row').removeClass('text-success');
            $('div.total-row').addClass('text-danger');
            $('div.schemes-group').addClass('has-error');
        }
        return total;
    }

    // Javascript validation
    function validate(){
        var valid = true;
        // reset UI
        $('div.form-group').removeClass('has-error');
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
                $('div.schemes-group').addClass('has-error');
            }
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

    // Add a scheme from the mixed select to the table
    $('button.add_scheme').click(function () {
        var scheme_select = $('select.mixed-scheme-select');
        // Get selected element
        var scheme_data = scheme_select.select2('data');
        if (scheme_data) {
            var scheme_id = scheme_data.id;
            var scheme_name = scheme_data.text;
            // Clear selection
            scheme_select.val(null)
            // Remove that option
            $('select.mixed-scheme-select option[value="' + scheme_id + '"]').remove();
            // Refresh select2
            scheme_select.select2({placeholder: "Select and add one or more schemes",});
            // Create fields
            var scheme_col = scheme_name;
            scheme_col += '<input type="hidden" value="' + scheme_id + '" name="certification_path[schemes][][scheme_id]">';
            var weight_col = '<div class="input-group"><input class="form-control weight" type="number" value="0" min="0" max="100" step="1" required name="certification_path[schemes][][weight]"><span class="input-group-addon">%</span></div>';
            var action_col = '<button type="button" class="btn btn-sm remove_scheme" data-scheme-id="' + scheme_id +'" data-scheme-name="' + scheme_name +'"><i title="Remove scheme" class="fa fa-trash"></i></button>';
            var scheme_row = '<tr><td>' + scheme_col + '</td><td>' + weight_col + '</td><td>' + action_col + '</td></tr>';
            $('table.schemes').append(scheme_row);
            validate();
        }
    });

    // ReCalculate the total weight
    $('table.schemes>tbody').on('change', 'input.weight', function () {
        validate();
    });

    // Remove a scheme from the table, but add it back to the mixed select
    $('table.schemes>tbody').on('click', 'button.remove_scheme', function () {
        // Find the current scheme information
        var scheme_id = $(this).data('scheme-id');
        var scheme_name = $(this).data('scheme-name');
        // Add the option back to the select box
        var scheme_select = $('select.mixed-scheme-select');
        scheme_select.append($('<option>', {value: scheme_id, text: scheme_name}));
        // Sort the options
        var scheme_select_options = $('select.mixed-scheme-select option');
        scheme_select_options.sort(function sort(a,b){
            a = a.text.toLowerCase();
            b = b.text.toLowerCase();
            if(a > b) {
                return 1;
            } else if (a < b) {
                return -1;
            }
            return 0;
        });
        scheme_select.html(scheme_select_options);
        // Remove the row
        $(this).closest('tr').remove();
        validate();
    });
});