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

/***************************************************************************/
//      Function: Measure the distance to obstacles in front and print the distance
//                        value to the serial terminal.The measured distance is from
//                        the range 0 to 400cm(157 inches).
//      Hardware: Grove - Ultrasonic Ranger
/*****************************************************************************/

extern "C" {
#include "arduino-process.h"
#include "rest-engine.h"
#include "net/netstack.h"
#include "Ultrasonic.h"

extern resource_t res_battery, res_distance;
#define LED_PIN 4    /* LED Pin */

}

Ultrasonic ultrasonic(7);

long RangeInInches;
long RangeInCentimeters;

void setup (void)
{
    // switch off the led
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, HIGH);
    // init coap resourcen
    rest_init_engine ();
    rest_activate_resource (&res_battery, "s/battery");
    rest_activate_resource (&res_distance, "s/distance");

    printf("The distance to obstacles in front is: \n");
}

void loop (void)
{
//        RangeInInches = ultrasonic.MeasureInInches();
//        printf(" %d inch\n",RangeInInches);

        RangeInCentimeters = ultrasonic.MeasureInCentimeters(); // two measurements should keep an interval
        printf(" %d cm\n",RangeInCentimeters);//0~400cm
}

