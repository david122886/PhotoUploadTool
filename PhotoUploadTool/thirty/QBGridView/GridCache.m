//
//  GridCache.m
//  Gridview
//
//  Created by midhun on 10/07/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GridCache.h"

static GridCache *cache = nil;

@implementation GridCache

@synthesize capacityPerType;

- (id)init {
	if ((self = [super init])) {
		allViews = [[NSMutableDictionary alloc] init];
		capacityPerType = 100;
	}
	return self;
}

+ (GridCache *)sharedCache {
	@synchronized(self){
		if (cache== nil) {
			cache = [[GridCache alloc] init];
		}
	}
	return cache;
}

/*
 To get the the reusable view with the identifier.
 */
- (UIView<ReusableView> *)dequeueReusableViewWithIdentifier:(NSString *)reuseIdentifier {
	if (!reuseIdentifier) {
		return nil;
	}
	NSMutableArray *views = [allViews objectForKey:reuseIdentifier];
	UIView<ReusableView> *view = [views lastObject];
	if (view) {
		[[view retain] autorelease];
		[views removeLastObject];
		return view;
	}
	return nil;
}
/*
 To Store the the reusable view with the identifier.
 */

- (void)enqueueReusableView:(UIView<ReusableView> *)view {
	if (![view reuseGridIdentifier]) {
		return;
	}
	NSMutableArray *views = [allViews objectForKey:[view reuseGridIdentifier]];
	if (views) {
		if ([views count] < capacityPerType) {
			[views addObject:view];
		}
	} else {
		views = [NSMutableArray arrayWithObject:view];
		[allViews setObject:views forKey:[view reuseGridIdentifier]];
	}
}
/*
 To remove the the reusable view with the identifier.
 */

- (void)removeReusableView:(UIView<ReusableView> *)view {
	if (![view reuseGridIdentifier]) {
		return;
	}
	NSMutableArray *views = [allViews objectForKey:[view reuseGridIdentifier]];
	if (views) {
		[views removeObjectIdenticalTo:view];
	}
}

- (void)clear {
	[allViews removeAllObjects];
}

@end
