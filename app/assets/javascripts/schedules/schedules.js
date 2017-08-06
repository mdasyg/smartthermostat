var $fullCalendar = null;
var $addNewEventToScheduleContainer = null;
var $scheduleEventsContainer = null;
var $scheduleStartDatetime = null;
var $scheduleEndDatetime = null;
var $scheduleEventDeviceSelector = null;
var $scheduleSubFormsTemplates = null;
var $scheduleEventSubFormTemplate = null;
var $scheduleEventActionSubFormTemplate = null;
var $overlapScheduleTemplate = null;

function initializeFullCalendar() {
    $fullCalendar.fullCalendar({
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
        displayEventEnd: true,
        events: '/schedules.json',
        select: function (start, end, jsEvent) {
            $scheduleForm.find('#schedule_start_datetime').data('DateTimePicker').date(start);
            $scheduleForm.find('#schedule_end_datetime').data('DateTimePicker').date(end);
            $scheduleModal.modal('show');
            $fullCalendar.fullCalendar('unselect');
        },
        eventClick: function (calEvent, jsEvent, view) {
            // console.log(calEvent);
            loadScheduleValues(calEvent);
            fetchAndDisplayOverlappingEvents(calEvent.id);
            $scheduleModal.modal('show');
            return false;
        },
        // eventDrop: function (event, delta, revertFunc) {
        //     console.log(event.title + " was dropped on " + event.start.format());
        //     if (!confirm("Are you sure about this change?")) {
        //         revertFunc();
        //     }
        // }
    });
}

function getDeviceAttributes(deviceUid, callback) {
    let data = {
        deviceUid: deviceUid
    };
    let url = $('#get-device-attributes-list-url').data('url');
    url = replaceUrlParams(url, data);

    // attributes request
    let request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        type: 'get',
        dataType: 'json',
    });
    request.done(function (responseData, textStatus, jqXHR) {
        let dataForScheduleEventActions = [];
        responseData.forEach(function (item) {
            dataForScheduleEventActions.push({
                device_attribute_id: item.id,
                device_attribute_name: item.name
            });
        });
        callback(dataForScheduleEventActions);
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });
}

function deleteSchedule($thisClick) {
    let url = null;
    let scheduleId = $scheduleForm.find('#schedule_id').val();
    if (scheduleId) {
        url = $scheduleForm.data('delete-url');
        let data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        console.log('Error, schedule id missing.');
        return false;
    }
    let request = $.ajax({
        url: url,
        // beforeSend: function (xhr) {
        //     xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        // },
        type: 'delete',
        dataType: 'json'
    });

    request.done(function (responseData, textStatus, jqXHR) {
        $fullCalendar.fullCalendar('removeEvents', scheduleId);
        $scheduleModal.modal('hide');
    });

    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });
}

$(document).on('turbolinks:load', function () {
    $scheduleEventDeviceSelector = $scheduleForm.find('#schedule-event-device-selector');
    $scheduleEventsContainer = $scheduleForm.find('.schedule-events-container');
    $addNewEventToScheduleContainer = $('#add-new-event-to-schedule-container');
    $scheduleStartDatetime = $('#schedule_start_datetime');
    $scheduleEndDatetime = $('#schedule_end_datetime');
    $scheduleSubFormsTemplates = $('#schedule-subforms-templates');
    $scheduleEventSubFormTemplate = $scheduleSubFormsTemplates.find('.shcedule-event-template .schedule-event');
    $scheduleEventActionSubFormTemplate = $scheduleSubFormsTemplates.find('.schedule-event-action-template .action');
    $overlapScheduleTemplate = $scheduleSubFormsTemplates.find('.overlap-schedule-template .overlap-schedule');
    $fullCalendar = $('.calendar');

    initAddNewEventSelect2();
    initScheduleDatetimePickers();
    initializeFullCalendar();

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        let $thisClick = $(this);
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('delete-schedule')) {
                deleteSchedule($thisClick);
            }
        }
    });

    $scheduleStartDatetime.on('dp.change', function (event) {
        if (!$scheduleEndDatetime.data('DateTimePicker').date().isAfter($scheduleStartDatetime.data('DateTimePicker').date())) {
            $scheduleEndDatetime.data('DateTimePicker').date(event.date.add(1, 'd'));
        }
    });

    $scheduleModal.on('hidden.bs.modal', function (event) {
        resetScheduleModal();
    });
});
