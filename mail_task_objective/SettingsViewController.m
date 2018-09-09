//
//  SettingsViewController.m
//  mail_task_objective
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import "SettingsViewController.h"
#import "TFHpple.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *switch_btn;

@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showimage"]) {
        NSLog(@"its on!");
        [_switch_btn setOn:YES animated:YES];
    } else {
        NSLog(@"its off!");
        [_switch_btn setOn:NO animated:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (IBAction)show_images:(UISwitch *)sender {
    
    if ([_switch_btn isOn]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:true forKey:@"showimage"];
        [defaults synchronize];
        NSLog(@"turned on!");
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:false forKey:@"showimage"];
        [defaults synchronize];
        NSLog(@"turned off!");
    }
    
}

@end
