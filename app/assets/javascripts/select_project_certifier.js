/**
 * Created by danielsb on 16/10/2015.
 */

$(function () {
    var certifier_list = $('.select2-certifier');
    if (certifier_list.length > 0) {
        GSAS.load_list(certifier_list, '- Unassigned -');
    }
});