var $deviceForm = null;

function updateDevicePage(data) {
    // device status change
    $('#device-status-indicator-text').text(data.last_contact_text);
    if (data.device_status) {
        $('#device-status-indicator-text').removeClass('offline').addClass('online');
    } else {
        $('#device-status-indicator-text').removeClass('online').addClass('offline');
    }
    // update device attribute elements
    var $deviceAttributeElement = null;
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

function titleMove(event) {
    var title = this.legend.title;
    title.translate(((this.legend.legendWidth / 2) - (title.width / 2)), title.y);
}

function displayChart(chartData) {
    Highcharts.chart('smart-thermostat-analyzed-data-graph-container', {
        chart: {
            type: 'spline',
            events: {
                load: titleMove,
                redraw: titleMove
            }
        },
        title: {
            text: 'Room temperature gain timeline'
        },
        // subtitle: {
        //     text: 'Irregular time data in Highcharts JS'
        // },
        xAxis: {
            title: {
                text: 'Timeline (secs)'
            }
        },
        yAxis: {
            title: {
                text: 'Inside Temperature (*C)'
            }
        },
        legend: {
            title: {
                text: 'Outside Temperature (*C)',
                style: {
                    fontStyle: 'italic'
                }
            }
        },
        plotOptions: {
            spline: {
                marker: {
                    enabled: true
                }
            }
        },
        series: chartData
    });
}

function displaySmartThermostatComputedDatasetGraph() {
    var url = $('#get-smart-thermostat-analyzed-data').data('url');
    if (!url) {
        return false;
    }

    // attributes request
    var request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        type: 'get',
        dataType: 'json'
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result == 'ok') {
            displayChart(responseData.data);
        } else if (responseData.result == 'error') {
            alert('Error getting device chart data');
        } else {
            alert('Unknown error');
        }
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        alert(errorThrown + ': ' + textStatus);
    });
}

function getDeviceInfo() {
    var url = $('#get-device-status-info').data('url');
    if (!url) {
        return false;
    }

    // attributes request
    var request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        type: 'get',
        dataType: 'json'
    });
    request.done(function (responseData, textStatus, jqXHR) {
        updateDevicePage(responseData);
    });
    request.fail(function (jqXHR, textStatus, errorThrown) {
        console.log(jqXHR);
        console.log(textStatus);
        console.log(errorThrown);
        alert(errorThrown + ': ' + textStatus);
    });
    request.always(function () {
        setTimeout(getDeviceInfo, deviceDetailShowViewUpdateIntervalInSeconds * 1000);
    });
}

function getDeviceAttributes(deviceUid, returnAllAttributes, callback, extraParamsToCallback) {
    var data = {
        deviceUid: deviceUid
    };
    var url = $('#get-device-attributes-list-url').data('url');
    url = replaceUrlParams(url, data);

    // attributes request
    var request = $.ajax({
        url: url,
        beforeSend: function (xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        type: 'get',
        dataType: 'json',
        data: {
            return_all_attributes: returnAllAttributes
        }
    });
    request.done(function (responseData, textStatus, jqXHR) {
        if (responseData.result == 'ok') {
            var deviceAttributesData = [];
            responseData.data.forEach(function (deviceAttribute) {
                deviceAttributesData.push({
                    device_attribute_id: deviceAttribute.id,
                    device_attribute_name: deviceAttribute.name,
                    device_attribute_primitive_type_c_id: deviceAttribute.primitive_type_c_id
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
        alert(errorThrown + ': ' + textStatus);
    });
}

function updateSmartThermostatDeviceAttributesSelectOptions(deviceAttributes, extraParams) {
    var $smartThermostatDeviceAttributeSelector = extraParams.closestRow.find('select.smart-thermostat-device-attribute-selector');

    $smartThermostatDeviceAttributeSelector.find('option').remove();

    var $newSmartThermostatDeivceAttributeOption = null;
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
        var deviceUid = $(this).val();
        getDeviceAttributes(deviceUid, 1, updateSmartThermostatDeviceAttributesSelectOptions, {closestRow: $(this).closest('.row')});
    });

    displaySmartThermostatComputedDatasetGraph();

});
