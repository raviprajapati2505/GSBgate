/**
 * Created by danielsb on 16/10/2015.
 */

$(function () {
    var assessor_list = $('.select2-assessor');
    if (assessor_list.length > 0) {
        GSAS.load_list(assessor_list, '- Unassigned -');
    }
});