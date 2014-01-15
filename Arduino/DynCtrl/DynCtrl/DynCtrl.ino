//
// DynCtrl
//
// Description of the project
// Developed with [embedXcode](http://embedXcode.weebly.com)
//
// Author	 	Slavik
// 				Slavik
//
// Date			1/13/14 3:57 PM
// Version		1.0
//
// Copyright	© Slavik, 2014
// License		<#license#>
//
// See			ReadMe.txt for references
//

// Core library for code-sense
#if defined(WIRING) // Wiring specific
#include "Wiring.h"
#elif defined(MAPLE_IDE) // Maple specific
#include "WProgram.h"
#elif defined(MICRODUINO) // Microduino specific
#include "Arduino.h"
#elif defined(MPIDE) // chipKIT specific
#include "WProgram.h"
#elif defined(DIGISPARK) // Digispark specific
#include "Arduino.h"
#elif defined(ENERGIA) // LaunchPad MSP430, Stellaris and Tiva, Experimeter Board FR5739 specific
#include "Energia.h"
#elif defined(CORE_TEENSY) // Teensy specific
#include "WProgram.h"
#elif defined(ARDUINO) && (ARDUINO >= 100) // Arduino 1.0 and 1.5 specific
#include "Arduino.h"
#elif defined(ARDUINO) && (ARDUINO < 100) // Arduino 23 specific
#include "WProgram.h"
#else // error
#error Platform not defined
#endif

// Include application, user and local libraries
#include "LocalLibrary.h"

// Define variables and constants
//
// Brief	Name of the LED
// Details	Each board has a LED but connected to a different pin
//
uint8_t myLED = 7;

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
//#include <DynamixelSerial.h>

#include <DynamixelSerial.h>


#define DEBUG_COM 0


#define BUF_LEN 32
unsigned char buf[BUF_LEN] = {0};
unsigned char len = 0;

unsigned char rbuf[BUF_LEN] = {0};
unsigned char rlen = 0;

//
// Brief	Loop
// Details	Blink the LED
//
// Add loop code
#define MAX_SERVO_COUNT 24
unsigned char servos[MAX_SERVO_COUNT];
unsigned char servoCount = 0;
unsigned char currSyncServo = 0;

typedef enum {
  
    INST_TYPE_SET = 0,

    
} InstructionType;

void scanServos() {
 
    servoCount = 0;
    currSyncServo = 0;
    for( int sid = 1; sid < MAX_SERVO_COUNT+1; sid++ ) {
        int ret = Dynamixel.ledStatus(sid,ON);
        if( -1 != ret ) {

            Dynamixel.setTempLimit(sid,80);  // Set Max Temperature to 80 Celcius
            Dynamixel.setVoltageLimit(sid,65,160);  // Set Operating Voltage from 6.5v to 16v
            Dynamixel.setMaxTorque(sid,512);        // 50% of Torque
            Dynamixel.setSRL(sid,2);                // Set the SRL to Return All
            // add new servo
            servos[servoCount++] = sid;
        }
    }
    
    if( 2 == servoCount ) {
        digitalWrite(5,HIGH);
    }
    
}

void syncServoAtIndex(int index) {
    
    unsigned char sid = servos[index];
    int position = Dynamixel.readPosition(sid);
    unsigned char speed = Dynamixel.readSpeed(sid);
    // write the status back to bluetooth

    ble_write(0xFF);
    ble_write(0xFF);
    ble_write(4);
    
    int sum = 4;

    ble_write(sid);
    sum += sid;
    
    unsigned char posH = position >> 8;
    unsigned char posL = position & 0xFF;

    ble_write(posH);
    sum += posH;

    ble_write(posL);
    sum += posL;
    
    ble_write(speed);
    sum += speed;
    
    sum %= 256;
    ble_write(sum);
    
}

void handleSet(unsigned char* inst, int inst_len) {
    
    int sid = inst[0];
    int position = inst[1];
    position = position << 8 | inst[2];
    
    #if DEBUG_COM
    Serial.print("sid ");
    Serial.println(sid,10);
    Serial.print("position ");
    Serial.println(position,10);
    #endif
    
    if( inst_len > 3 ) {
        // there is speed
        int speed = inst[3];
        
        #if DEBUG_COM
        Serial.print("speed ");
        Serial.println(speed,10);
        #else
        Dynamixel.moveSpeed( sid, position, speed );
        #endif
        
    } else {
        // there is no speed, use the default
        #if !DEBUG_COM
        Dynamixel.move( sid, position );
        #endif
    }

//    delay(1000);
    
}

void handleInstruction(unsigned char* buf, int inst_len) {
    
    int type = buf[0];
    
#if DEBUG_COM
    Serial.print("Handle inst type ");
    Serial.println(type,10);
#endif

    if( type == INST_TYPE_SET ) {
//        digitalWrite(7,HIGH);
        handleSet( buf+1, inst_len-1 );
//        digitalWrite(7,LOW);
    }
}

void readInstructionsFromBLE() {
    
//    digitalWrite(5,HIGH);
    
    while( ble_available() && rlen < BUF_LEN ) {
        rbuf[rlen++] = ble_read();
    }
    
//    digitalWrite(5,LOW);
    
//#if DEBUG_COM
//    
//    if( rlen ) {
//        Serial.print(rlen, 10);
//        Serial.println(" chars in rbuf");
//        for( int i = 0; i < rlen; i++ ) {
//            Serial.print("0x");
//            Serial.print(rbuf[i],16);
//            Serial.print(" ");
//        }
//        Serial.println("");
//    }
//#endif


    int i = 0;
    // find the start of the instruction
    while( i+1 < rlen ) {
        
        if( rbuf[i] == 0xff && rbuf[i+1] == 0xff ) {
            
            #if DEBUG_COM
            Serial.print("Find inst begin at ");
            Serial.println(i,10);
            #endif
            
            // found a begin of the instruction
            int begin = i+2;
            int inst_len = rbuf[begin];
            int check_sum_offset = begin + inst_len + 1;
            if( check_sum_offset < rlen ) {
                // the instruction is complete
                // check sum
                unsigned char* instBegin = rbuf+begin;
                unsigned char* instEnd = rbuf+check_sum_offset;
                int sum = 0;
                unsigned char* r = instBegin;
                while( r < instEnd ) {
                    sum += *(r++);
                }
                sum %= 256; // use the mod
                if( sum == *instEnd ) {
                    // valid instruction
                    handleInstruction(instBegin+1,inst_len);
                } else {
                    #if DEBUG_COM
                    Serial.print("Check sum is not right");
                    #endif
                }
                // goto the end of the instruction
                i += inst_len + 4;
            } else {
                
                break;
                
//                #if DEBUG_COM
//                Serial.print("Inst is not long enough");
//                #endif
//                
//                // the last instruction is not complete
//                // move it to the head
//                int w = 0;
//                int r = i;
//                while( r < rlen ) {
//                    rbuf[w++] = rbuf[r++];
//                }
//                // leave the buf to next loop
//                return;
            }
            
        } else {
            i++;
        }
    }
    
    
    if( i < rlen ) {
        // something is left
        // the last instruction is not complete
        // move it to the head
        int w = 0;
        int r = i;
        while( r < rlen ) {
            rbuf[w++] = rbuf[r++];
        }
        rlen = w;
    } else {
        rlen = 0;
    }
    
}

//
// Brief	Setup
// Details	Define the pin the LED is connected to
//
// Add setup code
void setup() {
    
    pinMode(5, OUTPUT);
    pinMode(6, OUTPUT);
    pinMode(7, OUTPUT);
    
    // Init. and start BLE library.
    ble_begin();
    
#if DEBUG_COM

    Serial.begin(9600);
    
#else 

//    Dynamixel.begin(1000000,2);  // Inicialize the servo at 1Mbps and Pin Control 2
    delay(1000);
    scanServos();
    
#endif
    
    
}


void loop() {
    
    readInstructionsFromBLE();
    
#if !DEBUG_COM

    if( ble_connected() ) {
        // write the servo status to the remote
        if( currSyncServo > servoCount ) {
            currSyncServo = 0;
        }
        if( currSyncServo < servoCount ) {
            
            digitalWrite(7,HIGH);
            syncServoAtIndex(currSyncServo);
            delay(500);
            digitalWrite(7,LOW);
            delay(500);
        }
        currSyncServo++;
    }
    
#endif
    
//    while ( ble_available() ) {
//        
//        Serial.write(ble_read());
//    }
//    
//    while( Serial.available() ) {
//        
//        digitalWrite(6,HIGH);
//        
//        while ( Serial.available() && len < BUF_LEN )
//        {
//            unsigned char c = Serial.read();
//            buf[len++] = c;
//        }
//        
//        for (int i = 0; i < len; i++)
//            ble_write(buf[i]);
//        len = 0;
//        
//        delay(1000);
//        digitalWrite(6,LOW);
//        delay(1000);
//    }
    
    ble_do_events();
    
//    digitalWrite(myLED, HIGH);
//    delay(500);
//    digitalWrite(myLED, LOW);
//    delay(500);
    
}
