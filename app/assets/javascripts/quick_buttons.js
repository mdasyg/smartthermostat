var $quickButtonSubformsTemplates = null;
var $quickButtonEventActionSubFormTemplate = null;
var $quickButtonForm = null;
var $quickButtonDeviceSelector = null;
var $selectDeviceForQuickButtonContainer = null;
var $quickButtonEventActionsContainer = null;

function initSelectDeviceForQuickButtontSelect2() {
    $quickButtonDeviceSelector.select2({
        ajax: {
            dataType: 'json',
            url: $('#devices-search-url').data('url'),
            processResults: function (response, params) {
                if (response.result == 'ok') {
                    return {
                        results: response.data
                    };
                } else {
                    return {
                        results: []
                    };
                }
            },
            delay: 250
        },
        minimumInputLength: 1,
        dropdownParent: $selectDeviceForQuickButtonContainer,
        placeholder: 'Select device',
        allowClear: true,
        width: '100%' // responsive workaround
    });
}

function changeQuickButtonDevice(deviceAttributesData) {
    let $actionsContainer = $quickButtonEventActionsContainer.find('.actions-container').empty();
    let prefix = $quickButtonForm.find('.quick-button-event-form-prefix-for-subform').data('prefix');
    deviceAttributesData.forEach(function (deviceAttributeData) {
        addNewAction($actionsContainer, $quickButtonEventActionSubFormTemplate, prefix, deviceAttributeData);
    });
}

$(document).on('turbolinks:load', function () {
    $quickButtonSubformsTemplates = $('#quick-button-subforms-templates');
    $quickButtonEventActionSubFormTemplate = $quickButtonSubformsTemplates.find('.quick-button-action-template .action');
    $quickButtonForm = $('#quick-button-form');
    $selectDeviceForQuickButtonContainer = $quickButtonForm.find('.select-device-for-quick-button-container');
    $quickButtonEventActionsContainer = $quickButtonForm.find('.quick-button-event-actions-container');
    $quickButtonDeviceSelector = $selectDeviceForQuickButtonContainer.find('.quick-button-device-selector');

    $quickButtonDeviceSelector.on('select2:select', function () {
        let deviceUid = $quickButtonDeviceSelector.val();
        getDeviceAttributes(deviceUid, changeQuickButtonDevice);
    });

    initSelectDeviceForQuickButtontSelect2();
});