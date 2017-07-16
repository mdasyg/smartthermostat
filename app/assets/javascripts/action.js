function addNewAction($containerToAppendActions, $actionTemplate, prefixForActionSubForm, actionData) {
    let lastActionDomId = parseInt($containerToAppendActions.find('.action').last().attr('data-index'));
    if (!lastActionDomId) {
        lastActionDomId = 0;
    }
    let nextActionDomId = lastActionDomId + 1;

    let $newAction = $actionTemplate.clone();

    $newAction.attr('data-index', nextActionDomId);

    let propertyName = null;
    let propertyId = null;
    //
    let $newActionInputs = $newAction.find('input');
    $newActionInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            propertyName = propertyName.replace('REPLACE_WITH_SCHEDULE_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyName = propertyName.replace('ACTION_INDEX', nextActionDomId);
            $(this).attr('name', propertyName);
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            propertyId = propertyId.replace('REPLACE_WITH_SCHEDULE_EVENT_FORM_PREFIX', prefixForActionSubForm);
            propertyId = propertyId.replace('ACTION_INDEX', nextActionDomId);
            propertyId = propertyId.replace('[', '_');
            propertyId = propertyId.replace(']', '_');
            $(this).attr('id', propertyId);
        }
    });

    console.log(actionData);

    if (actionData) {
        $newAction.find('.action-device-attributee-id').val(actionData.deviceAttributeId);
        $newAction.find('.schedule-event-action-device-attribute-name-placeholder').text(actionData.deviceAttributeName);
        // $newAction.find('.action-device-attribute-value').val(actionData.device_attribute_value);
    }

    $containerToAppendActions.append($newAction);

}

$(document).on('turbolinks:load', function () {
    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        let $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-action')) {
                addNewAction($thisClick);
            }
        }
    });

});