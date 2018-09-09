//
//  TweetViewController.m
//  mail_task_objective
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import "TweetViewController.h"
#import "TFHpple.h"
#import "TweetObj.h"

@interface TweetViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table_tweet;
@property (weak, nonatomic) IBOutlet UILabel *time_label;
@property (weak, nonatomic) IBOutlet UITextField *text_field;
@property (weak, nonatomic) IBOutlet UIButton *search_btn;

@end



int timeSec = 0;
NSTimer *timer;

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table_tweet.delegate = self;
    _table_tweet.dataSource = self;
    
    [self StartTimer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //[NSThread sleepForTimeInterval:3];
        //int i = arc4random() % 100;
        
        [self parse];
        
        // update UI on the main thread
       // dispatch_async(dispatch_get_main_queue(), ^{
       //     self.title = [[NSString alloc]initWithFormat:@"Result: %d", i];
       // });
       // [self.table_tweet reloadData];
    });

     [self.table_tweet reloadData];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



-(void) StartTimer {
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}



- (void) timerTick:(NSTimer *)timer {
    timeSec++;
    if (timeSec == 15)
    {
        timeSec = 0;
    }
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d", timeSec];
    
    _time_label.text= timeNow;
}



- (void) parse {
    
    NSURL *tutorialsUrl = [NSURL URLWithString:@"https://twitter.com/oleg02171931"];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    //NSString *strData = [[NSString alloc]initWithData:tutorialsHtmlData encoding:NSUTF8StringEncoding];
        //NSLog(@"%@", strData);
    
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    // 3
    NSString *tutorialsXpathQueryString = @"//div[@class='js-tweet-text-container']/p";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    //NSLog(@"%@",tutorialsNodes);
    
//    NSMutableArray *newTutorials = [[NSMutableArray alloc] initWithCapacity:0];
    for (TFHppleElement *element in tutorialsNodes) {
        
        NSLog(@"%@",[[element firstChild] content]);
        // 6
       // tutorial.title = [[element firstChild] content];
        
        // 7
       // tutorial.url = [element objectForKey:@"href"];
    }
    /*dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSThread sleepForTimeInterval:3];
        int i = arc4random() % 100;
        
        // update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            self.title = [[NSString alloc]initWithFormat:@"Result: %d", i];
        });
        
    });*/
}



- (IBAction)search:(UIButton *)sender {
    
    [self StartTimer];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //[NSThread sleepForTimeInterval:3];
        //int i = arc4random() % 100;
        
        [self parse];
        
        // update UI on the main thread
        // dispatch_async(dispatch_get_main_queue(), ^{
        //     self.title = [[NSString alloc]initWithFormat:@"Result: %d", i];
        // });
        
    });
    
}



-(NSInteger)tableView:(UITableView *)table_tweet numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)table_tweet cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Tweet_cell";
    UITableViewCell *cell = [table_tweet dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = @"0";
   // cell.textLabel.text = [[sectionTitleArray objectAtIndex:indexPath.section]objectForKey:@"Profile"];
    
    return cell;
}




@end
