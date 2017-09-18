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
            processResults: function (response, params) {
                if (response.result == 'ok') {
                    return {
                        results: response.data
                    };
                } else {
                    return {
                        results: []
                    };
                }
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
    $scheduleForm.find('#schedule_id').val(data.id);
    $scheduleForm.find('#schedule_original_schedule').val(data.original_schedule);
    $scheduleForm.find('#schedule_device_uid').val(data.device_uid);
    $scheduleForm.find('#schedule_title').val(data.title);
    $scheduleForm.find('#schedule_description').val(data.description);
    $scheduleForm.find('#schedule_start_datetime').data('DateTimePicker').date(data.start);
    $scheduleForm.find('#schedule_end_datetime').data('DateTimePicker').date(data.end);
    $scheduleForm.find('#schedule_priority').val(data.priority);
    $scheduleForm.find('#schedule_is_recurrent').prop('checked', data.is_recurrent);
    if (data.is_recurrent == 1) {
        $scheduleForm.find('#recurrent-entries').removeClass('hidden');
        $scheduleForm.find('#schedule_recurrence_frequency').val(data.recurrence_frequency);
        $scheduleForm.find('#schedule_recurrence_unit').val(data.recurrence_unit);
    }

    data.schedule_events.forEach(function (scheduleEvent) {
        // separate schedule event data from actions
        var scheduleEventData = {
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
    $scheduleForm.find('#schedule_original_schedule').val('');
    $scheduleForm.find('#recurrent-entries').addClass('hidden');
    $scheduleEventsContainer.empty();
    $scheduleEventDeviceSelector.val(null).trigger('change');
    $overlappingSchedulesContainer.addClass('hidden');
    $overlappingSchedulesList.empty();
    $scheduleForm.find('#errors-explanation').remove();
}

function addNewScheduleEventAction($scheduleEventArea, scheduleEventActionData) {
    var $scheduleEventActionsContainer = $scheduleEventArea.find('.actions-container');
    var prefixForScheduleEventActionSubform = $scheduleEventArea.find('.schedule-event-form-prefix-for-subform').data('prefix');

    var scheduleEventIndex = $scheduleEventArea.data('index');
    prefixForScheduleEventActionSubform = prefixForScheduleEventActionSubform.replace('SCHEDULE_EVENT_INDEX', scheduleEventIndex);

    addNewAction($scheduleEventActionsContainer, $scheduleEventActionSubFormTemplate, prefixForScheduleEventActionSubform, scheduleEventActionData);
}

function appendScheduleEventWithActions(dataForScheduleEventActions, dataForScheduleEvent) {
    var deviceUid = null;
    if (dataForScheduleEvent && dataForScheduleEvent.device_uid) {
        deviceUid = dataForScheduleEvent.device_uid;
    } else {
        deviceUid = $scheduleEventDeviceSelector.val();
    }
    if (!deviceUid) {
        console.log('Device uid missing');
        return false;
    }

    var lastScheduleEventDomId = parseInt($scheduleEventsContainer.find('.schedule-event').last().attr('data-index'));
    if (!lastScheduleEventDomId) {
        lastScheduleEventDomId = 0;
    }
    var nextScheduleEventDomId = lastScheduleEventDomId + 1;

    var $newScheduleEvent = $scheduleEventSubFormTemplate.clone();

    $newScheduleEvent.attr('data-index', nextScheduleEventDomId);
    $newScheduleEvent.attr('data-device-uid', deviceUid);
    var deviceName = (dataForScheduleEvent.device_name) ? dataForScheduleEvent.device_name : $scheduleEventDeviceSelector.find('option:selected').text();
    $newScheduleEvent.find('.schedule-event-id').val(dataForScheduleEvent.id);
    $newScheduleEvent.find('.schedule-event-device-name-placeholder').text(deviceName);
    $newScheduleEvent.find('.schedule-event-device-uid').val(deviceUid);

    $newScheduleEvent.removeClass('odd, even');
    if ((nextScheduleEventDomId % 2) == 1) {
        $newScheduleEvent.addClass('odd');
    } else {
        $newScheduleEvent.addClass('even');
    }

    var propertyName = null;
    var propertyId = null;

    var $newScheduleEventInputs = $newScheduleEvent.find('input');
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

    dataForScheduleEventActions.forEach(function (scheduleEventActionData) {
        addNewScheduleEventAction($newScheduleEvent, scheduleEventActionData);
    });

    $scheduleEventsContainer.append($newScheduleEvent);
}

function addNewScheduleEvent() {
    var deviceUid = $scheduleEventDeviceSelector.val();
    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    var deviceAlreadyExists = false;
    $scheduleEventsContainer.find('.schedule-event').each(function () {
        if ($(this).data('device-uid') == deviceUid) {
            deviceAlreadyExists = true;
        }
    });
    if (deviceAlreadyExists) {
        alert('Device already exists on schedule.');
        return false;
    }

    getDeviceAttributes(deviceUid, 0, appendScheduleEventWithActions, {});

}

function scheduleRecurrenceFieldsVisibilityToggle(event) {
    if ($(this).prop('checked')) {
        $('#recurrent-entries').removeClass('hidden');
    } else {
        $('#recurrent-entries').addClass('hidden');
    }
}

function displayOverlappingSchedules(scheduleData) {
    $overlappingSchedulesList.empty();
    scheduleData.forEach(function (schedule) {
        var $newOverlap = $overlapScheduleTemplate.clone();
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
    var url = null;
    if (scheduleId) {
        url = $('#get-schedule-overlaps-url').data('url');
        var data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        return false;
    }
    var request = $.ajax({
        url: url,
        type: 'get',
        dataType: 'json'
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result === 'error') {
            if (responseData.overlaps) {
                displayOverlappingSchedules(responseData.overlaps);
            }
            if (responseData.messages) {
                displayErrors($scheduleForm, responseData.messages);
            }
        }
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        alert(errorThrown + ': ' + textStatus);
    });
}

function updateOverlapSchedulesPriorities() {
    var overlapSchedulesWithPriorities = {overlap_schedules: []};
    $overlappingSchedulesList.find('.overlap-schedule').each(function (index, overlapSchedule) {
        var scheduleId = $(overlapSchedule).find('.schedule-id').val();
        var schedulePriority = $(overlapSchedule).find('.schedule-priority').val();
        overlapSchedulesWithPriorities['overlap_schedules'].push({
            id: scheduleId,
            priority: schedulePriority
        });
    });

    // get url
    var url = $('#update-schedule-overlaps-priorities-url').data('url');
    var request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        type: 'post',
        dataType: 'json',
        data: overlapSchedulesWithPriorities
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result == 'ok') {
            $fullCalendar.fullCalendar('refetchEvents');
        } else {
            console.log('Could not update overlapping event priorities');
        }
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        alert(errorThrown + ': ' + textStatus);
    });
}

function submitScheduleForm($thisClick) {
    var url = null;
    var scheduleId = $scheduleForm.find('#schedule_id').val();
    if (scheduleId) {
        url = $scheduleForm.data('update-url');
        var data = {
            scheduleId: scheduleId
        };
        url = replaceUrlParams(url, data);
    } else {
        url = $scheduleForm.data('create-url');
    }
    var request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        type: (scheduleId ? 'put' : 'post'),
        dataType: 'json',
        data: $scheduleForm.serialize()
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result === 'error') {
            if (responseData.overlaps) {
                displayOverlappingSchedules(responseData.overlaps);
            } else {
                $overlappingSchedulesList.empty();
                $overlappingSchedulesContainer.addClass('hidden');
            }
            if (responseData.messages) {
                displayErrors($scheduleForm, responseData.messages);
            }
        } else if (responseData.result === 'ok') {
            $fullCalendar.fullCalendar('refetchEvents'); // Do this for new events also in order to bring all the events in case schedule is recurrent
            $scheduleModal.modal('hide');
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
    $scheduleFormContainer = $('#schedule-form-container');
    $scheduleForm = $scheduleFormContainer.find('#schedule-form');
    $overlappingSchedulesContainer = $scheduleForm.find('#overlapping-schedules-container');
    $overlappingSchedulesList = $overlappingSchedulesContainer.find('.overlapping-schedules-list');
    $scheduleReccurenceSettings = $('#schedule_is_recurrent');

    $scheduleReccurenceSettings.on('change', scheduleRecurrenceFieldsVisibilityToggle);

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
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
