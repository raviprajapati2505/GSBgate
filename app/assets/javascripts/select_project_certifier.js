/**
 * Created by danielsb on 16/10/2015.
 */

$(function () {
    var certifier_list = $('.select2-certifier');
    if (certifier_list.length > 0) {
        GSAS.load_list(certifier_list, '- Unassigned -');
    }
});
//scheme criterion documents checkbox checked event
$(".smcd_checkbox_parent").on('ifChecked', function() {
  $('.smcd_child_checkbox').each(function() {
      $(this).prop("checked", true);
      $(this).addClass('icheck-processed').iCheck({
      checkboxClass: 'icheckbox_square-green'});
  });
});
//scheme criterion documents checkbox unchecked event
$('.smcd_checkbox_parent').on('ifUnchecked', function() {
	$('.smcd_child_checkbox').each(function() {
      $(this).prop("checked", false);
      $(this).removeClass('icheck-processed').iCheck({
      checkboxClass: 'icheckbox_square-green'});
  });
});