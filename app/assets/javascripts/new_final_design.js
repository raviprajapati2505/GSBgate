//# sourceURL=new_final_design.js
$(function () {
    // Initialize the select2
    $('select.duration-select').select2({
        placeholder: "Select the duration",
    });

    // Do JS validation before submitting
    $('form.new_certification_path').submit(function (event) {
        var valid = validate();
        if (!valid) {
            event.preventDefault();
        }
    });

    // Javascript validation
    function validate(){
        var valid = true;
        // reset UI
        $('div.form-group').removeClass('has-error');
        // do validation
        valid = ("" != $('select.duration-select').val());
        if(!valid){
            $('div.duration-group').addClass('has-error');
        }
        return valid;
    }

    $('select.duration-select').on("change", function (e) {
        validate();
    });
});