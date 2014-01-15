//
//  ServoInfo.m
//  DynMobile
//
//  Created by Slavik on 1/13/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "ServoInfo.h"

@implementation ServoInfo {
    
    unsigned char _servoData[128];
    
}

@dynamic servoData;

- (unsigned char*)servoData {
    return _servoData;
}

- (void)updateWithRawData:(unsigned char*)rawData {
    
    unsigned char* servoData = _servoData;
    
    memcpy(servoData,rawData,sizeof(unsigned char)*128);
    
    int position = servoData[P_PRESENT_POSITION_L]+256*servoData[P_PRESENT_POSITION_H];
    unsigned int speed = servoData[P_PRESENT_SPEED_L]+256*servoData[P_PRESENT_SPEED_H];
    if( speed >= 1024 ) {
        speed -= 1024;
    }
    int load = servoData[P_PRESENT_LOAD_L]+256*servoData[P_PRESENT_LOAD_H];
    if(load >= 1024) load -= 1024;
    
    int voltage = servoData[P_PRESENT_VOLTAGE];
    int temperature = servoData[P_PRESENT_TEMPERATURE];
    int torque = servoData[P_TORQUE_ENABLE];
    
    self.position = position;
    self.speed = speed;
    self.load = load;
    self.voltage = voltage;
    self.temperature = temperature;
    self.torque = torque;
    
}

- (id)copyWithZone:(NSZone *)zone {
    
    ServoInfo* s = [[ServoInfo alloc] init];
    
    if (s) {
        
        s.sid = self.sid;
        s.position = self.position;
        s.speed = self.speed;
        s.load = self.load;
        s.voltage = self.voltage;
        s.temperature = self.temperature;
        s.torque = self.torque;
        
        memcpy(s->_servoData,self->_servoData,sizeof(unsigned char)*128);
        
    }
    
    return s;
    
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    NSInteger sid = self.sid;
    NSInteger position = self.position;
    NSInteger speed = self.speed;
    NSInteger load = self.load;
    NSInteger voltage = self.voltage;
    NSInteger temperature = self.temperature;
    NSInteger torque = self.torque;
    
    [aCoder encodeInteger:sid forKey:@"sid"];
    if( position ) {
        [aCoder encodeInteger:position forKey:@"position"];
    }
    if( speed ) {
        [aCoder encodeInteger:speed forKey:@"speed"];
    }
    if( load ) {
        [aCoder encodeInteger:load forKey:@"load"];
    }
    if( voltage ) {
        [aCoder encodeInteger:voltage forKey:@"voltage"];
    }
    if( temperature ) {
        [aCoder encodeInteger:temperature forKey:@"temperature"];
    }
    if( torque ) {
        [aCoder encodeInteger:torque forKey:@"torque"];
    }
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    if( self ) {
        
        NSInteger sid = [aDecoder decodeIntegerForKey:@"sid"];
        NSInteger position = [aDecoder decodeIntegerForKey:@"position"];
        NSInteger speed = [aDecoder decodeIntegerForKey:@"speed"];
        NSInteger load = [aDecoder decodeIntegerForKey:@"load"];
        NSInteger voltage = [aDecoder decodeIntegerForKey:@"voltage"];
        NSInteger temperature = [aDecoder decodeIntegerForKey:@"temperature"];
        NSInteger torque = [aDecoder decodeIntegerForKey:@"torque"];
        
        self.sid = sid;
        self.position = position;
        self.speed = speed;
        self.load = load;
        self.voltage = voltage;
        self.temperature = temperature;
        self.torque = torque;
        
    }
    
    return self;
    
}

@end
