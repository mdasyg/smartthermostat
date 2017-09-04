var $deviceAttributeTemplate = null;
var $deviceAttributesContainer = null;

function addNewDeviceAttribute($thisClick) {
    let lastDeviceAttributeDomId = parseInt($deviceAttributesContainer.find('.device-attribute').last().attr('data-index'));
    if (!lastDeviceAttributeDomId) {
        lastDeviceAttributeDomId = 0;
    }
    let nextDeviceAttributeDomId = lastDeviceAttributeDomId + 1;

    let $newDeviceAttribute = $deviceAttributeTemplate.clone();

    $newDeviceAttribute.attr('data-index', nextDeviceAttributeDomId);

    let propertyName = null;
    let propertyId = null;

    let $newDeviceAttributeInputs = $newDeviceAttribute.find('input');
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

    let $newDeviceAttributeSelects = $newDeviceAttribute.find('select');
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
        let $thisClick = $(this);
        // let thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-device-attribute')) {
                addNewDeviceAttribute($thisClick);
            }
        }
    });

    $('#device-form').on('change', '.device-attribute-direction-selector, .device-attribute-primitive-type-selector', function () {
        $thisDeviceAttribute = $(this).closest('.device-attribute');
        if ($thisDeviceAttribute.find('.device-attribute-direction-selector').val() == deviceAttributeDirectionConstants["FEEDBACK_ONLY"]["ID"]) {
            $thisDeviceAttribute.find('.device-attribute-set-value').val('').prop('disabled', true);
            if ($thisDeviceAttribute.find('.device-attribute-primitive-type-selector').val() == deviceAttributePrimitiveTypesConstants["BOOL"]["ID"]) {
                $thisDeviceAttribute.find('.device-attribute-min-value').val(deviceAttributeBoolValuesData["MIN"]["ID"]).prop('readonly', true);
                $thisDeviceAttribute.find('.device-attribute-max-value').val(deviceAttributeBoolValuesData["MAX"]["ID"]).prop('readonly', true);
            } else {
                $thisDeviceAttribute.find('.device-attribute-min-value, .device-attribute-max-value').val('').prop('readonly', true);
            }
        } else {
            $thisDeviceAttribute.find('.device-attribute-set-value').prop('disabled', false);
            if ($thisDeviceAttribute.find('.device-attribute-primitive-type-selector').val() == deviceAttributePrimitiveTypesConstants["BOOL"]["ID"]) {
                $thisDeviceAttribute.find('.device-attribute-min-value').val(deviceAttributeBoolValuesData["MIN"]["ID"]).prop('readonly', true);
                $thisDeviceAttribute.find('.device-attribute-max-value').val(deviceAttributeBoolValuesData["MAX"]["ID"]).prop('readonly', true);
            } else {
                $thisDeviceAttribute.find('.device-attribute-min-value, .device-attribute-max-value').val('').prop('readonly', false);
            }
        }

    });

});
