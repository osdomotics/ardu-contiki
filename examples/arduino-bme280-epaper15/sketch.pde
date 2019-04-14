/*
 * Sample e-paper arduino sketch using contiki features.
 * We turn the LED off
 *
 * Note that for a normal arduino sketch you won't have to include any
 * of the contiki-specific files here, the sketch should just work.
 */

extern "C" {
#include "arduino-process.h"
#include "rest-engine.h"
#include "net/netstack.h"
#include <SPI.h>
#include <epd1in54.h>
#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BME280.h>
#include "jsonparse.h"
#include "dev/batmon.h"
#include "ota-update.h"

extern resource_t res_cputemp, res_bmptemp, res_bmphum, res_bmppress,res_bmpatm,res_bmpalt, res_battery;

float bmptemp;
float bmppress;
float bmpatm;
float bmpalt;
float bmphum;
char  bmptemp_s[8];
char  bmppress_s[10];
char  bmpatm_s[8];
char  bmpalt_s[8];
char  bmphum_s[8];

#define SEALEVELPRESSURE_HPA (1013.25)
Adafruit_BME280 bme; // I2C

uint8_t led_pin=4;
uint8_t led_status;

void __cxa_pure_virtual() { while (1); }

}

#include <Adafruit_GFX.h>
#include <Fonts/arial_big.h>
#include <Fonts/arial_small.h>
#include <Fonts/arial_xsmall.h>

#define COLORED     0
#define UNCOLORED   1

Epd epd;

GFXcanvas1 canvas = GFXcanvas1 (200, 200);

extern resource_t res_htu21dtemp, res_htu21dhum, res_battery;

char flag = 1;

void setup (void)
{
    // switch off the led
    pinMode(led_pin, OUTPUT);
    digitalWrite(led_pin, HIGH);
    led_status=0;
    bool status;

    // default settings 0x77 or 0x76
    status = bme.begin(0x76);
    if (!status) {
        printf("Could not find a valid BME280 sensor, check wiring!");
    }
    // init coap resourcen
    rest_init_engine ();
    #pragma GCC diagnostic ignored "-Wwrite-strings"
    rest_activate_resource (&res_bmptemp, "s/temp");
    rest_activate_resource (&res_bmppress, "s/press");
    rest_activate_resource (&res_bmpatm, "s/atm");
    rest_activate_resource (&res_bmpalt, "s/alt");
    rest_activate_resource (&res_battery, "s/battery");
    rest_activate_resource (&res_cputemp, "s/cputemp");
    OTA_ACTIVATE_RESOURCES();
    #pragma GCC diagnostic pop

 //   NETSTACK_MAC.off(1);
    mcu_sleep_set(128);

    epd.Init (lut_full_update);
    epd.ClearFrameMemory(0xFF);   // bit set = white, bit reset = black
    epd.DisplayFrame();

    flag = 1;
}

void loop (void)
{
    uint16_t battery_voltage;
    char buf [20];

    bmptemp = bme.readTemperature();
    bmppress = bme.readPressure();
    bmpalt = bme.readAltitude(SEALEVELPRESSURE_HPA);
    bmpatm = bme.readPressure() / 100.0F;
    bmphum = bme.readHumidity();
    
    dtostrf(bmptemp , 0, 2, bmptemp_s );   
    dtostrf(bmppress , 0, 2, bmppress_s );
    dtostrf(bmpalt , 0, 2, bmpalt_s );
    dtostrf(bmpatm , 0, 2, bmpatm_s );
    dtostrf(bmphum , 0, 2, bmphum_s );
         
// Debug Print
    printf("Temp: %s\n",bmptemp_s);
    printf("Press: %s\n",bmppress_s);
    printf("Altitude: %s\n",bmpalt_s);
    printf("atm: %s\n",bmpatm_s);
    printf("hum: %s\n",bmphum_s);   

    batmon_get_voltage(&battery_voltage);

    switch (flag) {
     case 1 :
      epd.ClearFrameMemory(0xFF);   // bit set = white, bit reset = black
      epd.DisplayFrame();
       break;

     case 2 :
      epd.Init (lut_partial_update);
      canvas.fillScreen(0xffff);
      canvas.setTextColor(0x0000);

      canvas.setFont(&arialbd12pt7b);
      canvas.setCursor (14, 30);
      canvas.print (F("WOHNZIMMER"));
      //canvas.print (((float)battery_voltage)/1000, 1);

      canvas.setFont(&arialbd48pt7b);
      canvas.setCursor(10, 115);
      canvas.print (bmptemp, 1);

      canvas.setFont(&arialbd20pt7b);
      canvas.setCursor(50, 155);
      canvas.print (bmphum, 1);
      canvas.println (F("%"));

      canvas.setFont(&arialbd20pt7b);
      canvas.setCursor(20, 190);
      canvas.print (bmpatm, 1);
      canvas.println (F("hPa"));

      epd.SetFrameMemory(canvas.getBuffer(), 0, 0, 200, 200);
      epd.DisplayFrame();
      loop_periodic_set (LOOP_INTERVAL_AFTER_INIT);
      epd.Sleep();
     break;
    }

    flag++;

    if (flag == 3) flag = 2;

    printf ("\n");

}
