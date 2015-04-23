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
#import "ESDataCache.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)start {

    
    ESSimulatedAnnealingMethodology *sa = [[ESSimulatedAnnealingMethodology alloc] init];
    NSDate *start = [NSDate date];

    ESSchedule *schedule = [sa solve];

    if ([[ESDataCache sharedInstance].bestSchedule.quality doubleValue] > [schedule.quality doubleValue]) {
        [ESDataCache sharedInstance].bestSchedule = schedule;
        [[ESDataCache sharedInstance] save];
    }

    NSTimeInterval timeInterval = [start timeIntervalSinceNow];

    NSLog(@"Slots: %@\n", schedule.slotForCourseId);
    NSLog(@"QUALITY: %@\n",schedule.quality);
    NSLog(@"Time: %f\n",fabs(timeInterval));
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self start];
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
