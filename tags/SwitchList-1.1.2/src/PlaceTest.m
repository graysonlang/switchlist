//
//  PlaceTest.m
//  SwitchList
//
//  Created by Robert Bowdidge on 4/14/12
//
// Copyright (c)2012 Robert Bowdidge,
// All rights reserved.
// 

#import "PlaceTest.h"

#import "Place.h"

@implementation PlaceTest
- (void) testIsStaging {
	Place *stationA = [self makePlaceWithName: @"A"];
	STAssertEqualObjects(@"On Layout", [stationA kind], @"");
	STAssertFalse([stationA isStaging], @"");
	STAssertFalse([stationA isOffline], @"");
	
	[stationA setIsStaging: YES];
	STAssertEqualObjects(@"Staging", [stationA kind], @"");
	STAssertTrue([stationA isStaging], @"");
	STAssertFalse([stationA isOffline], @"");
	
	[stationA setIsStaging: NO];
	[stationA setIsOffline: YES];
	STAssertEqualObjects(@"Offline", [stationA kind], @"");
	STAssertFalse([stationA isStaging], @"");
	STAssertTrue([stationA isOffline], @"");
	
	[stationA setIsStaging: NO];
	[stationA setIsOffline: NO];
	STAssertEqualObjects(@"On Layout", [stationA kind], @"");
	STAssertFalse([stationA isStaging], @"");
	STAssertFalse([stationA isOffline], @"");
}

- (void) testTemplateDirectory {
	Place *stationA = [self makePlaceWithName: @"A"];
	
	NSDictionary *templateDictionary = [stationA templateDictionary];
	STAssertEqualObjects(@"A", [templateDictionary objectForKey: @"name"], @"");
	STAssertEqualsInt(1, [[templateDictionary objectForKey: @"allIndustriesSortedOrder"] count], @"");
}
@end
