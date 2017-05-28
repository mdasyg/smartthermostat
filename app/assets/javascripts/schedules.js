$(document).on("turbolinks:load", function () {

    $('#schedule_datetime').datetimepicker({
        locale: 'en',
        format: "DD/MM/YYYY HH:mm:ss",
        extraFormats: ['YYYY-MM-DD HH:mm:ss'],
        showClear: true,
        sideBySide: true,
        defaultDate: moment()
    });
    // $('#schedule_datetime').data('DateTimePicker').format("DD/MM/YYYY HH:mm:ss")

});

