var $scheduleFormContainer = null;
var $scheduleForm = null;
var $addNewEventToScheduleSelector = null;
var $addNewEventToScheduleContainer = null;
var $scheduleEventsContainer = null;
var $scheduleStartDatetime = null;
var $scheduleEndDatetime = null;
var $scheduleReccurenceSettings = null;
var $scheduleSubFormsTemplates = null;
var $scheduleEventSubFormTemplate = null;
var $scheduleEventActionSubFormTemplate = null;

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
    $addNewEventToScheduleSelector.select2({
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
        format: 'DD/MM/YYYY HH:mm',
        extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });
}

function addNewScheduleEvent() {
    let lastScheduleEventDomId = parseInt($scheduleEventsContainer.find('.schedule-event').last().attr('data-index'));
    if (!lastScheduleEventDomId) {
        lastScheduleEventDomId = 0;
    }
    let nextScheduleEventDomId = lastScheduleEventDomId + 1;

    let $newScheduleEvent = $scheduleEventSubFormTemplate.clone();

    $newScheduleEvent.attr('data-index', nextScheduleEventDomId);

    $newScheduleEvent.removeClass('odd, even');
    if (nextScheduleEventDomId % 2 == 1) {
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

    console.log(nextScheduleEventDomId);
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
    $scheduleEventsContainer = $scheduleForm.find('.schedule-events-container');
    $addNewEventToScheduleSelector = $('#add-new-event-to-schedule');
    $addNewEventToScheduleContainer = $('#add-new-event-to-schedule-container');
    $scheduleStartDatetime = $('#schedule_start_datetime');
    $scheduleEndDatetime = $('#schedule_end_datetime');
    $scheduleReccurenceSettings = $('#schedule_is_recurrent');
    $scheduleSubFormsTemplates = $('#schedule-subforms-templates');
    $scheduleEventSubFormTemplate = $scheduleSubFormsTemplates.find('.shcedule-event-template .schedule-event');
    $scheduleEventActionSubFormTemplate = $scheduleSubFormsTemplates.find('.schedule-event-action-template .action');

    initAddNewEventSelect2();

    initScheduleDatetimePickers();

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
