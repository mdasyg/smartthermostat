var $scheduleModal = null;

function resetScheduleModal() {
    resetScheduleForm();
}

$(document).on('turbolinks:load', function () {
    $scheduleModal = $('#schedule-modal');
});