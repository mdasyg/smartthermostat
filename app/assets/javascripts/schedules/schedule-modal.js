function resetScheduleModal() {
    // $scheduleForm.trigger('reset');
    $scheduleForm.find('#schedule_id').val('');
    $scheduleEventsContainer.empty();
    $scheduleEventDeviceSelector.val(null).trigger('change');
}
