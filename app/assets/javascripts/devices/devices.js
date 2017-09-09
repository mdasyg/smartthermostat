var $deviceForm = null;

function updateDevicePage(data) {
    $('#device-status-indicator-text').text(data.last_contact_text);
    let $deviceAttributeElement = null;
    data.device_attributes.forEach(function (deviceAttributeData) {
        $deviceAttributeElement = $('#device-attributes-container .device-attribute[data-id="' + deviceAttributeData.id + '"]');
        $deviceAttributeElement.find('.device-attribute-name').text((deviceAttributeData.name) ? deviceAttributeData.name : '-');
        $deviceAttributeElement.find('.device-attribute-min-value').text((deviceAttributeData.min_value) ? deviceAttributeData.min_value : '-');
        $deviceAttributeElement.find('.device-attribute-max-value').text((deviceAttributeData.max_value) ? deviceAttributeData.max_value : '-');
        $deviceAttributeElement.find('.device-attribute-set-value').editable('setValue', deviceAttributeData.set_value);
        $deviceAttributeElement.find('.device-attribute-current-value').text(deviceAttributeData.current_value_text);
    });
}

function initSmartThermostatDeviceAttributesSourceSelectiorSelect2() {
    $('.smart-thermostat-device-attributes-source-selector.outside').select2({
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
        dropdownParent: $('.smart-thermostat-device-attributes-source-selector-container.outside'),
        minimumInputLength: 1,
        allowClear: false,
        width: '100%' // responsive workaround
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

function getDeviceAttributes(deviceUid, returnAllAttributes, callback, extraParamsToCallback = {}) {
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
        data: {
            return_all_attributes: returnAllAttributes
        }
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result == 'ok') {
            let deviceAttributesData = [];
            responseData.data.forEach(function (deviceAttribute) {
                deviceAttributesData.push({
                    device_attribute_id: deviceAttribute.id,
                    device_attribute_name: deviceAttribute.name
                });
            });
            callback(deviceAttributesData, extraParamsToCallback);
        } else {
            alert('Error getting device attributes');
        }
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        // alert(errorThrown + ': ' + textStatus);
    });
}

function updateSmartThermostatDeviceAttributesSelectOptions(deviceAttributes, extraParams) {
    let $smartThermostatDeviceAttributeSelector = extraParams.closestRow.find('select.smart-thermostat-device-attribute-selector');

    $smartThermostatDeviceAttributeSelector.find('option').remove();

    let $newSmartThermostatDeivceAttributeOption = null;
    deviceAttributes.forEach(function (deviceAttribute) {
        $newSmartThermostatDeivceAttributeOption = new Option(deviceAttribute.device_attribute_name, deviceAttribute.device_attribute_id);
        $smartThermostatDeviceAttributeSelector.append($newSmartThermostatDeivceAttributeOption);
    });

}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks
    $deviceForm = $('#device-form');

    initSmartThermostatDeviceAttributesSourceSelectiorSelect2();
    $('.editable-device-attribute-set-value').editable();

    if ($('#get-device-status-info').data('url')) {
        setTimeout(getDeviceInfo, deviceDetailShowViewUpdateIntervalInSeconds * 1000);
    }

    $('.smart-thermostat-device-attributes-source-selector').on('select2:select', function () {
        let deviceUid = $(this).val();
        getDeviceAttributes(deviceUid, 1, updateSmartThermostatDeviceAttributesSelectOptions, {closestRow: $(this).closest('.row')});
    });

});
