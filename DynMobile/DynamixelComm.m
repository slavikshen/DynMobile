//
//  DynamixelComm.m
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "DynamixelComm.h"

#define DYNAMIXEL_COMM_RECEIVE_BUT_SIZE 512

@implementation DynamixelComm {
    
    BLE* _bt;
    
    unsigned char _receiveBuf[DYNAMIXEL_COMM_RECEIVE_BUT_SIZE];
    int _recevieBufLength;
    
}

@dynamic bluetooth;

-(BLE*)bluetooth {
    return _bt;
}

- (id)initWithBluetooth:(BLE*)bluetooth {
    self = [super init];
    if( self ) {
        _bt = bluetooth;
    }
    return self;
}


- (void)send:(unsigned char*)b {
    
//    unsigned char checksum = 0;
//    for(int i=0; i<(b[3]+1); i++)
//        checksum += b[i+2];
//    checksum = ~checksum;
//    b[b[3]+3] = checksum;
//    
//    NSInteger length = b[3]+4;
//    NSData* data = [NSData dataWithBytes:b length:length];
//    [_bt write:data];
    
    
    unsigned char* r = b+2;
    int len = *(r++);
    unsigned char* end = r+len;
    int sum = len;
    while( r < end ) {
        sum += *(r++);
    }
    sum %= 256;
    *end = sum;
    
    NSData* data = [NSData dataWithBytes:b length:len+4];
    [_bt write:data];

}

- (void)moveServo:(NSInteger)sid toPosition:(NSInteger)pos withSpeed:(NSInteger)speed {
    unsigned char outbuf[256] = {0XFF, 0XFF, sid, 7, INST_WRITE, P_GOAL_POSITION_L, pos % 256, pos / 256, speed % 256, speed / 256, 0X00}; // move to position with speed
    [self send:outbuf];
//    [_bt read];
}

- (void)setServo:(NSInteger)sid withSpeed:(NSInteger)speed {
    unsigned char outbuf[16] = {0XFF, 0XFF, 3, 0, sid, speed%256, 0X00}; // write two bytes for present position
    [self send:outbuf];
//    [_bt read];
}

- (void)setServo:(NSInteger)sid withPosition:(NSInteger)pos {
    unsigned char outbuf[16] = {0XFF, 0XFF, 4, 0, sid, pos>>8, pos%256, 0X00}; // write two bytes for present position
    [self send:outbuf];
//    [_bt read];
}

- (void)setServo:(NSInteger)sid withTorque:(NSInteger)value {
    unsigned char outbuf[16] = {0XFF, 0XFF, sid, 4, INST_WRITE, P_TORQUE_ENABLE, value, 0X00}; // write two bytes for present position
    [self send:outbuf];
//    [_bt read];
}

- (void)getServoPosition:(NSInteger)sid {
    unsigned char outbuf[16] = {0XFF, 0XFF, sid, 4, INST_READ, P_PRESENT_POSITION_L, 2, 0X00}; // read two bytes for present position
    [self send:outbuf];
//    [_bt read];
}

- (void)pingServo:(NSInteger)sid {
    unsigned char outbuf[16] = {0XFF, 0XFF, sid, 2, INST_PING, 0X00};
    [self send:outbuf];
//    [_bt read];
}

- (void)scanServos {
    
//    [_bt write:[NSData dataWithBytes:"Scan servo" length:10]];
//    
//    unsigned char outbuf[16] = {0XFF, 0XFF, 0xFE, 2, INST_PING, 0X00};
//    for( unsigned char sid = 1; sid < MAX_SERVO_COUNT+1; sid++ ) {
//        outbuf[2] = sid;
//        [self send:outbuf];
//    }
//    [_bt read];
//    double delayInSeconds = 1.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [_bt read];
//    });
    
}

- (void)didReceiveData:(unsigned char *) data length:(int)length {
    
    // check if the data begin with 0xFF
    int begin = length;
    for( int i = 0; i < length; i++) {
        if( data[i] == 0xFF && i+1 <length && data[i+1] == 0xFF ) {
            begin = i;
            break;
        }
    }
    
    if( begin < length & begin > 0 ) {
        // we have some thing left in the buf
        unsigned char* w = _receiveBuf+_recevieBufLength;
        memcpy(w, data, begin);
        _recevieBufLength += begin;
        // commit the content in the buf
        [self _commitStatus:_receiveBuf length:_recevieBufLength];
        _recevieBufLength = 0; // consumed
    }
    
    while( begin < length ) {
        // check the length of the status

        int lenOffset = begin+2;
        if( lenOffset < length ) {
            int statusLen = data[lenOffset];
            int end = begin + statusLen + 4;
            if( end < length ) {
                // do check sum later
                
                // the status is complete
                [self _commitStatus:data+lenOffset+1 length:statusLen];
                // continue to next status
                begin = end;
                continue;
            }
        }

        // the status is not completed
        // dump the content to the buffer
        unsigned char* w = _receiveBuf+_recevieBufLength;
        int leftLen = length-begin;
        memcpy(w, data, leftLen);
        _recevieBufLength += leftLen;
        break;
    }
    
}

- (void)_commitStatus:(unsigned char*)data length:(int)length {
    
    // the data must contain a complete status
    int sid = data[0];
    if( sid != 0xFE ) {
        // not a broadcast id
        // notify the existing of the servo
        [_delegate didReceiveStatusFromServo:sid];
    }
    
//    int len = data[3];
//    if( 3 == len ) {
//        // this status contains the control table
//        
//    }
    
}

@end
