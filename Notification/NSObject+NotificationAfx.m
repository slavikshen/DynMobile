//
//  NSObject+NotificationAfx.m
//  Youplay
//
//  Created by Slavik on 12/20/13.
//  Copyright (c) 2013 apollobrowser.com. All rights reserved.
//

#import "NSObject+NotificationAfx.h"

@implementation NSObject (NotificationAfx)

// the key is the notifciation name, the value is selector name
- (void)registerNotification:(NSDictionary*)map {

    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    NSArray* allKeys = map.allKeys;
    for( NSString* name in allKeys ) {
        NSString* selectorName = map[name];
        SEL sel = NSSelectorFromString(selectorName);
        [dc addObserver:self selector:sel name:name object:nil];
    }
    
}

- (void)unregisterNotification:(NSDictionary*)map {
    
    NSNotificationCenter* dc = [NSNotificationCenter defaultCenter];
    NSArray* allKeys = map.allKeys;
    for( NSString* name in allKeys ) {
        [dc removeObserver:self name:name object:nil];
    }
    
}


@end
