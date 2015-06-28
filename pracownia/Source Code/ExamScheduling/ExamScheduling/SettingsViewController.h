//
//  SettingsViewController.h
//  ExamScheduling
//
//  Created by Michal Zaborowski on 28.06.2015.
//
//

#import <UIKit/UIKit.h>

typedef void(^SettingsViewControllerCompletionBlock)(NSNumber *initialTemperature, NSNumber *freezingTemperature);

@interface SettingsViewController : UIViewController
@property (nonatomic, strong) NSNumber *initialTemperature;
@property (nonatomic, strong) NSNumber *freezingTemperature;
@property (nonatomic, copy) SettingsViewControllerCompletionBlock completionBlock;
@end
