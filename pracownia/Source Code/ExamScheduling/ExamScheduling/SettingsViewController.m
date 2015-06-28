//
//  SettingsViewController.m
//  ExamScheduling
//
//  Created by Michal Zaborowski on 28.06.2015.
//
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *initialTemperatureSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *freezingTemperatureSegmentedControl;
@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.initialTemperature) {
        if ([self.initialTemperature doubleValue] == 0.95) {
            self.initialTemperatureSegmentedControl.selectedSegmentIndex = 0;
        } else if ([self.initialTemperature doubleValue] == 100) {
            self.initialTemperatureSegmentedControl.selectedSegmentIndex = 1;
        } else if ([self.initialTemperature doubleValue] == 250) {
            self.initialTemperatureSegmentedControl.selectedSegmentIndex = 2;
        } else if ([self.initialTemperature doubleValue] == 500) {
            self.initialTemperatureSegmentedControl.selectedSegmentIndex = 3;
        } else {
            self.initialTemperatureSegmentedControl.selectedSegmentIndex = 4;
        }
    } else {
        self.initialTemperatureSegmentedControl.selectedSegmentIndex = 0;
    }
    
    if (self.freezingTemperature) {
        if ([self.freezingTemperature doubleValue] == 0.0009765625) {
            self.freezingTemperatureSegmentedControl.selectedSegmentIndex = 3;
        } else if ([self.freezingTemperature doubleValue] == 0.0078125) {
            self.freezingTemperatureSegmentedControl.selectedSegmentIndex = 2;
        } else if ([self.freezingTemperature doubleValue] == 0.03125) {
            self.freezingTemperatureSegmentedControl.selectedSegmentIndex = 1;
        } else {
            self.freezingTemperatureSegmentedControl.selectedSegmentIndex = 0;
        }
    } else {
        self.freezingTemperatureSegmentedControl.selectedSegmentIndex = 0;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    
    NSNumber *initialTemperature = @([[self.initialTemperatureSegmentedControl titleForSegmentAtIndex:self.initialTemperatureSegmentedControl.selectedSegmentIndex] doubleValue]);
    
    
    NSString *freezingTemperatureString = [self.freezingTemperatureSegmentedControl titleForSegmentAtIndex:self.freezingTemperatureSegmentedControl.selectedSegmentIndex];
    
    NSArray *freezingTemperatureArray = [freezingTemperatureString componentsSeparatedByString:@"/"];
    NSNumber *freezingTemperature = @([[freezingTemperatureArray firstObject] doubleValue] / [[freezingTemperatureArray lastObject] doubleValue]);
    
    if (self.completionBlock) {
        self.completionBlock(initialTemperature,freezingTemperature);
    }
}


@end
