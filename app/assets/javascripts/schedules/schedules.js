var $scheduleFormContainer = null;
var $scheduleForm = null;
var $addNewEventToScheduleContainer = null;
var $scheduleEventsContainer = null;
var $scheduleStartDatetime = null;
var $scheduleEndDatetime = null;
var $scheduleReccurenceSettings = null;
var $scheduleSubFormsTemplates = null;
var $scheduleEventSubFormTemplate = null;
var $scheduleEventActionSubFormTemplate = null;
var $scheduleEventDeviceSelector = null;
var $calendar = null;

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
        minimumInputLength: 2,
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
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });
}

function initializeFullCalendar() {
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
        // events: '/schedules.json',
        select: function (start, end, jsEvent) {
            $('#schedule_datetime').data('DateTimePicker').date(start);
            $scheduleModal.modal('show');
            $calendar.fullCalendar('unselect');
        },
        eventClick: function (calEvent, jsEvent, view) {

            // console.log(calEvent);
            // console.log(calEvent.id);
            // console.log(calEvent.device_uid);
            // console.log(calEvent.name);
            // console.log(calEvent.start.format('YYYY-MM-DD HH:mm:ss'));

            $scheduleId.val(calEvent.id);
            $scheduleForm.find('#schedule_device_uid').val(calEvent.device_uid);
            $scheduleForm.find('#schedule_title').val(calEvent.name);
            $scheduleForm.find('#schedule_datetime').data('DateTimePicker').date(calEvent.start);

            updateSelectedDeviceAttributes($('.schedule-device-selector'), false, calEvent.actions);


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

    let lastScheduleEventDomId = parseInt($scheduleEventsContainer.find('.schedule-event').last().attr('data-index'));
    if (!lastScheduleEventDomId) {
        lastScheduleEventDomId = 0;
    }
    let nextScheduleEventDomId = lastScheduleEventDomId + 1;

    let $newScheduleEvent = $scheduleEventSubFormTemplate.clone();

    $newScheduleEvent.attr('data-index', nextScheduleEventDomId);
    $newScheduleEvent.attr('data-device-uid', $scheduleEventDeviceSelector.val());
    $newScheduleEvent.find('.schedule-event-device-name-placeholder').text($scheduleEventDeviceSelector.find('option:selected').text());

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

    $scheduleEventsContainer.append($newScheduleEvent);
}

function addNewScheduleEventAction($thisClick) {
    let $closestScheduleEvent = $thisClick.closest('.schedule-event');
    let $scheduleEventActionsContainer = $closestScheduleEvent.find('.actions-container');
    let prefixForScheduleEventActionSubform = $closestScheduleEvent.find('.schedule-event-form-prefix-for-subform').data('prefix');

    let lastScheduleEventDomId = parseInt($scheduleEventsContainer.find('.schedule-event').last().attr('data-index'));
    if (!lastScheduleEventDomId) {
        lastScheduleEventDomId = 0;
    }

    prefixForScheduleEventActionSubform = prefixForScheduleEventActionSubform.replace('SCHEDULE_EVENT_INDEX', lastScheduleEventDomId);

    addNewAction($scheduleEventActionsContainer, $scheduleEventActionSubFormTemplate, prefixForScheduleEventActionSubform);
}

function scheduleRecurrenceFieldsVisibilityToggle(event) {
    if ($(this).prop('checked')) {
        $('#recurrent-entries').removeClass('hidden');
    } else {
        $('#recurrent-entries').addClass('hidden');
    }
}

$(document).on('turbolinks:load', function () {
    $scheduleFormContainer = $('#schedule-form-container');
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
    $calendar = $('.calendar');

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
            } else if ($thisClick.hasClass('add-schedule-event-action')) {
                addNewScheduleEventAction($thisClick);

            }
        }
    });


});
