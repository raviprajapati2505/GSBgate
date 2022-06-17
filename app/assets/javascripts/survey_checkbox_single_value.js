$(function () {
  var checked_values = new Array(); 
  $('.iCheck-helper').click(function() {
    if($(this).parent().hasClass('icheckbox_square-green')){

      /* get selected checkbox values and make a string to save in a database */
      var selector = $(this).parent().find("input[name^='survey_response[question_responses_attributes]']").attr('name');
      var checkbox_value = $(this).parent().find('input[name="'+selector+'"]').data('checkbox-value');
      if($(this).parent().hasClass('checked')){
        checked_values.push(checkbox_value);
      } else {
        var index = checked_values.indexOf(checkbox_value);
        if (index !== -1) {
          checked_values.splice(index, 1);
        }
      };

      $('input[name="'+selector+'"]').val(checked_values.join('|||'));

      /* if at lease one checkbox checked then remove required validation*/
      if($('input[name="'+selector+'"]').attr('required')){
        if(checked_values.length > 0){
          $('input[name="'+selector+'"]').attr('required',false);
        }else {
          $('input[name="'+selector+'"]').attr('required',true);
        }
      }
    }
  })
});