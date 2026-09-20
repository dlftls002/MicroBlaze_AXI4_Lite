#ifndef SRC_AP_AP_MAIN_H_
#define SRC_AP_AP_MAIN_H_

#include <stdint.h>

#include "../driver/button/button.h"
#include "../driver/LED/LED.h"
#include "../driver/Switch/Switch.h"
#include "../driver/FND/FND.h"
#include "../HAL/SPI/SPI.h"

void ap_init();
void ap_execute();

#endif /* SRC_AP_AP_MAIN_H_ */
