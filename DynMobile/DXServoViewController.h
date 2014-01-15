//
//  DXServoViewController.h
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXServoViewController : UIViewController

@property(nonatomic,strong) ServoInfo* servo;

@property(nonatomic,strong) IBOutlet UISlider* positionSlider;
@property(nonatomic,strong) IBOutlet UISlider* speedSlider;

- (IBAction)userDidChangePosition:(UISlider*)sender;
- (IBAction)userDidChangeSpeed:(UISlider*)sender;

@end
