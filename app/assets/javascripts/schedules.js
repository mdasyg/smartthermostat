var selectedDeviceProperties = {};

function replaceUrlParams(url, deviceUid = null) {
    if (deviceUid) {
        url = url.replace('DEVICE_ID', deviceUid);
    }
    return url;
}

function updateSelectedDeviceProperties($thisElement, initActionsContainer) {
    var $thisForm = $thisElement.closest('form');
    var $actionsContainer = $thisForm.find('.actions-container');
    selectedDeviceProperties = {};


    var deviceUid = $thisElement.val();
    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    // var data = {
    //     device_uid: deviceUid
    // };
    var url = $('#get-device-properties-list-url').data('url');
    url = replaceUrlParams(url, deviceUid);
    var request = $.ajax({
        url: url,
        type: 'get',
        dataType: 'json',
        // data: data
    });
    request.done(function (responseData, textStatus, jqXHR) {
        var deviceProperties = $(responseData);
        selectedDeviceProperties = {};
        deviceProperties.each(function () {
            selectedDeviceProperties[this.id] = this.name;
        });
        if (initActionsContainer) {
            $actionsContainer.empty();
            addNewAction($thisForm);
        }
    });
}

$(document).on("turbolinks:load", function () {

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
        updateSelectedDeviceProperties($(this), true);
    });


    if (!!$('.schedule-device-selection').val()) {
        updateSelectedDeviceProperties($('.schedule-device-selection'), false);
    }

});

