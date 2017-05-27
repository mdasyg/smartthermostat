$(document).on("turbolinks:load", function(){

    $('#schedule_datetime').datetimepicker({
        locale: 'en',
        // format:"dd/MM/yyyy",
        // extraFormats: ['YYYY-MM-DD'],
        showClear: true,
        useCurrent: true
    });
    $('#schedule_datetime').data('DateTimePicker').format("DD/MM/YYYY HH:mm:ss")

});

