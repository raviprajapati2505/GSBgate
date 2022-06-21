$(function() {
  // ajax call to update position
  function updatePositions(survey_version_id, model, new_sequence) {
    if (!!survey_version_id && !!model && !!new_sequence) {
      $.ajax({
        url: "/survey_types/" + survey_version_id + "/survey_questionnaire_versions/update_position",
        type: "PATCH",
        dataType: "json",
        cache: false,
        data: {
          model: model,
          new_sequence: new_sequence
        },
        success: function(data) {
            $("#toast-message").html($.rails.toast_message(data["css_class"], data["message"]));
        },
        error: function() {
            $("#toast-message").html($.rails.toast_message("error", "Something went wrong!"));
        }
      });
    } else {
      $("#toast-message").html($.rails.toast_message("error", "Something went wrong!"));
    }

    // hide container after 2 seconds
      setInterval(function() {
        $("#toast-message").html('');
    }, 2000);
  }

  // change the visibility of options and set their destroy parameter values
  function manageExistingOptionsVisibility(element, visibility) {
    var options_nested_fields = element.find(".survey-question-options .nested-fields");
    var remove_options_fields = options_nested_fields.find("input[id*='__destroy']");

    if (visibility == "hide") {
      // track already removed options
      // remove_options_fields.find("[value='1']").addClass("to_be_removed");

      options_nested_fields.hide();
      remove_options_fields.val("1");

    } else {
      options_nested_fields.show();
      remove_options_fields.val("false");

      // set value for already removed options
      // remove_options_fields.find(".to_be_removed").val("1");
      // remove_options_fields.removeClass("to_be_removed");
    }
  }

  // change visibility of add options button according to question type
  function changeVisibilityOfOptionsButton() {
    $(".select-question-type").on("change", function() {
      let question_types_with_no_options = ["fill_in_the_blank"]
      let survey_questions_fields = $(this).parent().parent();
      let selected_question_type = $(this).find(":selected").val();
      let add_options_button = survey_questions_fields.find("#add-option-button");

      if ( question_types_with_no_options.includes(selected_question_type) ) {
        add_options_button.addClass("d-none");

        manageExistingOptionsVisibility(survey_questions_fields, 'hide');

      } else {
        add_options_button.removeClass("d-none");
        manageExistingOptionsVisibility(survey_questions_fields, 'show');
      }
    });
  }

  $('.sortable-survey-questions').sortable({
    axis: 'y',

    update: function(event, ele) {
      var survey_version_id = $(".sortable-survey-questions").data("survey-type-id");
      var model = $(this).data("model");

      new_sequence = []
      $(".sortable-survey-questions").children().each(function(){
        new_sequence.push($(this).data("sortable-id"));
      });

      updatePositions(survey_version_id, model, new_sequence);
    }
  });

  // assign position to position field of question option
  $('.sortable-question-options').sortable({
    axis: 'x',
    update: function(event, ele) {
      $(ele.item).parent().children().each(function(index, ele) {
        $(this).find("input.option-position-field").val(index);
      });
    }
  });

  // for nested forms
  $(document).on("cocoon:after-insert", function() {
    changeVisibilityOfOptionsButton();
  }).trigger('cocoon:after-insert');

  var checked_values = new Array();

  $('.iCheck-helper').click(function() {
    if($(this).parent().hasClass('icheckbox_square-green')){

      /* get selected checkbox values and make a string to save in a database */
      var selector = $(this).parent().find("input[name^='survey_response[question_responses_attributes]']").attr('name');
      var checkbox_value = $(this).parent().find('input[name="' + selector + '"]').data('checkbox-value');

      if ($(this).parent().hasClass('checked')) {
        checked_values.push(checkbox_value);
      } else {
        var index = checked_values.indexOf(checkbox_value);
        if (index !== -1) {
          checked_values.splice(index, 1);
        }
      };

      $('input[name="' + selector + '"]').val(checked_values.join('|||'));

      /* if at lease one checkbox checked then remove required validation*/
      if ($('input[name="'+selector+'"]').attr('required')) {
        if (checked_values.length > 0) {
          $('input[name="'+selector+'"]').attr('required',false);
        } else {
          $('input[name="'+selector+'"]').attr('required',true);
        }
      }
    }
  });
});
