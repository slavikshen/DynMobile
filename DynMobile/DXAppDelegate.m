//
//  DXAppDelegate.m
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "DXAppDelegate.h"
#import "DXViewController.h"
#import "DXServoListViewController.h"


NSString* const kBLEDidConnect = @"BLEDidConnect";
NSString* const kBLEDidDisconnect = @"BLEDidDisconnect";
NSString* const kAppDelegateProperty_Servos = @"servos";


@implementation DXAppDelegate {
    NSTimer* _rssiTimer;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    BLE* bleShield = [[BLE alloc] init];
    [bleShield controlSetup];
    self.bluetooth = bleShield;
    
    // load servos
    NSMutableArray* servos = [NSMutableArray arrayWithCapacity:MAX_SERVO_COUNT];
    for( NSInteger sid = 1; sid < MAX_SERVO_COUNT+1; sid++ ) {
    
        ServoInfo* servo = [[ServoInfo alloc] init];
        servo.sid = sid;
        servo.position = 512;
        servo.speed = 100;
        
        [servos addObject:servo];
        
    }
    
    self.servos = servos;
    
    // Override point for customization after application launch.
    UIWindow* win = nil;
    win = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window = win;
    
    UISplitViewController* splitViewController = [[UISplitViewController alloc] init];
    
    DXViewController* mainViewController = [[DXViewController alloc] init];
    DXServoListViewController* servoListViewController = [[DXServoListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController* outlineController = [[UINavigationController alloc] initWithRootViewController:servoListViewController];
    UINavigationController* detailController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    splitViewController.viewControllers = @[outlineController,detailController];
    splitViewController.title = @"Dynamixel Mobile";
    
    win.rootViewController = splitViewController;
    
    [win makeKeyAndVisible];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setBluetooth:(BLE *)bluetooth {
 
    if(_bluetooth){
        _bluetooth.delegate = nil;
    }
    _bluetooth = bluetooth;
    if( _bluetooth ) {
        _bluetooth.delegate = self;
    }
    
}

- (void)setDynamixelCom:(DynamixelComm *)dynamixelCom {
    
    if( _dynamixelCom ) {
        _dynamixelCom.delegate = nil;
    }
    _dynamixelCom = dynamixelCom;
    if( _dynamixelCom ) {
        _dynamixelCom.delegate = self;
    }
    
}

-(void) readRSSITimer:(NSTimer *)timer
{
    [self.bluetooth readRSSI];
}

#pragma mark - BLEDelegate

-(void) bleDidConnect {
    NSLog(@"bleDidConnect");
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEDidConnect object:self.bluetooth];
    
//    self.servos = [NSMutableArray arrayWithCapacity:MAX_SERVO_COUNT];
//    // Schedule to read RSSI every 1 sec.
//    _rssiTimer = [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(readRSSITimer:) userInfo:nil repeats:YES];
//    double delayInSeconds = 2.0;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        DynamixelComm* dynCom = [[DynamixelComm alloc] initWithBluetooth:self.bluetooth];
//        self.dynamixelCom = dynCom;
//        [self.bluetooth read];
////        [dynCom scanServos];
//    });
//    // create a dyn com
    
    DynamixelComm* dynCom = [[DynamixelComm alloc] initWithBluetooth:self.bluetooth];
    self.dynamixelCom = dynCom;

}

-(void) bleDidDisconnect {
    NSLog(@"bleDidDisconnect");
    [[NSNotificationCenter defaultCenter] postNotificationName:kBLEDidDisconnect object:self.bluetooth];
//    [_rssiTimer invalidate];
}

-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    
    NSLog(@"RSSI: %@", rssi);
    
    NSInteger pos = rand()%200;
    [self.dynamixelCom setServo:5 withPosition:pos];
    
}

-(void) bleDidReceiveData:(unsigned char *) data length:(int) length {

    // change the dyn status according to the data received
    [_dynamixelCom didReceiveData:data length:length];
    
//    double delayInSeconds = 0.05f;
//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        [self.bluetooth read];
//    });
    
}

#pragma mark - DynamixelCommDelegate

- (void)didReceiveStatusFromServo:(NSInteger)sid {
    
    if( nil == [self servo:sid] ) {
     
        // create new servo instance
        ServoInfo* srv = [[ServoInfo alloc] init];
        srv.sid  = sid;
        
        [self insertObject:srv inServosAtIndex:_servos.count];
        
    }
    
    
}

#pragma mark - servo status

- (ServoInfo*)servo:(NSInteger)sid {
 
    ServoInfo* srv = nil;
    
    for( ServoInfo* s in _servos ) {
     
        if( s.sid == sid ) {
            srv = s;
            break;
        }
        
    }
    
    return srv;
    
}


- (void)insertObject:(ServoInfo*)sInfo inServosAtIndex:(NSUInteger)index {
    [_servos insertObject:sInfo atIndex:index];
}

- (void)removeObjectFromServosAtIndex:(NSUInteger)index {
    [_servos removeObjectAtIndex:index];
}

- (void)removeServosAtIndexes:(NSIndexSet*)indexes {
    [_servos removeObjectsAtIndexes:indexes];
}

- (void)clearServos {
    
    NSUInteger count = _servos.count;
    if( count ) {
        [self removeServosAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, count)]];
    }
    
}

@end
