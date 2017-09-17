#include <Ethernet.h>

#include "DataStructures.h"

#ifndef SCHEDULE_H
#define SCHEDULE_H

extern char flashReadBuffer[];

void powerOffSchedule(schedule schedules[], deviceAttribute stateOfAttributes[], byte scheduleIndex);
void checkScheduleStatus(EthernetClient &ethClient, schedule schedules[], deviceAttribute stateOfAttributes[]);
void disableSchedule(schedule schedules[], deviceAttribute stateOfAttributes[], byte scheduleIndex);

#endif
