// 
//  Place.m
//  SwitchList
//
//  Created by Robert Bowdidge on 6/9/06.
//
// Copyright (c)2006 Robert Bowdidge,
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

#import "Place.h"

#import "Industry.h"
#import "StringHelpers.h"

@implementation Place 

@dynamic name;

// Sets up default values for a newly created Place.
- (void)awakeFromInsert {
	[super awakeFromInsert];
	[self setName: @"New town"];
}

- (BOOL)isOffline 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"isOffline"];
    tmpValue = [self primitiveValueForKey: @"isOffline"];
    [self didAccessValueForKey: @"isOffline"];
    
    return [tmpValue boolValue];
}

- (void)setIsOffline:(BOOL) offline { 
	NSNumber *value = [NSNumber numberWithBool: offline];
    [self willChangeValueForKey: @"isOffline"];
    [self setPrimitiveValue: value forKey: @"isOffline"];
    [self didChangeValueForKey: @"isOffline"];
}

- (BOOL) isStaging 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey: @"isStaging"];
    tmpValue = [self primitiveValueForKey: @"isStaging"];
    [self didAccessValueForKey: @"isStaging"];
    
    return [tmpValue boolValue];
}

- (void)setIsStaging:(BOOL) isStaging {
	NSNumber *value = [NSNumber numberWithBool: isStaging];
    [self willChangeValueForKey: @"isStaging"];
    [self setPrimitiveValue: value forKey: @"isStaging"];
    [self didChangeValueForKey: @"isStaging"];
}


- (void)addAdjacentPlacesObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"adjacentPlaces" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"adjacentPlaces"] addObject: value];
    [self didChangeValueForKey:@"adjacentPlaces" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeAdjacentPlacesObject:(NSManagedObject *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"adjacentPlaces" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"adjacentPlaces"] removeObject: value];
    [self didChangeValueForKey:@"adjacentPlaces" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}


- (void)addIndustriesObject:(InduYard *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"industries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"industries"] addObject: value];
    [self didChangeValueForKey:@"industries" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeIndustriesObject:(InduYard *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"industries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey: @"industries"] removeObject: value];
    [self didChangeValueForKey:@"industries" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (NSSet*) industries {
	return [self primitiveValueForKey: @"industries"];
}

- (NSSet*) yards {
	NSSet *industries = [self industries];
	NSMutableSet *result = [NSMutableSet set];
	Industry *i;
	NSEnumerator *e = [industries objectEnumerator];
	while ((i = [e nextObject]) != nil) {
		if ([i isYard]) {
			[result addObject: i];
		}
	}
	return result;
}

// Does this place have a yard?
- (BOOL) hasYard {
	return [[self yards] count] != 0;
}

- (NSSet*) freightCarsAtStation {
	NSSet *industriesHere = [self industries];
	NSMutableSet *allFreightCars = [NSMutableSet set];
	NSEnumerator *indEnum = [industriesHere objectEnumerator];
	Industry *ind;
	while ((ind = [indEnum nextObject]) != nil) {
		[allFreightCars unionSet: [ind freightCars]];
	}
	return allFreightCars;
}

// Returns true if the current managedObjectContext already knows of a station with the
// name.
- (BOOL) stationAlreadyExists: (NSString*) name {
	NSError *fetchError;
	NSEntityDescription *ent = [NSEntityDescription entityForName: @"Place" inManagedObjectContext: [self managedObjectContext]];
	NSFetchRequest * req2  = [[[NSFetchRequest alloc] init] autorelease];
	[req2 setEntity: ent];
	[req2 setPredicate: [NSPredicate predicateWithFormat: @"name LIKE %@",[name sqlSanitizedString]]];
	NSArray *result = [[self managedObjectContext] executeFetchRequest: req2 error:&fetchError];
	
	return ([result count] != 0);
}

// Validate that name is unique.  Only called by nib files if set to validate.
// This check is needed because the stationStops field of a ScheduledTrain only lists names, not references
// to objects.
- (BOOL)validateName: (id*) namePtr error:(NSError **)error {
	return YES;
	// TODO(bowdidge): This causes assertion errors on save.  Figure out how to catch earlier.
	// NSString *name = *namePtr;
	// if ([self stationAlreadyExists: name]) {
	// NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
    // [errorDict setObject: @"Duplicate name." forKey: NSLocalizedDescriptionKey];
    // [errorDict setObject: [NSString stringWithFormat: @"There is already a town named %@.  Please choose a different name.", name] forKey: NSLocalizedRecoverySuggestionErrorKey];
		
	// *error = [NSError errorWithDomain: @"com.blogspot.vasonabranch.SwitchListApp" code: 1
	//							 userInfo: errorDict];
		
	//	return NO;
	//}
	// return YES;
}

- (NSString*) description {
	return [NSString stringWithFormat: @"<Place: %@>", [self name]];
}
	
@end