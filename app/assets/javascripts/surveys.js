$(function() {
  // close toast-message
  function closeToastMessage() {
    setInterval(function() {
      $("#toast-message").html('');
    }, 2000);
  }

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

    closeToastMessage();
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
    GSB.processiCheck();
    changeVisibilityOfOptionsButton();
  }).trigger('cocoon:after-insert');

  // model to show all text responses of projects survey
  $('.show_text_responses').click(function() {
    var modal = $('#survey_text_response_model');
    var project_survey_id = modal.data('projects-survey-id');

    modal.modal('show');

    $.ajax({
      url: "/survey_responses/all_text_responses_of_survey_question",
      method: "GET",
      dataType: "json",
      data: {
        project_survey_id: project_survey_id,
        question_id: $(this).data('survey_question_id')
      },
      success: function(data) {
        modal.find('.content').html('');
        modal.find('.modal-title').html(data.question_text);
        modal.find('.reaction-count').html("Reactions: " + data.question_responses.length);

        for (response of data.question_responses) {
          $('.content').append("<div class='alert alert-info'>" + response.value + '</div>');
        }
      },
      error: function() {
        alert('Something went wrong !');
      }
    });
  });

  // to copy the projects survey link.
  $('.link-survey').on('click', function() {
    let temp = document.createElement('textarea');
    temp.value = $(this).data('base_url') + $(this).data('survey_link');
    document.body.appendChild(temp);
    temp.select();
    document.execCommand('copy');
    document.body.removeChild(temp);
    $("#toast-message").html($.rails.toast_message('success', 'link are copied'));

    closeToastMessage();
  });
});
