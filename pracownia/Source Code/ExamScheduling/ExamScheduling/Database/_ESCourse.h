// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ESCourse.h instead.

@import CoreData;

extern const struct ESCourseAttributes {
	__unsafe_unretained NSString *courseId;
} ESCourseAttributes;

extern const struct ESCourseRelationships {
	__unsafe_unretained NSString *students;
} ESCourseRelationships;

@class ESStudent;

@interface ESCourseID : NSManagedObjectID {}
@end

@interface _ESCourse : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ESCourseID* objectID;

@property (nonatomic, strong) NSString* courseId;

//- (BOOL)validateCourseId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *students;

- (NSMutableSet*)studentsSet;

@end

@interface _ESCourse (StudentsCoreDataGeneratedAccessors)
- (void)addStudents:(NSSet*)value_;
- (void)removeStudents:(NSSet*)value_;
- (void)addStudentsObject:(ESStudent*)value_;
- (void)removeStudentsObject:(ESStudent*)value_;

@end

@interface _ESCourse (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveCourseId;
- (void)setPrimitiveCourseId:(NSString*)value;

- (NSMutableSet*)primitiveStudents;
- (void)setPrimitiveStudents:(NSMutableSet*)value;

@end
