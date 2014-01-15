//
//  NSIndexSet+IndexPath.m
//  Apollo
//
//  Created by Slavik on 11-8-3.
//  Copyright 2011年 ihanghai.com. All rights reserved.
//

#import "NSIndexSet+IndexPath.h"


@implementation NSIndexSet (NSIndexSet_IndexPath)

- (NSArray*)indexPathes:(NSUInteger)section {

	NSMutableArray* array = [NSMutableArray arrayWithCapacity:self.count];
	[self enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL* stop) {
		NSIndexPath* indexPath = [NSIndexPath indexPathForRow:idx inSection:section];
		[array addObject:indexPath];
	}];
	return array;
}

@end
