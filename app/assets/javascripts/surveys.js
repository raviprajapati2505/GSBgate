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
    }

    $("#toast-message").html($.rails.toast_message("error", "Something went wrong!"));
    
    // hide container after 2 seconds
      setInterval(function() {
        $("#toast-message").html('');
    }, 2000);
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
});
