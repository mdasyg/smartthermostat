// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery/dist/jquery
//= require turbolinks
//= require moment/min/moment.min
//= require moment-timezone-all/builds/moment-timezone-with-data
//= require bootstrap/dist/js/bootstrap
//= require x-editable/dist/bootstrap3-editable/js/bootstrap-editable
//= require eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker
//= require fullcalendar/dist/fullcalendar
//= require_tree .

$(document).on("turbolinks:load", function () { // we need this because of turbolinks

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('remove-form-row')) {
                $thisClick.closest('.form-row').empty().remove();
            }
        }
    });

});
