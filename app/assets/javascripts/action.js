var $actionTemplate = null;

function addNewAction($thisClick) {
    let $thisForm = $thisClick.closest('form');
    let deviceUid = $thisForm.find('.schedule-device-selector').val();

    if (!deviceUid) {
        alert('Please select a device.');
        return false;
    }

    if ($.isEmptyObject(selectedDeviceAttributes)) {
        alert('Device has no attributes, please add some first.');
        return false;
    }

    let $actionsContainer = $thisForm.find('.actions-container');

    let numberOfDeviceAttributes = Object.keys(selectedDeviceAttributes).length;
    let numberOfActions = $actionsContainer.children('.action').length;
    if (numberOfActions >= numberOfDeviceAttributes) {
        alert('Device has only (' + numberOfDeviceAttributes + ') attributes available.');
        return false;
    }

    let lastActionDomId = parseInt($actionsContainer.find('.action').last().attr('data-index'));
    if (!lastActionDomId) {
        lastActionDomId = 0;
    }
    let nextActionDomId = lastActionDomId + 1;

    let $newAction = $actionTemplate.clone();

    $newAction.attr('data-index', nextActionDomId);

    let propertyName = null;
    let propertyId = null;

    let $newActionInputs = $newAction.find('input');
    $newActionInputs.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextActionDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextActionDomId));
        }
    });

    let $newActionSelects = $newAction.find('select');
    $newActionSelects.each(function () {
        propertyName = $(this).attr('name');
        if (propertyName) {
            $(this).attr('name', propertyName.replace('INDEX', nextActionDomId));
        }
        propertyId = $(this).attr('id');
        if (propertyId) {
            $(this).attr('id', propertyId.replace('INDEX', nextActionDomId));
        }
    });

    let newSelectOptions = [];
    $.each(selectedDeviceAttributes, function (key, value) {
        newSelectOptions.push($('<option>').attr('value', key).text(value));
    });
    $newAction.find('#action-device-attributes-select-box').empty().append(newSelectOptions);

    $actionsContainer.append($newAction);

}

$(document).on("turbolinks:load", function () {
    $actionTemplate = $(document.body).find('#action-template .action');

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