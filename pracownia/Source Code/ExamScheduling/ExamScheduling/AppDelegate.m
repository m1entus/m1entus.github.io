//
//  AppDelegate.m
//  ExamScheduling
//
//  Created by Michał Zaborowski on 12.04.2015.
//
//

#import "AppDelegate.h"
#import "ESCoursesFileParser.h"
#import "ESCourse.h"
#import "ESSimulatedAnnealingMethodology.h"
#import "ESDatabaseDataCache.h"
#import "ESGenethicMethodology.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)start {
    [[ESDatabaseDataCache sharedInstance] cacheForContext:[NSManagedObjectContext MR_defaultContext]];

    ESSimulatedAnnealingMethodology *sa = [[ESSimulatedAnnealingMethodology alloc] initWithContext:[NSManagedObjectContext MR_defaultContext]];
    ESSchedule *schedule = [sa solve];


//    ESGenethicMethodology *ge = [[ESGenethicMethodology alloc] initWithPopulationSize:[ESDatabaseDataCache sharedInstance].courses.count context:[NSManagedObjectContext MR_defaultContext]];
//
//    ESSchedule *schedule = [ge solve];

    
    schedule;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [MagicalRecord setupAutoMigratingCoreDataStack];

    if ([ESCourse MR_countOfEntities] <= 0) {
        [ESCoursesFileParser parseFileAtPath:[[NSBundle mainBundle] pathForResource:@"small5-stu" ofType:@"txt"] completionHandler:^(NSError *error) {
            [self start];
        }];
    } else {
        [self start];
    }


    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
