//
//  EntireLayoutTest.m
//  SwitchList
//
//  Created by bowdidge on 10/26/10.
//
// Copyright (c)2010 Robert Bowdidge,
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
// OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
// LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE.

#import "EntireLayoutTest.h"

#import "Cargo.h"
#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "InduYard.h"
#import "Industry.h"
#import "Place.h"
#import "ScheduledTrain.h"
#import "Yard.h"


// Tests functionality in EntireLayout class - mostly whether global queries work.

@implementation EntireLayoutTest

- (void) testSetName {
	[self makeSimpleLayout];
	
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[entireLayout setLayoutName: @"Test"];
	STAssertEqualObjects([entireLayout layoutName], @"Test", @".  Name does not match.");
	// TODO(bowdidge): For now, just check not-nil as opposed to actually within seconds of now.
	STAssertNotNil([entireLayout currentDate], @".  Date not equal to today.");
}

// Checks that the workbench object exists in the layout object once we request it.
- (void) testWorkbench {
	// Make sure we allocate one and only one workbench.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	// Populate industry stuff.
	Industry *workbenchIndustry = [entireLayout workbenchIndustry];
	STAssertNotNil([entireLayout workbench], @"Workbench not defined.");
	Place *workbench = [entireLayout workbench];
	STAssertFalse([workbench isStaging], @"Workbench should not be staging.");
	STAssertTrue([workbench isOffline], @"Workbench should be offline.");
	STAssertEquals([[entireLayout allStations] count], (NSUInteger) 1, @"Wrong number of Places");
	STAssertEqualObjects([workbench name], @"Workbench", @"Name not correct.");
}

- (void) testPreferences {
	// TODO(bowdidge): Test we can read it back.

}
	
- (void) testAllFreightCars {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	STAssertEquals([[entireLayout allFreightCars] count], (NSUInteger) 2, @"Wrong number of total freight cars");
	STAssertEquals([[entireLayout allAvailableFreightCars] count], (NSUInteger) 1,  @"Wrong number of available freight cars");
	STAssertEquals([[entireLayout allReservedFreightCars] count], (NSUInteger) 0, @"Wrong number of reserved freight cars");
}

- (void) testFreightCarsOnWorkbench {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
    FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[car2 setCurrentLocation: workbenchIndustry];
	
	STAssertEquals([[entireLayout allFreightCars] count], (NSUInteger) 2, @"Wrong number of total freight cars");
	// Make sure we don't count the car on the workbench as available.
	STAssertEquals([[entireLayout allAvailableFreightCars] count], (NSUInteger) 1, @"Wrong number of available freight cars");
	// Make sure neither car has a cargo.
	STAssertEquals([[entireLayout allReservedFreightCars] count], (NSUInteger) 0, @"Wrong number of reserved freight cars");
}

- (void) testFreightCars {
	// Unit tests for freight cars.
	// TODO(bowdidge) Move to own section.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	id workbenchIndustry = [entireLayout workbenchIndustry];
	FreightCar *car1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *car2 = [self makeFreightCarWithReportingMarks: @"DRG&W 99999"];
	FreightCar *car3 = [self makeFreightCarWithReportingMarks: @"UP  2222"];
	FreightCar *car4 = [self makeFreightCarWithReportingMarks: @"LA2X 9999"];
	
	STAssertEqualObjects(@"SP", [car1 initials], @"Car initials should be SP, were %@", [car1 initials]);
	STAssertEqualObjects(@"1", [car1 number], @"Car number should be 1, was %@", [car1 initials]);

	STAssertEqualObjects(@"DRG&W", [car2 initials], @"Car initials should be DRG&W, were %@", [car2 initials]);
	STAssertEqualObjects(@"99999", [car2 number], @"Car number should be 99999, was %@", [car2 initials]);

	STAssertEqualObjects(@"UP", [car3 initials], @"Car initials should be UP, were %@", [car3 initials]);
	STAssertEqualObjects(@"2222", [car3 number], @"Car number should be 22222, was %@", [car3 initials]);

	STAssertEqualObjects(@"LA2X", [car4 initials], @"Car initials should be LA2X, were %@", [car4 initials]);
	STAssertEqualObjects(@"9999", [car4 number], @"Car number should be 9999, was %@", [car4 initials]);
}

- (void) testFreightCarCargos {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP2"];

	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc1 setLoaded: NO];

	// Cars that are empty and unassigned or empty and assigned should appear the same way.
	STAssertEqualObjects(@"empty", [fc1 cargoDescription], @"");
	STAssertEqualObjects(@"empty", [fc2 cargoDescription], @"");

	[fc1 setIsLoaded: YES];
	STAssertEqualObjects(@"Foo", [fc1 cargoDescription], @"");
}

- (void) testAllFreightCarsAtDestination {
	[self makeThreeStationLayout];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP2"];
	
	Cargo *c1 = [self makeCargo: @"Foo"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	
	// fc1 has no cargo.
	[fc1 setCurrentLocation: [self industryAtStation:@"A"]];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc1], @"Car without cargo shouldn't be at destination.");
	

	// fc2 has a cargo, but the car isn't at source or dest.
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	[fc2 setCargo: c1];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
	
	// fc2 has a cargo, is unloaded, and is at source.
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setIsLoaded: NO];
	STAssertTrue([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");

	// If fc2 is loaded, it's not at the next destination.
	[fc2 setIsLoaded: YES];
	[fc2 setCurrentLocation: [self industryAtStation: @"C"]];
	STAssertFalse([[entireLayout_ allFreightCarsAtDestination] containsObject: fc2], @"Car not at src or dest not at destination.");
}

- (void) testAllFreightCarsAtDestinationInStaging {
	// TODO(bowdidge): Fill in.
}

- (void) testAllFreightCarsInTrains {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: @"SP 1"];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: @"SP 2"];
	[myTrain addFreightCarsObject: fc1];
	
	STAssertEquals([[entireLayout allFreightCars] count], (NSUInteger) 2, @"Wrong total number of cars");
	STAssertEquals([[entireLayout allFreightCarsNotInTrain] count], (NSUInteger) 1, @"Wrong number of cars not in train");
	STAssertTrue([[myTrain freightCars] containsObject: fc1], @"freight car 1 should be in train.");
	STAssertFalse([[myTrain freightCars] containsObject: fc2], @"freight car 2 should not be in train.");
}


- (void) testAllStations {
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @"B"];
	Place *placeC = [self makePlaceWithName: @"C"];
	[placeB setIsStaging: YES];

	// Workbench counts as a station.
	STAssertEquals([[entireLayout allStations] count], (NSUInteger) 4, @"Wrong number of stations");
	STAssertEquals([[entireLayout allStationsInStaging] count], (NSUInteger) 1, @"Wrong number of stations in staging");
	STAssertEquals([[entireLayout allStationNamesInStaging] count], (NSUInteger) 1, @"Wrong number of station names in staging.");
	STAssertTrue([[entireLayout allStationNamesInStaging] containsObject: @"B"], @"Place A not in all station names in staging.");
}

// Make sure we correctly handle valid and invalid names.
- (void) testStationWithName {
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
    Place *placeA = [self makePlaceWithName: @"A"];
	
	STAssertEqualObjects([entireLayout stationWithName: @"A"], placeA, @"Check existence of A");
	STAssertNil([entireLayout stationWithName: @"Bogus"], @"Check bogus name rejected");
	STAssertNil([entireLayout stationWithName: nil], @"Check NULL rejected.");	
}

- (void) disableTestStationValidation {
	Place *placeA = [self makePlaceWithName: @"A"];
	Place *placeB = [self makePlaceWithName: @""];
	NSString *proposedNameA = @"A";
	NSString *proposedNameB = @"B";
	NSError *error = nil;
	STAssertTrue([placeB validateName: &proposedNameB error:&error], @"B should be legal name for place.");
	STAssertNil(error, @"Error not nil.");
 	STAssertFalse([placeB validateName: &proposedNameA error:&error], @"A should not be legal name for place.");
	STAssertNotNil(error, @"Error should be non-nil");
}								 

- (void) testAllIndustries {
	// TODO(bowdidge): Test that yards are included.
	// Make sure the workbench industry is in the workbench place.
	id entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	Place *placeA = [self makePlaceWithName: @"A"];
	
	STAssertEquals([[entireLayout allIndustries] count], (NSUInteger) 1, @"Wrong number of industries");
}

- (void) testAllCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	
	STAssertEquals([[entireLayout allValidCargos] count], (NSUInteger) 1, @"Wrong number of cargos");
	STAssertTrue([[entireLayout allValidCargos] containsObject: c1], @"cargo isn't in list.");
}

- (void) testAllFixedRateCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];

	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setPriority: [NSNumber numberWithBool: YES]];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEquals([[entireLayout allFixedRateCargos] count], (NSUInteger) 1, @"Wrong number of cargos");
	STAssertTrue([[entireLayout allFixedRateCargos] containsObject: c2], @"cargo isn't in list.");
}	 

- (void) testAllNonFixedRateCargo {
	EntireLayout *entireLayout = [[EntireLayout alloc] initWithMOC: context_];
	[self makeThreeStationLayout];
	
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setPriority: [NSNumber numberWithBool: YES]];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	
	STAssertEquals([[entireLayout allNonFixedRateCargos] count], (NSUInteger) 1, @"Wrong number of cargos");
	STAssertTrue([[entireLayout allNonFixedRateCargos] containsObject: c1], @"cargo isn't in list.");
}

- (void) testAllCarsInTrainSortedInVisitOrder {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allCars = [entireLayout_ allCarsInTrainSortedByVisitOrder: myTrain1 withDoorAssignments: nil];
	STAssertEquals([allCars count], (NSUInteger) 2, @"Not enough cars in train.");
	// First A->B car
	STAssertEqualObjects([[[allCars objectAtIndex: 0] cargo] cargoDescription], @"a to b", @"Cars out of order");
    // Then B->C Car									
	STAssertEqualObjects([[[allCars objectAtIndex: 1] cargo] cargoDescription], @"b to c", @"Cars out of order.");
}

// TODO(bowdidge): Make sure works for industries without doors, etc.
- (void) testAllCarsInTrainSortedInVisitOrderWithDoors {
	[self makeThreeStationLayout];

	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc2 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	
	[myTrain setStopsString: @"A,B,C"];
	[self setTrain: myTrain acceptsCarTypes: @"XM"];

	Cargo *c1 = [self makeCargo: @"a to b"];
	[c1 setSource: [self industryAtStation: @"A"]];
	[c1 setDestination: [self industryAtStation: @"B"]];
	[fc1 setCargo: c1];
	[fc2 setCargo: c1];
	[fc1 setIsLoaded: YES];
	[fc2 setIsLoaded: YES];
	[fc1 setCurrentLocation: [self industryAtStation: @"A"]];
	[fc2 setCurrentLocation: [self industryAtStation: @"A"]];
	
	Industry *bIndustry = [self industryAtStation: @"B"];
	[bIndustry setHasDoors: YES];
	[bIndustry setNumberOfDoors: [NSNumber numberWithInt: 2]];
	
	DoorAssignmentRecorder *doorAssignments = [[[DoorAssignmentRecorder alloc] init] autorelease];
	[doorAssignments setCar: fc1 destinedForIndustry: bIndustry door:2];
	[doorAssignments setCar: fc2 destinedForIndustry: bIndustry door:1];
	
	[myTrain addFreightCarsObject: fc1];
	[myTrain addFreightCarsObject: fc2];
	STAssertEquals([[[entireLayout_ trainWithName: @"MyTrain"] freightCars] count], (NSUInteger) 2, @"Not enough cars in train.");

	// Now to the test
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *allCars = [entireLayout_ allCarsInTrainSortedByVisitOrder: myTrain1 withDoorAssignments: doorAssignments];
	NSLog(@"%@", allCars);
	STAssertEquals([allCars count], (NSUInteger) 2, @"Not enough cars in train.");
	// First car for door 1.
	STAssertEquals(fc2, [allCars objectAtIndex: 0], @"Cars out of order");
    // Then car for door 2.
	STAssertEquals(fc1, [allCars objectAtIndex: 1], @"Cars out of order.");
}

- (void) testStationStops {
	[self makeThreeStationLayout];
	[self makeThreeStationTrain];
	
	ScheduledTrain *myTrain1 = [[entireLayout_ allTrains] lastObject];
	NSArray *stops = [entireLayout_ stationStopsForTrain: myTrain1];
	
	STAssertTrue(3 ==[stops count], @"Incorrect number of stops for train");
	STAssertEqualObjects([entireLayout_ stationWithName: @"A"],
						  [stops objectAtIndex: 0], @"A not first station.");
	STAssertEqualObjects([entireLayout_ stationWithName: @"B"],
						 [stops objectAtIndex: 1], @"B not second station.");
	STAssertEqualObjects([entireLayout_ stationWithName: @"C"],
						 [stops objectAtIndex: 2], @"C not third station.");
}

// TODO(bowdidge): Move to ScheduledTrainTest.
- (void) testAcceptsCar {
	ScheduledTrain *myTrain = [self makeTrainWithName: @"MyTrain"];
	FreightCar *fc1 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_1_NAME];
	[fc1 setCarTypeRel: [entireLayout_ carTypeForName: @"XM"]];
	FreightCar *fc2 = [self makeFreightCarWithReportingMarks: FREIGHT_CAR_2_NAME];
	[fc2 setCarTypeRel: [entireLayout_ carTypeForName: @"XA"]];

	[myTrain setStopsString: @"A,B,C"];
	[self setTrain: myTrain acceptsCarTypes: @"XM"];
	
	STAssertTrue([myTrain acceptsCar: fc1], @"Should be accepted");
	STAssertFalse([myTrain acceptsCar: fc2], @"Should not be accepted");
}

- (void) testAllFreightCarsInYard {
	[self makeThreeStationLayout];
	[self makeYardAtStation: @"A"];
	FreightCar *fc = [self makeFreightCarWithReportingMarks: @"A 1"];
	[fc setCurrentLocation: [self yardAtStation: @"A"]];
	NSArray *carsInYard = [entireLayout_ allFreightCarsInYard];
	STAssertTrue(1 == [carsInYard count], @"Incorrect number of cars in yard, found %d", [carsInYard count]);
}

- (void) testImport {
	NSString *input = @"SP 1\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertTrue(3 == [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
	STAssertTrue(0 == [errors length], @"No errors expected");
}

- (void) testImportBlankLines {
	NSString *input = @"SP 1\n\n\n\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertTrue(0 == [errors length], @"No errors expected");
	STAssertTrue(3 == [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d (%@)", [[entireLayout_ allFreightCars] count],[entireLayout_ allFreightCars]);
	STAssertNotNil([self freightCarWithReportingMarks: @"SP 1"], @"Freight car names corrupted.");
}

// TODO(bowdidge): How far do I want to go with invalid characters?
// TODO(bowdidge): \r treated as non-space.
// TODO(bowdidge): What happens if the car name already exists?
- (void) disableTestImportControlCharacters {
	NSString *input = @"SP 1\007\b\\nSP 2  \n    SP 3\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertTrue(0 == [errors length], @"No errors expected");
	STAssertTrue(3 == [[entireLayout_ allFreightCars] count], @"Expected 3 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
}

- (void) checkExistenceOfCar: (NSString*) reportingMarks type: (NSString*) carType {
	FreightCar *fc = [self freightCarWithReportingMarks: reportingMarks];
	STAssertNotNil(fc, @"Freight car %@ not found", reportingMarks);	
	NSString *actualCarTypeName = [[fc carTypeRel] carTypeName];
	STAssertEqualObjects(carType, actualCarTypeName,
				   @"Expected freight car %@ to have type %@, but had type %@",
				   reportingMarks, carType, actualCarTypeName);
}

- (void)testImportCarTypes {
	NSString *input = @"SP 1, XM,\nSP 2, T\nSP    3\nSP 4\tXM\n  SP  5\t MYCARTYPE\t\n";
	NSMutableString *errors = nil;
	[entireLayout_ importFreightCarsUsingString: input errors: &errors];
	STAssertTrue(0 == [errors length], @"No errors expected");
	
	STAssertTrue(5 == [[entireLayout_ allFreightCars] count], @"Expected 4 freight cars, got %d", [[entireLayout_ allFreightCars] count]);
	
	[self checkExistenceOfCar: @"SP 1" type: @"XM"];
	[self checkExistenceOfCar: @"SP 2" type: @"T"];
	[self checkExistenceOfCar: @"SP 3" type: nil];
	[self checkExistenceOfCar: @"SP 4" type: @"XM"];
	[self checkExistenceOfCar: @"SP 5" type: @"MYCARTYPE"];
	NSString *actualCarTypeDescription = [[[self freightCarWithReportingMarks: @"SP 5"] carTypeRel] carTypeDescription];
	STAssertEqualObjects(@"", actualCarTypeDescription,
						 @"Car type description for new car type assumed to be empty but was %@", actualCarTypeDescription);
}

- (void) testCargoLoadsPerDay {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 7]];
	
	STAssertTrue(1 == [entireLayout_ loadsPerDay], @"Expected 1 load/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testCargoLoadsPerDayFractions {
	[self makeThreeStationLayout];
	Cargo *c1 = [self makeCargo: @"b to c"];
	[c1 setSource: [self industryAtStation: @"B"]];
	[c1 setDestination: [self industryAtStation: @"C"]];
	[c1 setCarsPerWeek: [NSNumber numberWithInt: 10]];
	
	Cargo *c2 = [self makeCargo: @"a to b"];
	[c2 setSource: [self industryAtStation: @"A"]];
	[c2 setDestination: [self industryAtStation: @"B"]];
	[c2 setCarsPerWeek: [NSNumber numberWithInt: 11]];
	
	STAssertTrue(3 == [entireLayout_ loadsPerDay], @"Expected 1 load/day, got %d", [entireLayout_ loadsPerDay]);
}

- (void) testSqlSanity {
	[self makeThreeStationLayout];
	Industry *i = [entireLayout_ industryWithName: @"'" withStationName: @"A"];
	// Make sure it didn't crash, and didn't return anything.
	STAssertNil(i, @"industryWithName not correctly finding quote");
	
	Industry *myIndustry = [self makeIndustryWithName: @"robert's"];
	[myIndustry setLocation: [entireLayout_ stationWithName: @"A"]];
	Industry *j = [entireLayout_ industryWithName: @"robert's-industry" withStationName: @"A"];
	STAssertTrue(j == myIndustry, @"Wrong industry returned.");
	
	// Same test for freight cars at industry - just test it doesn't throw.
	NSSet *cars = [myIndustry freightCars];
	STAssertNotNil(cars, @"freightCars failed.");
}
@end

