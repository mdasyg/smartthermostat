// var selectedDeviceAttributes = {};
// var $calendar = null;
// var $scheduleModal = null;
// var $scheduleForm = null;
// var $scheduleId = null;
// var $actionsContainer = null;

// function updateSelectedDeviceAttributes($thisElement, initActionsContainer, actionData = null) {
//     let $thisForm = $thisElement.closest('form');
//     let deviceUid = $thisElement.val();
//     selectedDeviceAttributes = {};
//
//     if (!deviceUid) {
//         // alert('Please select a device.');
//         return false;
//     }
//
//     // var data = {
//     //     device_uid: deviceUid
//     // };
//     let url = $('#get-device-attributes-list-url').data('url');
//     url = replaceUrlParams(url, {deviceUid: deviceUid});
//     let request = $.ajax({
//         url: url,
//         type: 'get',
//         dataType: 'json',
//         // data: data
//     });
//     request.done(function (responseData, textStatus, jqXHR) {
//         let deviceAttributes = $(responseData);
//         selectedDeviceAttributes = {};
//         deviceAttributes.each(function () {
//             selectedDeviceAttributes[this.id] = this.name;
//         });
//         if (initActionsContainer) {
//             $actionsContainer.empty();
//             addNewAction($thisForm);
//         }
//         if (actionData) {
//             let $actionsFormContainer = $scheduleForm.find('.action-form-container');
//             actionData.forEach(function (action) {
//                 console.log(action);
//                 addNewAction($actionsFormContainer, action);
//             });
//         }
//     });
// }
//
// function initializeFullCalendar() {
//     $calendar.fullCalendar({
//         timezone: false,
//         header: {
//             left: 'prev,next today',
//             center: 'title',
//             right: 'month,agendaWeek,agendaDay listMonth'
//         },
//         selectable: true,
//         selectHelper: true,
//         editable: true,
//         eventLimit: true,
//         // events: '/schedules.json',
//         select: function (start, end, jsEvent) {
//             $('#schedule_datetime').data('DateTimePicker').date(start);
//             $scheduleModal.modal('show');
//             $calendar.fullCalendar('unselect');
//         },
//         eventClick: function (calEvent, jsEvent, view) {
//
//             // console.log(calEvent);
//             // console.log(calEvent.id);
//             // console.log(calEvent.device_uid);
//             // console.log(calEvent.name);
//             // console.log(calEvent.start.format('YYYY-MM-DD HH:mm:ss'));
//
//             $scheduleId.val(calEvent.id);
//             $scheduleForm.find('#schedule_device_uid').val(calEvent.device_uid);
//             $scheduleForm.find('#schedule_title').val(calEvent.name);
//             $scheduleForm.find('#schedule_datetime').data('DateTimePicker').date(calEvent.start);
//
//             updateSelectedDeviceAttributes($('.schedule-device-selector'), false, calEvent.actions);
//
//
//             $scheduleModal.modal('show');
//
//             return false;
//         },
//         // eventDrop: function (event, delta, revertFunc) {
//         //
//         //     console.log(event.title + " was dropped on " + event.start.format());
//         //
//         //     if (!confirm("Are you sure about this change?")) {
//         //         revertFunc();
//         //     }
//         //
//         // }
//     });
// }
//
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
// $scheduleModal = $('#schedule-modal');
// $scheduleForm = $scheduleModal.find('#schedule-form');
// $scheduleId = $scheduleForm.find('#schedule_id');
// $calendar = $('.calendar');
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
//     initializeFullCalendar();
//
//     $('#schedule_datetime').datetimepicker({
//         // locale: 'en',
//         // debug: true,
//         format: 'DD/MM/YYYY HH:mm',
//         extraFormats: ['YYYY-MM-DD HH:mm', 'YYYY-MM-DD HH:mm:ss'],
//         showClear: true,
//         sideBySide: true,
//         defaultDate: moment()
//     });
//
//     $('#schedule_is_recurrent').on('change', function () {
//         if ($(this).prop('checked')) {
//             $('#recurrent-entries').removeClass('hidden');
//         } else {
//             $('#recurrent-entries').addClass('hidden');
//         }
//     });
//
//     $('.schedule-device-selector').on('change', function (event) {
//         $actionsContainer.empty();
//         updateSelectedDeviceAttributes($(this), true);
//     });
//
//     $scheduleModal.on('hidden.bs.modal', function (event) {
//         resetScheduleModal();
//     });
// });
