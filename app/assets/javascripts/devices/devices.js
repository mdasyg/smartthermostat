function updateDevicePage(data) {
    $('#device-status-indicator-text').text(data.last_contact_text);
    let $deviceAttributeElement = null;
    data.device_attributes.forEach(function (deviceAttributeData) {
        $deviceAttributeElement = $('#device-attributes-container .device-attribute[data-id="' + deviceAttributeData.id + '"]');
        $deviceAttributeElement.find('.device-attribute-name').text((deviceAttributeData.name) ? deviceAttributeData.name : '-');
        $deviceAttributeElement.find('.device-attribute-min-value').text((deviceAttributeData.min_value) ? deviceAttributeData.min_value : '-');
        $deviceAttributeElement.find('.device-attribute-max-value').text((deviceAttributeData.max_value) ? deviceAttributeData.max_value : '-');
        $deviceAttributeElement.find('.device-attribute-set-value').text((deviceAttributeData.set_value) ? deviceAttributeData.set_value : 'Empty');
        $deviceAttributeElement.find('.device-attribute-current-value').text(deviceAttributeData.current_value_text);
    });
}

function getDeviceInfo() {
    let url = $('#get-device-status-info').data('url');
    if (!url) {
        return false;
    }

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
        updateDevicePage(responseData);
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });
    request.always(function () {
        setTimeout(getDeviceInfo, deviceDetailShowViewUpdateIntervalInSeconds * 1000);
    });
}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks

    $('.editable-device-attribute-set-value').editable();

    if ($('#get-device-status-info').data('url')) {
        setTimeout(getDeviceInfo, deviceDetailShowViewUpdateIntervalInSeconds * 1000);
    }

});
