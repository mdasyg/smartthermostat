var $valueTypeTemplate = null;

function addNewValueType($thisClick) {
    var $thisForm = $thisClick.closest('form');
    var $valueTypesContainer = $thisForm.find('#value-types-container');

    var $newValueType = $valueTypeTemplate.clone()

    $valueTypesContainer.append($newValueType);

}
$(document).on("turbolinks:load", function () { // we need this because of turbolinks
    $valueTypeTemplate = $('#value-type-template').find('.value-type');

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
