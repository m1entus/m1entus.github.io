// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to ESStudent.h instead.

@import CoreData;

extern const struct ESStudentAttributes {
	__unsafe_unretained NSString *studentId;
} ESStudentAttributes;

extern const struct ESStudentRelationships {
	__unsafe_unretained NSString *courses;
} ESStudentRelationships;

@class ESCourse;

@interface ESStudentID : NSManagedObjectID {}
@end

@interface _ESStudent : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) ESStudentID* objectID;

@property (nonatomic, strong) NSString* studentId;

//- (BOOL)validateStudentId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSSet *courses;

- (NSMutableSet*)coursesSet;

@end

@interface _ESStudent (CoursesCoreDataGeneratedAccessors)
- (void)addCourses:(NSSet*)value_;
- (void)removeCourses:(NSSet*)value_;
- (void)addCoursesObject:(ESCourse*)value_;
- (void)removeCoursesObject:(ESCourse*)value_;

@end

@interface _ESStudent (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveStudentId;
- (void)setPrimitiveStudentId:(NSString*)value;

- (NSMutableSet*)primitiveCourses;
- (void)setPrimitiveCourses:(NSMutableSet*)value;

@end
