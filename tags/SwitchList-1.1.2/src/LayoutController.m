//
//  LayoutController.m
//  SwitchList
//
//  Created by bowdidge on 3/6/11.
//
// Copyright (c)2012 Robert Bowdidge,
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
//
#import "LayoutController.h"

#import "CarAssigner.h"
#import "CargoAssigner.h"
#import "CarType.h"
#import "DoorAssignmentRecorder.h"
#import "EntireLayout.h"
#import "FreightCar.h"
#import "ScheduledTrain.h"
#import "TrainAssigner.h"

@implementation LayoutController
// Creates a new LayoutController.
- (id) initWithEntireLayout: (EntireLayout*) layout {
	self = [super init];
	entireLayout_ = [layout retain];
	doorAssignmentRecorder_ = [[DoorAssignmentRecorder alloc] init];
	return self;
}

- (void) dealloc {
	[entireLayout_ release];
	[doorAssignmentRecorder_ release];
	[super dealloc];
}

// Marks unloaded cars as loaded, and loaded as empty.
- (void) advanceLoads {
	NSArray *freightCarsToAdvance = [entireLayout_ allFreightCarsAtDestination];
	NSEnumerator *e = [freightCarsToAdvance objectEnumerator];
	FreightCar *car;
	while ((car = [e nextObject]) != nil) {
		if ([car isLoaded] == NO) {
			[car setIsLoaded: YES];
			// cargo stays the same
		} else {
			[car setIsLoaded: NO];
			[car setValue: nil forKey: @"cargo"];
		}
	}
	
	
}

// Assigns all freight cars on the layout to the trains listed, while respecting siding lengths and doors
// if requested.  Returns array of strings describing any errors encontered during assignment process.
- (NSArray *) assignCarsToTrains: (NSArray*) allTrains respectSidingLengths: (BOOL) respectSidingLengths useDoors: (BOOL) useDoors  {
	// Start from scratch (all cars, not just available) to make sure the placement is right.
	NSArray *allFreightCars = [entireLayout_ allFreightCars];
	
	NSEnumerator *e = [allFreightCars objectEnumerator];
	FreightCar *car;
	while ((car = [e nextObject]) != nil) {
		[car setCurrentTrain: nil];
	}
	
	TrainAssigner *ta = [[TrainAssigner alloc] initWithLayout: entireLayout_ useDoors: useDoors respectSidingLengths: respectSidingLengths];
	
	[ta assignCarsToTrains: allTrains];
	[doorAssignmentRecorder_ release];
	doorAssignmentRecorder_ = [[ta doorAssignmentRecorder] retain];
	NSArray *errs = [[[ta errors] retain] autorelease];
	[ta release];
	return errs;
}

// Creates the requested number of cargos and assigns them to unassigned cars.
// Returns dictionary mapping car type name (as string) to NSNumber showing number of cars
// that could not be loaded.
- (NSMutableDictionary *) createAndAssignNewCargos: (int) loadsToAdd  {
	NSArray *allFreightCars = [entireLayout_ allAvailableFreightCars];
	
	// Sanity check - if no freight cars, just return.
	if ([allFreightCars count] < 1)  return nil;
	
	// Keep track of how many cargos couldn't be filled to help layout owner with cargo balance.
	NSMutableDictionary *unavailableCarTypeDict = [NSMutableDictionary dictionary];

	CargoAssigner *cargoAssigner = [[CargoAssigner alloc] initWithEntireLayout: entireLayout_];
	NSArray *cargosForToday = [cargoAssigner cargosForToday: loadsToAdd];
	
	
	CarAssigner *carAssigner = [[CarAssigner alloc] initWithUnassignedCars: allFreightCars layout: entireLayout_];
	id cargo;
	
	NSEnumerator *cargoEnum = [cargosForToday objectEnumerator];
	while ((cargo = [cargoEnum nextObject]) != nil) {
		
		FreightCar *frtCar = [carAssigner assignedCarForCargo: cargo];
		
		if (frtCar == nil) {
			// No cars available - increase the count on this cargo in the unavailable cars dict.
			NSString *cargoCarReqt = [[cargo carTypeRel] carTypeName];
			if (cargoCarReqt == nil) {
				cargoCarReqt = @"Unspecified";
			}
			NSNumber *count = [unavailableCarTypeDict valueForKey: cargoCarReqt];
			if (count == nil) {
				// first car of this type that's unavailable.
				count = [NSNumber numberWithInt: 1];
			} else {
				count = [NSNumber numberWithInt: [count intValue] + 1];
			}
			[unavailableCarTypeDict setObject: count forKey: cargoCarReqt];
		}
	}
	[carAssigner release];
	[cargoAssigner release];
	return unavailableCarTypeDict;
}

// Moves all cars in the train to their final location.
- (void) completeTrain: (ScheduledTrain *) train  {
	NSSet *carMvmts = [NSSet setWithSet: [train freightCars]];
	for (FreightCar *car in carMvmts) {
		if (![car moveOneStep]) {
			// Problem occurred - silently fail.
		}
	}
}

// Clear all cargos for all freight cars with extreme prejudice.
// For restoring to a known state.
- (void) clearAllLoads {
	NSArray *unavailableFreightCars = [entireLayout_ allReservedFreightCars];
	NSEnumerator *e = [unavailableFreightCars objectEnumerator];
	id car;
	while ((car = [e nextObject]) != nil) {
		[car setIsLoaded: NO];
		[car setCargo: nil];
		[car setCurrentTrain: nil];
	}
}



- (DoorAssignmentRecorder*) doorAssignmentRecorder {
	return doorAssignmentRecorder_;
}
@end