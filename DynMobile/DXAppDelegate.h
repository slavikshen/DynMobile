//
//  DXAppDelegate.h
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLE.h"
#import "DynamixelComm.h"
#import "ServoInfo.h"

UIKIT_EXTERN NSString* const kBLEDidConnect;
UIKIT_EXTERN NSString* const kBLEDidDisconnect;
UIKIT_EXTERN NSString* const kAppDelegateProperty_Servos;

@interface DXAppDelegate : UIResponder <UIApplicationDelegate,BLEDelegate,DynamixelCommDelegate>

@property (strong,nonatomic) UIWindow *window;

@property (strong,nonatomic) BLE* bluetooth;
@property (strong,nonatomic) DynamixelComm* dynamixelCom;

@property (strong,nonatomic) NSMutableArray* servos;

- (ServoInfo*)servo:(NSInteger)sid;

- (void)insertObject:(ServoInfo*)sInfo inServosAtIndex:(NSUInteger)index;
- (void)removeObjectFromServosAtIndex:(NSUInteger)index;
- (void)removeServosAtIndexes:(NSIndexSet*)indexes;
- (void)clearServos;

@end

#define APP_DELEGATE ((DXAppDelegate*)[UIApplication sharedApplication].delegate)
