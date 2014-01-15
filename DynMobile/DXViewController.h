//
//  DXViewController.h
//  DynMobile
//
//  Created by Slavik on 1/12/14.
//  Copyright (c) 2014 Slavik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXViewController : UIViewController

@property(nonatomic,strong) IBOutlet UIActivityIndicatorView* spinner;
@property(nonatomic,strong) IBOutlet UIButton* connectButton;

- (IBAction)connect:(id)sender;

@end
