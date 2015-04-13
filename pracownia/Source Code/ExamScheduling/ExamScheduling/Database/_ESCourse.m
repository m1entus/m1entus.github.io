// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ESCourse.m instead.

#import "_ESCourse.h"

const struct ESCourseAttributes ESCourseAttributes = {
	.courseId = @"courseId",
};

const struct ESCourseRelationships ESCourseRelationships = {
	.students = @"students",
};

@implementation ESCourseID
@end

@implementation _ESCourse

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ESCourse" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ESCourse";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ESCourse" inManagedObjectContext:moc_];
}

- (ESCourseID*)objectID {
	return (ESCourseID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic courseId;

@dynamic students;

- (NSMutableSet*)studentsSet {
	[self willAccessValueForKey:@"students"];

	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"students"];

	[self didAccessValueForKey:@"students"];
	return result;
}

@end

