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
        defaultDate: $scheduleStartDatetime.data('DateTimePicker').date().add(1, 'm'),
    });

    $scheduleStartDatetime.on('dp.change', function (event) {
        $scheduleEndDatetime.data('DateTimePicker').minDate(event.date.add(1, 'm'));
        $scheduleEndDatetime.data('DateTimePicker').date(event.date.add(1, 'm'));
    });
}

function loadScheduleValues(data) {
    // console.log(data);
    $scheduleForm.find('#schedule_id').val(data.id);
    $scheduleForm.find('#schedule_device_uid').val(data.device_uid);
    $scheduleForm.find('#schedule_title').val(data.name);
    $scheduleForm.find('#schedule_description').val(data.description);
    $scheduleForm.find('#schedule_start_datetime').data('DateTimePicker').date(data.start);
    $scheduleForm.find('#schedule_end_datetime').data('DateTimePicker').date(data.end);

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
        // beforeSend: function (xhr) {
        //     xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        // },
        type: (scheduleId ? 'put' : 'post'),
        dataType: 'json',
        data: $scheduleForm.serialize()
    });

    request.done(function (responseData, textStatus, jqXHR) {
        console.log(responseData)
    });

    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });
}
