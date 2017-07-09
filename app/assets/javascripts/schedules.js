var selectedDeviceAttributes = {};

function replaceUrlParams(url, deviceUid = null) {
    if (deviceUid) {
        url = url.replace('DEVICE_ID', deviceUid);
    }
    return url;
}

function updateSelectedDeviceAttributes($thisElement, initActionsContainer) {
    let $thisForm = $thisElement.closest('form');
    let $actionsContainer = $thisForm.find('.actions-container');
    selectedDeviceAttributes = {};

    let deviceUid = $thisElement.val();
    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    // var data = {
    //     device_uid: deviceUid
    // };
    let url = $('#get-device-attributes-list-url').data('url');
    url = replaceUrlParams(url, deviceUid);
    let request = $.ajax({
        url: url,
        type: 'get',
        dataType: 'json',
        // data: data
    });
    request.done(function (responseData, textStatus, jqXHR) {
        let deviceAttributes = $(responseData);
        selectedDeviceAttributes = {};
        deviceAttributes.each(function () {
            selectedDeviceAttributes[this.id] = this.name;
        });
        if (initActionsContainer) {
            $actionsContainer.empty();
            addNewAction($thisForm);
        }
    });
}

function initializeFullCalendar() {
    $calendar = $('.calendar');
    $calendar.fullCalendar({
        timezone: false,
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay listMonth'
        },
        selectable: true,
        selectHelper: true,
        editable: true,
        eventLimit: true,
        events: '/schedules.json',
        select: function (start, end, jsEvent) {
            $('#schedule_datetime').val(moment(start).format('YYYY-MM-DD HH:mm'));
            $('#my-modal').modal('show');
            $calendar.fullCalendar('unselect');
        },
    });
}

// $(document).ready( function () {
$(document).on("turbolinks:load", function () {
    initializeFullCalendar();

    $('#schedule_datetime').datetimepicker({
        // locale: 'en',
        format: "DD/MM/YYYY HH:mm:ss",
        extraFormats: ['YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });

    $('.schedule-device-selection').on('change', function (event) {
        updateSelectedDeviceAttributes($(this), true);
    });

    if (!!$('.schedule-device-selection').val()) {
        updateSelectedDeviceAttributes($('.schedule-device-selection'), false);
    }

});

