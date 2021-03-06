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
            loadScheduleValues(calEvent);
            fetchAndDisplayOverlappingEvents(calEvent.id);
            $scheduleModal.modal('show');
            return false;
        }
    });
}

function deleteSchedule($thisClick) {
    var url = null;
    var scheduleId = $scheduleForm.find('#schedule_id').val();
    if (scheduleId) {
        url = $scheduleForm.data('delete-url');
        var data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        console.log('Error, schedule id missing.');
        return false;
    }
    var request = $.ajax({
        url: url,
        type: 'delete',
        dataType: 'json'
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result == 'ok') {
            $fullCalendar.fullCalendar('refetchEvents');
            $fullCalendar.fullCalendar('removeEvents', scheduleId);
            $scheduleModal.modal('hide');
        } else if (responseData.result == 'error') {
            displayErrors($scheduleForm, responseData.messages);
            console.log('Could not delet event');
        }

    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        alert(errorThrown + ': ' + textStatus);
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
        var $thisClick = $(this);
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
