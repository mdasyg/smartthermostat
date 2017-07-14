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

    $addNewEventToScheduleSelector.select2({
        ajax: {
            dataType: 'json',
            url: 'http://home-auto.eu:1026/devices/search',
            processResults: function (data, params) {
                return {
                    results: data
                };
            },
            minimumInputLength: 1,
            dropdownParent: $addNewEventToScheduleSelector,
            delay: 250
        },
        placeholder: 'Select device',
        allowClear: true
    });

    $addNewEventToScheduleSelector.on('select2:select', function (event) {
        console.log("select2:select", event);
        console.log($(this).val());
    });

    $('#schedule_start_datetime').datetimepicker({
        // locale: 'en',
        // debug: true,
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });
    $('#schedule_end_datetime').datetimepicker({
        // locale: 'en',
        // debug: true,
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });

});
