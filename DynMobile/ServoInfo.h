//
//  ServoInfo.h
//  DynMobile
//
//  Created by Slavik on 1/13/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServoInfo : NSObject

@property(nonatomic,assign) NSInteger sid;
@property(nonatomic,assign) NSInteger speed;
@property(nonatomic,assign) NSInteger position;
@property(nonatomic,assign) NSInteger load;
@property(nonatomic,assign) NSInteger voltage;
@property(nonatomic,assign) NSInteger temperature;
@property(nonatomic,assign) NSInteger torque;
@property(nonatomic,readonly) unsigned char* servoData;

- (void)updateWithRawData:(unsigned char*)rawData;

@end
