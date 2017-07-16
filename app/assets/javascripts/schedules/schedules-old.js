// function saveSchedule($thisClick) {
//     let url = null;
//     if ($scheduleId.val()) {
//         url = $scheduleForm.data('update-url');
//         url = replaceUrlParams(url, {scheduleId: $scheduleId.val()});
//     } else {
//         url = $scheduleForm.data('create-url');
//     }
//     let request = $.ajax({
//         url: url,
//         beforeSend: function (xhr) {
//             xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
//         },
//         type: 'put',
//         dataType: 'json',
//         data: $scheduleForm.serialize()
//     });
//     request.done(function (responseData, textStatus, jqXHR) {
//         console.log(responseData);
//
//         $calendar.fullCalendar('renderEvent', responseData);
//         $scheduleModal.modal('hide');
//
//     });
//     request.fail(function (jqXHR, textStatus, errorThrown) {
//         console.log(jqXHR);
//         console.log(textStatus);
//         console.log(errorThrown);
//         // alert(errorThrown + ': ' + textStatus);
//     });
// }
//
// $(document).on('turbolinks:load', function () {
//
// $scheduleForm = $scheduleModal.find('#schedule-form');
// $scheduleId = $scheduleForm.find('#schedule_id');
// $actionsContainer = $scheduleForm.find('.actions-container');
//
//     $(document.body).on('click', '.action-button', function (event) {
//         event.stopPropagation();
//         let $thisClick = $(this);
//         // var thisRowId = ($thisClick.closest('.grid-row').data('id')) ? $thisClick.closest('.grid-row').data('id') : null;
//         if ($thisClick.hasClass('active')) {
//             if ($thisClick.hasClass('save-schedule')) {
//                 saveSchedule($thisClick);
//             }
//         }
//     });
//
// });
