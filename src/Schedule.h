#include <Ethernet.h>

#include "DataStructures.h"

#ifndef SCHEDULE_H
#define SCHEDULE_H

extern char flashReadBuffer[];

void checkScheduleStatus(EthernetClient &ethClient, schedule schedules[], deviceAttribute stateOfAttributes[]);

#endif
