var $deviceProperties = null;
var $thisForm = null;
var $devicePropertyTemplate = null;

function addNewDeviceProperty() {
    var lastDevicePropertyDomId = parseInt($deviceProperties.find('.device-property').last().attr('data-index'));
    if (!lastDevicePropertyDomId) {
        lastDevicePropertyDomId = 0;
    }
    var nextDevicePropertyDomId = lastDevicePropertyDomId + 1;

    var newDeviceProperty = $devicePropertyTemplate.clone();

    newDeviceProperty.attr('data-index', nextDevicePropertyDomId);

    var newDevicePropertyInputs = newDeviceProperty.find('input');
    newDevicePropertyInputs.each(function () {
        var propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDevicePropertyDomId));
        }
        var propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDevicePropertyDomId));
        }
    });

    var newDevicePropertySelects = newDeviceProperty.find('select');
    newDevicePropertySelects.each(function () {
        var propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDevicePropertyDomId));
        }
        var propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDevicePropertyDomId));
        }
    });

    $deviceProperties.append(newDeviceProperty);
}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks
    $devicePropertyTemplate = $('#device-property-template').find('.device-property');
    $thisForm = $(document.body).find('#device-form').find('form');
    $deviceProperties = $thisForm.find('.device-properties-wrapper');

    $thisForm.on('click', '.add-new-device-property-button', addNewDeviceProperty);
});
