var $deviceAttributeTemplate = null;
var $deviceAttributesContainer = null;

function addNewDeviceAttribute($thisClick) {
    var lastDeviceAttributeDomId = parseInt($deviceAttributesContainer.find('.device-attribute').last().attr('data-index'));
    if (!lastDeviceAttributeDomId) {
        lastDeviceAttributeDomId = 0;
    }
    var nextDeviceAttributeDomId = lastDeviceAttributeDomId + 1;

    var $newDeviceAttribute = $deviceAttributeTemplate.clone();

    $newDeviceAttribute.attr('data-index', nextDeviceAttributeDomId);

    var propertyName = null;
    var propertyId = null;

    var $newDeviceAttributeInputs = $newDeviceAttribute.find('input');
    $newDeviceAttributeInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDeviceAttributeDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDeviceAttributeDomId));
        }
    });

    var $newDeviceAttributeSelects = $newDeviceAttribute.find('select');
    $newDeviceAttributeSelects.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextDeviceAttributeDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextDeviceAttributeDomId));
        }
    });

    $deviceAttributesContainer.append($newDeviceAttribute);
}

$(document).on('turbolinks:load', function () { // we need this because of turbolinks
    $deviceAttributeTemplate = $('#device-attribute-template').find('.device-attribute');
    $deviceAttributesContainer = $(document.body).find('#device-form').find('.device-attributes-container');

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-device-attribute')) {
                addNewDeviceAttribute($thisClick);
            }
        }
    });

});
