//
//  DynamixelComm.h
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAX_SERVO_COUNT 24

//--- Control Table Address ---

#define P_MODEL_NUMBER_L      0
#define P_MODOEL_NUMBER_H     1
#define P_VERSION             2
#define P_ID                  3
#define P_BAUD_RATE           4
#define P_RETURN_DELAY_TIME   5
#define P_CW_ANGLE_LIMIT_L    6
#define P_CW_ANGLE_LIMIT_H    7
#define P_CCW_ANGLE_LIMIT_L   8
#define P_CCW_ANGLE_LIMIT_H   9
#define P_SYSTEM_DATA2        10
#define P_LIMIT_TEMPERATURE   11
#define P_DOWN_LIMIT_VOLTAGE  12
#define P_UP_LIMIT_VOLTAGE    13
#define P_MAX_TORQUE_L        14
#define P_MAX_TORQUE_H        15
#define P_RETURN_LEVEL        16
#define P_ALARM_LED           17
#define P_ALARM_SHUTDOWN      18
#define P_OPERATING_MODE      19
#define P_KP                  20    // These names seem to suggest some form of PID controller
#define P_KD                  21    // but the AX-12 manual calls address 20-23 up/down calibration
#define P_KI                  22    // to compensate for potentiometer inaccuracies
#define P_IDAMP               23

#define P_TORQUE_ENABLE         24
#define P_LED                   25
#define P_CW_COMPLIANCE_MARGIN  26
#define P_CCW_COMPLIANCE_MARGIN 27
#define P_CW_COMPLIANCE_SLOPE   28
#define P_CCW_COMPLIANCE_SLOPE  29
#define P_GOAL_POSITION_L       30
#define P_GOAL_POSITION_H       31
#define P_GOAL_SPEED_L          32
#define P_GOAL_SPEED_H          33
#define P_TORQUE_LIMIT_L        34
#define P_TORQUE_LIMIT_H        35
#define P_PRESENT_POSITION_L    36
#define P_PRESENT_POSITION_H    37
#define P_PRESENT_SPEED_L       38
#define P_PRESENT_SPEED_H       39
#define P_PRESENT_LOAD_L        40
#define P_PRESENT_LOAD_H        41
#define P_PRESENT_VOLTAGE       42
#define P_PRESENT_TEMPERATURE   43
#define P_REGISTERED_INSTRUCTION 44
#define P_PAUSE_TIME            45
#define P_MOVING                46
#define P_LOCK                  47
#define P_PUNCH_L               48
#define P_PUNCH_H               49

#define INST_PING               1
#define INST_READ               2
#define INST_WRITE              3
#define INST_REG_WRITE          4
#define INST_ACTION             5
#define INST_RESET              6
#define INST_SYNC_WRITE         131

@protocol DynamixelCommDelegate <NSObject>

- (void)didReceiveStatusFromServo:(NSInteger)sid;

@end


@interface DynamixelComm : NSObject

@property(nonatomic,readonly) BLE* bluetooth;
@property(nonatomic,assign) id<DynamixelCommDelegate> delegate;

- (id)initWithBluetooth:(BLE*)bluetooth;

- (void)moveServo:(NSInteger)sid toPosition:(NSInteger)pos withSpeed:(NSInteger)speed;
- (void)setServo:(NSInteger)sid withSpeed:(NSInteger)speed;
- (void)setServo:(NSInteger)sid withPosition:(NSInteger)pos;
- (void)setServo:(NSInteger)sid withTorque:(NSInteger)torque;
- (void)getServoPosition:(NSInteger)sid;
- (void)pingServo:(NSInteger)sid;
- (void)scanServos;

- (void)didReceiveData:(unsigned char *) data length:(int)length;

@end
