var $scheduleFormContainer = null;
var $scheduleForm = null;
var $scheduleModal = null;
var $addNewEventToScheduleContainer = null;
var $scheduleEventsContainer = null;
var $scheduleStartDatetime = null;
var $scheduleEndDatetime = null;
var $scheduleReccurenceSettings = null;
var $scheduleSubFormsTemplates = null;
var $scheduleEventSubFormTemplate = null;
var $scheduleEventActionSubFormTemplate = null;
var $scheduleEventDeviceSelector = null;
var $fullCalendar = null;

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
            $scheduleModal.modal('show');
            return false;
        },
        // eventDrop: function (event, delta, revertFunc) {
        //
        //     console.log(event.title + " was dropped on " + event.start.format());
        //
        //     if (!confirm("Are you sure about this change?")) {
        //         revertFunc();
        //     }
        //
        // }
    });
}

function addNewScheduleEventAction($scheduleEventArea, scheduleEventAction) {
    let $scheduleEventActionsContainer = $scheduleEventArea.find('.actions-container');
    let prefixForScheduleEventActionSubform = $scheduleEventArea.find('.schedule-event-form-prefix-for-subform').data('prefix');

    let scheduleEventIndex = $scheduleEventArea.data('index');
    prefixForScheduleEventActionSubform = prefixForScheduleEventActionSubform.replace('SCHEDULE_EVENT_INDEX', scheduleEventIndex);

    addNewAction($scheduleEventActionsContainer, $scheduleEventActionSubFormTemplate, prefixForScheduleEventActionSubform, scheduleEventAction);
}

function appendScheduleEventWithActions(dataForScheduleEventActions, dataForScheduleEvent = {}) {
    let deviceUid = null;
    if (dataForScheduleEvent && dataForScheduleEvent.device_uid) {
        deviceUid = dataForScheduleEvent.device_uid;
    } else {
        deviceUid = $scheduleEventDeviceSelector.val();
    }
    if (!deviceUid) {
        console.log('Device uid missing');
        return false;
    }

    let lastScheduleEventDomId = parseInt($scheduleEventsContainer.find('.schedule-event').last().attr('data-index'));
    if (!lastScheduleEventDomId) {
        lastScheduleEventDomId = 0;
    }
    let nextScheduleEventDomId = lastScheduleEventDomId + 1;

    let $newScheduleEvent = $scheduleEventSubFormTemplate.clone();

    $newScheduleEvent.attr('data-index', nextScheduleEventDomId);
    $newScheduleEvent.attr('data-device-uid', deviceUid);
    let deviceName = (dataForScheduleEvent.device_name) ? dataForScheduleEvent.device_name : $scheduleEventDeviceSelector.find('option:selected').text();
    $newScheduleEvent.find('.schedule-event-id').val(dataForScheduleEvent.id);
    $newScheduleEvent.find('.schedule-event-device-name-placeholder').text(deviceName);
    $newScheduleEvent.find('.schedule-event-device-uid').val(deviceUid);

    $newScheduleEvent.removeClass('odd, even');
    if ((nextScheduleEventDomId % 2) == 1) {
        $newScheduleEvent.addClass('odd');
    } else {
        $newScheduleEvent.addClass('even');
    }

    let propertyName = null;
    let propertyId = null;

    let $newScheduleEventInputs = $newScheduleEvent.find('input');
    $newScheduleEventInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('SCHEDULE_EVENT_INDEX', nextScheduleEventDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('SCHEDULE_EVENT_INDEX', nextScheduleEventDomId));
        }
    });

    dataForScheduleEventActions.forEach(function (scheduleEventAction) {
        addNewScheduleEventAction($newScheduleEvent, scheduleEventAction);
    });

    $scheduleEventsContainer.append($newScheduleEvent);
}

function addNewScheduleEvent() {
    let deviceUid = $scheduleEventDeviceSelector.val();
    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    let deviceAlreadyExists = false;
    $scheduleEventsContainer.find('.schedule-event').each(function () {
        if ($(this).data('device-uid') == deviceUid) {
            deviceAlreadyExists = true;
        }
    });
    if (deviceAlreadyExists) {
        alert('Device already exists on schedule.');
        return false;
    }

    getDeviceAttributes(deviceUid, appendScheduleEventWithActions);

}

function scheduleRecurrenceFieldsVisibilityToggle(event) {
    if ($(this).prop('checked')) {
        $('#recurrent-entries').removeClass('hidden');
    } else {
        $('#recurrent-entries').addClass('hidden');
    }
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
    $scheduleFormContainer = $('#schedule-form-container');
    $scheduleModal = $('#schedule-modal');
    $scheduleForm = $scheduleFormContainer.find('#schedule-form');
    $scheduleEventDeviceSelector = $scheduleForm.find('#schedule-event-device-selector');
    $scheduleEventsContainer = $scheduleForm.find('.schedule-events-container');
    $addNewEventToScheduleContainer = $('#add-new-event-to-schedule-container');
    $scheduleStartDatetime = $('#schedule_start_datetime');
    $scheduleEndDatetime = $('#schedule_end_datetime');
    $scheduleReccurenceSettings = $('#schedule_is_recurrent');
    $scheduleSubFormsTemplates = $('#schedule-subforms-templates');
    $scheduleEventSubFormTemplate = $scheduleSubFormsTemplates.find('.shcedule-event-template .schedule-event');
    $scheduleEventActionSubFormTemplate = $scheduleSubFormsTemplates.find('.schedule-event-action-template .action');
    $fullCalendar = $('.calendar');

    initAddNewEventSelect2();
    initScheduleDatetimePickers();
    initializeFullCalendar();

    $scheduleReccurenceSettings.on('change', scheduleRecurrenceFieldsVisibilityToggle);

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        let $thisClick = $(this);
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-event-to-schedule')) {
                addNewScheduleEvent($thisClick);
            } else if ($thisClick.hasClass('save-schedule')) {
                submitScheduleForm($thisClick);
            } else if ($thisClick.hasClass('delete-schedule')) {
                deleteSchedule($thisClick);
            }
        }
    });

    $scheduleModal.on('hidden.bs.modal', function (event) {
        resetScheduleModal();
    });
});
