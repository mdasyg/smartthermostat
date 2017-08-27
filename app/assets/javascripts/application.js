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
//= require jquery-ujs/src/rails
//= require select2/dist/js/select2
//= require turbolinks
//= require moment/min/moment.min
//= require moment-timezone-all/builds/moment-timezone-with-data
//= require bootstrap/dist/js/bootstrap
//= require x-editable/dist/bootstrap3-editable/js/bootstrap-editable
//= require eonasdan-bootstrap-datetimepicker/src/js/bootstrap-datetimepicker
//= require fullcalendar/dist/fullcalendar
//= require_tree .

var deviceDetailShowViewUpdateIntervalInSeconds = null;
var deviceAttributeDirectionConstants = null;
var deviceAttributePrimitiveTypesConstants = null;

function replaceUrlParams(url, data = {}) {
    if (!url) {
        return false;
    }

    if (data.deviceUid) {
        url = url.replace('DEVICE_ID', data.deviceUid);
    }
    if (data.scheduleId) {
        url = url.replace('SCHEDULE_ID', data.scheduleId);
    }

    return url;
}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks

    deviceDetailShowViewUpdateIntervalInSeconds = $('meta[name="device-detail-show-view-update-interval-in-seconds"]').attr('content');
    deviceAttributeDirectionConstants = $('#device-attribute-direction-constants').data('constants');
    deviceAttributePrimitiveTypesConstants = $('#device-attribute-primitive-types-constants').data('constants');

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
