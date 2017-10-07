function addNewAction($containerToAppendActions, $actionTemplate, prefixForActionSubForm, actionData) {
    var lastActionDomId = parseInt($containerToAppendActions.find('.action').last().attr('data-index'));
    if (!lastActionDomId) {
        lastActionDomId = 0;
    }
    var nextActionDomId = lastActionDomId + 1;

    var $newAction = $actionTemplate.clone();

    $newAction.attr('data-index', nextActionDomId);

    var propertyName = null;
    var propertyId = null;

    $actionStartValueContainer = $newAction.find('.action-device-attribute-start-value-container');
    if (actionData.device_attribute_primitive_type_c_id == deviceAttributePrimitiveTypesConstants['BOOL']['ID']) {
        $actionStartValueContainer.find('.action-device-attribute-start-value-not-bool').remove();
    } else {
        $actionStartValueContainer.find('.action-device-attribute-start-value-bool').remove();
    }

    $actionEndValueContainer = $newAction.find('.action-device-attribute-end-value-container');
    if (actionData.device_attribute_primitive_type_c_id == deviceAttributePrimitiveTypesConstants['BOOL']['ID']) {
        $actionEndValueContainer.find('.action-device-attribute-end-value-not-bool').remove();
    } else {
        $actionEndValueContainer.find('.action-device-attribute-end-value-bool').remove();
    }

    var $newActionInputs = $newAction.find('input');
    $newActionInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            propertyName = propertyName.replace('REPLACE_WITH_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyName = propertyName.replace('ACTION_INDEX', nextActionDomId);
            $(this).attr('name', propertyName);
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            propertyId = propertyId.replace('REPLACE_WITH_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyId = propertyId.replace('ACTION_INDEX', nextActionDomId);
            propertyId = propertyId.replace('[', '_');
            propertyId = propertyId.replace(']', '_');
            $(this).attr('id', propertyId);
        }
    });

    var $newActionSelects = $newAction.find('select');
    $newActionSelects.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            propertyName = propertyName.replace('REPLACE_WITH_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyName = propertyName.replace('ACTION_INDEX', nextActionDomId);
            $(this).attr('name', propertyName);
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            propertyId = propertyId.replace('REPLACE_WITH_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyId = propertyId.replace('ACTION_INDEX', nextActionDomId);
            propertyId = propertyId.replace('[', '_');
            propertyId = propertyId.replace(']', '_');
            $(this).attr('id', propertyId);
        }
    });

    if (actionData) {
        $newAction.find('.action-id').val(actionData.id);
        $newAction.find('.action-device-attribute-id').val(actionData.device_attribute_id);
        $newAction.find('.event-action-device-attribute-name-placeholder').text(actionData.device_attribute_name);
        $newAction.find('.action-device-attribute-start-value').val((actionData.device_attribute_primitive_type_c_id == deviceAttributePrimitiveTypesConstants['BOOL']['ID']) ? parseInt(actionData.device_attribute_start_value) : actionData.device_attribute_start_value);
        $newAction.find('.action-device-attribute-end-value').val((actionData.device_attribute_primitive_type_c_id == deviceAttributePrimitiveTypesConstants['BOOL']['ID']) ? parseInt(actionData.device_attribute_end_value) : actionData.device_attribute_end_value);
    }

    $containerToAppendActions.append($newAction);

}

$(document).on('turbolinks:load', function () {
    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-action')) {
                addNewAction($thisClick);
            }
        }
    });

});