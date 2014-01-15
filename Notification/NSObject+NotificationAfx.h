//
//  NSObject+NotificationAfx.h
//  Youplay
//
//  Created by Slavik on 12/20/13.
//  Copyright (c) 2013 apollobrowser.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (NotificationAfx)

// the key is the notifciation name, the value is selector name
- (void)registerNotification:(NSDictionary*)map;
- (void)unregisterNotification:(NSDictionary*)map;

@end
