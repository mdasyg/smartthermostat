// need to be initialized on turblinks:load otherwise is empty
var $valueTypeTemplate = null;
var $valueTypesContainer = null;

function addNewValueType($thisClick) {
    var lastValueTypeDomId = parseInt($valueTypesContainer.find('.value-type').last().attr('data-index'));
    if (!lastValueTypeDomId) {
        lastValueTypeDomId = 0;
    }
    var nextValueTypeDomId = lastValueTypeDomId + 1;

    var $newValueType = $valueTypeTemplate.clone();

    $newValueType.attr('data-index', nextValueTypeDomId);

    var valueTypeName = null;
    var valueTypeId = null;

    var $newValueTypeInputs = $newValueType.find('input');
    $newValueTypeInputs.each(function () {
        valueTypeName = $(this).attr('name');
        if (valueTypeName) {
            $(this).attr('name', valueTypeName.replace('INDEX', nextValueTypeDomId));
        }
        valueTypeId = $(this).attr('id');
        if (valueTypeId) {
            $(this).attr('id', valueTypeId.replace('INDEX', nextValueTypeDomId));
        }
    });

    var $newValueTypeSelects = $newValueType.find('select');
    $newValueTypeSelects.each(function () {
        valueTypeName = $(this).attr('name');
        if (valueTypeName) {
            $(this).attr('name', valueTypeName.replace('INDEX', nextValueTypeDomId));
        }
        valueTypeId = $(this).attr('id');
        if (valueTypeId) {
            $(this).attr('id', valueTypeId.replace('INDEX', nextValueTypeDomId));
        }
    });

    $valueTypesContainer.append($newValueType);
}

$(document).on("turbolinks:load", function () { // we need this because of turbolinks

    $valueTypeTemplate = $('#value-type-template').find('.value-type');
    $valueTypesContainer = $(document.body).find('#value-types-container');

    $(document.body).on('click', '.action-button', function (event) {
        event.stopPropagation();
        var $thisClick = $(this);
        // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
        if ($thisClick.hasClass('active')) {
            if ($thisClick.hasClass('add-new-value-type')) {
                addNewValueType($thisClick);
            }
        }
    });

});
