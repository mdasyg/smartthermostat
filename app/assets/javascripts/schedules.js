var selectedDeviceAttributes = {};

function replaceUrlParams(url, deviceUid = null) {
    if (deviceUid) {
        url = url.replace('DEVICE_ID', deviceUid);
    }
    return url;
}

function updateSelectedDeviceAttributes($thisElement, initActionsContainer) {
    var $thisForm = $thisElement.closest('form');
    var $actionsContainer = $thisForm.find('.actions-container');
    selectedDeviceAttributes = {};


    var deviceUid = $thisElement.val();
    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    // var data = {
    //     device_uid: deviceUid
    // };
    var url = $('#get-device-attributes-list-url').data('url');
    url = replaceUrlParams(url, deviceUid);
    var request = $.ajax({
        url: url,
        type: 'get',
        dataType: 'json',
        // data: data
    });
    request.done(function (responseData, textStatus, jqXHR) {
        var deviceAttributes = $(responseData);
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
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,agendaWeek,agendaDay'
        },
        selectable: true,
        selectHelper: true,
        editable: true,
        eventLimit: true,

        select: function (start, end) {


            console.log(start, end);

            // $.getScript('/events/new', function () {
            //     $('#event_date_range').val(moment(start).format("MM/DD/YYYY HH:mm") + ' - ' + moment(end).format("MM/DD/YYYY HH:mm"))
            //     date_range_picker();
            //     $('.start_hidden').val(moment(start).format('YYYY-MM-DD HH:mm'));
            //     $('.end_hidden').val(moment(end).format('YYYY-MM-DD HH:mm'));
            // });

            $calendar.fullCalendar('unselect');
        },

    });
}

$(document).on("turbolinks:load", function () {

    initializeFullCalendar();

    $('#schedule_datetime').datetimepicker({
        locale: 'en',
        format: "DD/MM/YYYY HH:mm:ss",
        extraFormats: ['YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });
    // $('#schedule_datetime').data('DateTimePicker').format("DD/MM/YYYY HH:mm:ss")


    $('.schedule-device-selection').on('change', function (event) {
        updateSelectedDeviceAttributes($(this), true);
    });


    if (!!$('.schedule-device-selection').val()) {
        updateSelectedDeviceAttributes($('.schedule-device-selection'), false);
    }

});

