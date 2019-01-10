/*
 * Sample arduino sketch using contiki features.
 * We turn the LED off
 * We allow read the moisture sensor
 * Unfortunately sleeping for long times in loop() isn't currently
 * possible, something turns off the CPU (including PWM outputs) if a
 * Proto-Thread is taking too long. We need to find out how to sleep in
 * a Contiki-compatible way.
 * Note that for a normal arduino sketch you won't have to include any
 * of the contiki-specific files here, the sketch should just work.
 */

extern "C" {
#include "arduino-process.h"
#include "rest-engine.h"
#include "net/netstack.h"
#include "ota-update.h"

extern resource_t res_led, res_battery, res_cputemp;

uint8_t led_pin=4;
uint8_t led_status;
}

void setup (void)
{
    // switch off the led
    pinMode(led_pin, OUTPUT);
    digitalWrite(led_pin, HIGH);
    led_status=0;
    // init coap resourcen
    rest_init_engine ();
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    rest_activate_resource (&res_led, "s/led");
    rest_activate_resource (&res_battery, "s/battery");
    rest_activate_resource (&res_cputemp, "s/cputemp");
    OTA_ACTIVATE_RESOURCES();
    #pragma GCC diagnostic pop

    // uncomment if you want this node to be a routing node and set the
    // correct options in project-conf.h and contiki-conf.h
    //NETSTACK_MAC.off(1);

    // uncoment if you want to set the loop interval at runtime
    //#define LOOP_INTERVAL_AFTER_INIT (60 * CLOCK_SECOND)    
    //loop_periodic_set (LOOP_INTERVAL_AFTER_INIT);

    mcu_sleep_set(128);
}

void loop (void)
{
	printf("Hello Merkurboard\n");
}
