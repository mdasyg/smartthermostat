var $actionTemplate = null;

function addNewAction($thisClick) {
    if ($.isEmptyObject(selectedDeviceAttributes)) {
        alert('No device selected. Please select one first');
        return false;
    }

    var $thisForm = $thisClick.closest('form');
    var $actionsContainer = $thisForm.find('.actions-container');

    var numberOfDeviceAttributes = Object.keys(selectedDeviceAttributes).length;
    var numberOfActions = $actionsContainer.children('.action').length;
    if (numberOfActions >= numberOfDeviceAttributes) {
        alert('Device has only (' + numberOfDeviceAttributes + ') attributes available.');
        return false;
    }

    var lastActionDomId = parseInt($actionsContainer.find('.action').last().attr('data-index'));
    if (!lastActionDomId) {
        lastActionDomId = 0;
    }
    var nextActionDomId = lastActionDomId + 1;

    var $newAction = $actionTemplate.clone();

    $newAction.attr('data-index', nextActionDomId);

    var propertyName = null;
    var propertyId = null;

    var $newActionInputs = $newAction.find('input');
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

    var $newActionSelects = $newAction.find('select');
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

    var newSelectOptions = [];
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
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-action')) {
                addNewAction($thisClick);
            }
        }
    });

});