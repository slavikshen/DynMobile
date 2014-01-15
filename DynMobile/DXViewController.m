//
//  DXViewController.m
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "DXViewController.h"

@interface DXViewController ()

@end

@implementation DXViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    [self _setup];
    return self;
    
}

- (void)_setup {
    
    
    [self registerNotification:@{
               kBLEDidConnect : @"_BLEDidConnect:",
            kBLEDidDisconnect : @"_BLEDidDisconnect:",
    }];
    
}

- (void)dealloc {
    
    [self unregisterNotification:@{
                 kBLEDidConnect : @"_BLEDidConnect:",
              kBLEDidDisconnect : @"_BLEDidDisconnect:",
    }];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self _refreshUI];
    
}

- (void)_refreshUI {
    BLE* ble = APP_DELEGATE.bluetooth;
    BOOL connected = [ble isConnected];
    [self.connectButton setEnabled:!connected];
}


- (IBAction)connect:(id)sender {
    
    if( ![self.spinner isAnimating] ) {
        [self _connect];
    }
    
}

- (void)_connect {
    
    DXAppDelegate* app = APP_DELEGATE;
    BLE* bleShield = app.bluetooth;
    
    if (bleShield.activePeripheral) {
        if(bleShield.activePeripheral.state == CBPeripheralStateConnected)
        {
            [[bleShield CM] cancelPeripheralConnection:[bleShield activePeripheral]];
            return;
        }
    }

    if (bleShield.peripherals)
        bleShield.peripherals = nil;

    [bleShield findBLEPeripherals:3];

    [NSTimer scheduledTimerWithTimeInterval:(float)3.0 target:self selector:@selector(connectionTimeout:) userInfo:nil repeats:NO];

    [self.spinner startAnimating];
    
}

- (void)connectionTimeout:(NSTimer*)timer {
    
    DXAppDelegate* app = APP_DELEGATE;
    BLE* bleShield = app.bluetooth;
    NSArray* peripherals = bleShield.peripherals;
    if(peripherals.count > 0)
    {
        [bleShield connectPeripheral:[peripherals objectAtIndex:0]];
    }
    else
    {
        [self.spinner stopAnimating];
    }
}


- (void)_BLEDidConnect:(NSNotification*)n {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        [self _refreshUI];
    });

}

- (void)_BLEDidDisconnect:(NSNotification*)n {

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        [self _refreshUI];
    });
    
}


@end
