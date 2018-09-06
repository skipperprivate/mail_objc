//
//  TweetViewController.m
//  mail_task_objective
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import "TweetViewController.h"

@interface TweetViewController ()

@end



@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector (testtimer) userInfo:nil repeats:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



- (void)testtimer {
    NSLog(@"lets go timer!");
}

@end
