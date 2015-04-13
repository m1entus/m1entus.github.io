// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ESStudent.m instead.

#import "_ESStudent.h"

const struct ESStudentAttributes ESStudentAttributes = {
	.studentId = @"studentId",
};

const struct ESStudentRelationships ESStudentRelationships = {
	.courses = @"courses",
};

@implementation ESStudentID
@end

@implementation _ESStudent

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ESStudent" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ESStudent";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ESStudent" inManagedObjectContext:moc_];
}

- (ESStudentID*)objectID {
	return (ESStudentID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic studentId;

@dynamic courses;

- (NSMutableSet*)coursesSet {
	[self willAccessValueForKey:@"courses"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"courses"];

	[self didAccessValueForKey:@"courses"];
	return result;
}

@end

