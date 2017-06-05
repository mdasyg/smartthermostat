var $devicePropertyTemplate = null;
var $devicePropertiesContainer = null;

function addNewDeviceProperty($thisClick) {
    var lastDevicePropertyDomId = parseInt($devicePropertiesContainer.find('.device-property').last().attr('data-index'));
    if (!lastDevicePropertyDomId) {
        lastDevicePropertyDomId = 0;
    }
    var nextDevicePropertyDomId = lastDevicePropertyDomId + 1;

    var $newDeviceProperty = $devicePropertyTemplate.clone();

    $newDeviceProperty.attr('data-index', nextDevicePropertyDomId);

    var propertyName = null;
    var propertyId = null;

    var $newDevicePropertyInputs = $newDeviceProperty.find('input');
    $newDevicePropertyInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDevicePropertyDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDevicePropertyDomId));
        }
    });

    var $newDevicePropertySelects = $newDeviceProperty.find('select');
    $newDevicePropertySelects.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDevicePropertyDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDevicePropertyDomId));
        }
    });

    $devicePropertiesContainer.append($newDeviceProperty);
}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks
    $devicePropertyTemplate = $('#device-property-template').find('.device-property');
    $devicePropertiesContainer = $(document.body).find('#device-form').find('.device-properties-container');

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-device-property')) {
                addNewDeviceProperty($thisClick);
            }
        }
    });

});
