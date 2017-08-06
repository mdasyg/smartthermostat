var $scheduleFormContainer = null;
var $scheduleForm = null;
var $overlappingSchedulesContainer = null;
var $overlappingSchedulesList = null;
var $scheduleReccurenceSettings = null;

function initAddNewEventSelect2() {
    $scheduleEventDeviceSelector.select2({
        ajax: {
            dataType: 'json',
            url: $('#devices-search-url').data('url'),
            processResults: function (data, params) {
                return {
                    results: data
                };
            },
            delay: 250
        },
        minimumInputLength: 1,
        dropdownParent: $addNewEventToScheduleContainer,
        placeholder: 'Select device',
        allowClear: true,
        width: '100%' // responsive workaround
    });
}

function initScheduleDatetimePickers() {
    $scheduleStartDatetime.datetimepicker({
        // locale: 'en',
        // debug: true,
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });

    $scheduleEndDatetime.datetimepicker({
        // locale: 'en',
        // debug: true,
        useCurrent: false, //Important! See issue #1075
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });

}

function loadScheduleValues(data) {
    // console.log(data);
    $scheduleForm.find('#schedule_id').val(data.id);
    $scheduleForm.find('#schedule_device_uid').val(data.device_uid);
    $scheduleForm.find('#schedule_title').val(data.title);
    $scheduleForm.find('#schedule_description').val(data.description);
    $scheduleForm.find('#schedule_start_datetime').data('DateTimePicker').date(data.start);
    $scheduleForm.find('#schedule_end_datetime').data('DateTimePicker').date(data.end);
    $scheduleForm.find('#schedule_priority').val(data.priority);

    data.schedule_events.forEach(function (scheduleEvent) {
        // separate schedule event data from actions
        let scheduleEventData = {
            id: scheduleEvent.id,
            device_name: scheduleEvent.device_name,
            device_uid: scheduleEvent.device_uid
        };
        appendScheduleEventWithActions(scheduleEvent.actions, scheduleEventData);
    });
}

function resetScheduleForm() {
    $scheduleForm.trigger('reset');
    $scheduleForm.find('#schedule_id').val('');
    $scheduleForm.find('#recurrent-entries').addClass('hidden')
    $scheduleEventsContainer.empty();
    $scheduleEventDeviceSelector.val(null).trigger('change');
    $overlappingSchedulesContainer.addClass('hidden');
    $overlappingSchedulesList.empty();
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

function displayOverlappingSchedules(scheduleData) {
    scheduleData.forEach(function (schedule) {
        let $newOverlap = $overlapScheduleTemplate.clone();
        $newOverlap.find('.schedule-id').val(schedule.id);
        $newOverlap.find('.schedule-title').text(schedule.title);
        $newOverlap.find('.schedule-start-datetime').text(schedule.start_datetime);
        $newOverlap.find('.schedule-end-datetime').text(schedule.end_datetime);
        $newOverlap.find('.schedule-priority').val(schedule.priority);
        $overlappingSchedulesList.append($newOverlap);
        $overlappingSchedulesContainer.removeClass('hidden');
    });
}

function fetchAndDisplayOverlappingEvents(scheduleId) {
    let url = null;
    if (scheduleId) {
        url = $('#get-schedule-overlaps-url').data('url');
        let data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        return false;
    }
    let request = $.ajax({
        url: url,
        type: 'get',
        dataType: 'json',
    });
    request.done(function (responseData, textStatus, jqXHR) {
        let status = responseData.status;
        let data = responseData.data;
        if (status === 'overlaps') {
            $overlappingSchedulesList.empty();
            displayOverlappingSchedules(data);
        }
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });

}

function updateOverlapSchedulesPriorities() {
    let overlapSchedulesWithPriorities = {overlap_schedules: []};
    $overlappingSchedulesList.find('.overlap-schedule').each(function (index, overlapSchedule) {
        let scheduleId = $(overlapSchedule).find('.schedule-id').val();
        let schedulePriority = $(overlapSchedule).find('.schedule-priority').val();
        console.log(scheduleId);
        console.log(schedulePriority);
        overlapSchedulesWithPriorities['overlap_schedules'].push({
            id: scheduleId,
            priority: schedulePriority
        });
    });

    // get url
    let url = $('#update-schedule-overlaps-priorities-url').data('url');

    let request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        type: 'post',
        dataType: 'json',
        data: overlapSchedulesWithPriorities
    });

    request.done(function (responseData, textStatus, jqXHR) {
        console.log(responseData);
    });
}

function submitScheduleForm($thicClick) {
    let url = null;
    let scheduleId = $scheduleForm.find('#schedule_id').val();
    if (scheduleId) {
        url = $scheduleForm.data('update-url');
        let data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        url = $scheduleForm.data('create-url');
    }
    let request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        type: (scheduleId ? 'put' : 'post'),
        dataType: 'json',
        data: $scheduleForm.serialize()
    });

    request.done(function (responseData, textStatus, jqXHR) {
        let status = responseData.status;
        let data = responseData.data;
        if (status === 'overlaps') {
            $overlappingSchedulesList.empty();
            displayOverlappingSchedules(data);
        } else if (status === 'ok') {
            if (scheduleId) {
                $fullCalendar.fullCalendar('refetchEvents');
            } else {
                $fullCalendar.fullCalendar('renderEvent', data);
            }
            $scheduleModal.modal('hide');
        }

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
    $scheduleForm = $scheduleFormContainer.find('#schedule-form');
    $overlappingSchedulesContainer = $scheduleForm.find('#overlapping-schedules-container');
    $overlappingSchedulesList = $overlappingSchedulesContainer.find('.overlapping-schedules-list');
    $scheduleReccurenceSettings = $('#schedule_is_recurrent');

    $scheduleReccurenceSettings.on('change', scheduleRecurrenceFieldsVisibilityToggle);

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        let $thisClick = $(this);
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-event-to-schedule')) {
                addNewScheduleEvent($thisClick);
            } else if ($thisClick.hasClass('save-schedule')) {
                submitScheduleForm($thisClick);
            } else if ($thisClick.hasClass('update-overlapping-schedules-priorities')) {
                updateOverlapSchedulesPriorities();
            }
        }
    });

});