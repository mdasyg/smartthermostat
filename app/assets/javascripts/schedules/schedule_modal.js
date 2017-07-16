function resetScheduleModal() {
    $scheduleForm.trigger('reset');
    $scheduleEventsContainer.empty();
    $scheduleEventDeviceSelector.val(null).trigger('change');
}
