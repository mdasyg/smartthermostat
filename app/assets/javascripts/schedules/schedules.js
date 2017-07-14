var $addNewEventToScheduleSelector = null;

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

$(document).on('turbolinks:load', function () {
    $addNewEventToScheduleSelector = $('#add-new-event-to-schedule');

    $addNewEventToScheduleSelector.select2();

    $addNewEventToScheduleSelector.on('select2:select', function (event) {
        console.log("select2:select", event);
        console.log($(this).val());
    });

});
