/*
 * This is a manifest file that'll be compiled into application.js, which will include all the files listed below.
 *
 * Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
 * or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
 *
 * It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the compiled file.
 *
 * Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details about supported directives.
 *
 * NOTE: you must explicitly require external libraries here
  *
 *= require jquery
 *= require jquery-ujs
 *= require jquery.steps
 *= require bootstrap
 *= require pace
 *= require metisMenu
 *= require slimScroll
 *= require inspinia
 *= require wicket/wicket
 *= require wicket/wicket-gmap3
 *= require datatables
 *= require datatables-responsive
 *= require datatables-init
 */

// Tooltips demo
$(function () {
    $('[data-toggle="tooltip"]').tooltip()
})