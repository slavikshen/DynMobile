//
//  DXServoViewController.m
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import "DXServoViewController.h"

@interface DXServoViewController ()

@end

@implementation DXServoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setServo:(ServoInfo *)servo {
 
    _servo = servo;
    if( servo && [self isViewLoaded] ) {
        [self _refreshServoInfo];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if( _servo ) {
        [self _refreshServoInfo];
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)_refreshServoInfo {
    
    ServoInfo* s = self.servo;
    
    self.positionSlider.value = s.position;
    self.speedSlider.value = s.speed;
    
}

- (IBAction)userDidChangePosition:(UISlider*)sender {
    
    NSInteger pos = floorf(sender.value);
    NSInteger sid = self.servo.sid;
    [APP_DELEGATE.dynamixelCom setServo:sid withPosition:pos];
    
}

- (IBAction)userDidChangeSpeed:(UISlider*)sender {

    NSInteger speed = floorf(sender.value);
    NSInteger sid = self.servo.sid;
    [APP_DELEGATE.dynamixelCom setServo:sid withSpeed:speed];

}

@end
