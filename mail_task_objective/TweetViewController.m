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
@property (nonatomic, strong) NSMutableArray *task_tweets;
@end



int timeSec = 0;
NSTimer *timer;
//NSMutableArray *task_tweets;

@implementation TweetViewController

@synthesize task_tweets = _task_tweets;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table_tweet.delegate = self;
    _table_tweet.dataSource = self;
    
    [self StartTimer];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    _text_field.text = name;
    
    [self parse:^(NSMutableArray *resultArray) {
        //NSLog(@"%@", resultArray);
        self.task_tweets = resultArray;
    }];
    
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
    if (timeSec == 15) {
        timeSec = 0;
        
       // NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
       // self.text_field.text = name;
        
        [self.task_tweets removeAllObjects];
        
        [self parse:^(NSMutableArray *resultArray) {
            //NSLog(@"%@", resultArray);
            self.task_tweets = resultArray;
            [self.table_tweet reloadData];
        }];
        
        // });
        
        //NSLog(@"%@",self.task_tweets);
        
        //[self.table_tweet reloadData];
    }
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d", timeSec];
    
    _time_label.text= timeNow;
}



- (void) parse:(void(^)(NSMutableArray * resultArray))completeBlock {
    
    NSString *str = self.text_field.text;
    //NSString *str = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
   NSLog(@"%@", str);
    //NSString *str = @"oleg02171931";
    NSMutableString *firsturl_part = [NSMutableString stringWithString:@"https://twitter.com/"];
    [firsturl_part appendString:str];
    //NSMutableString *url = [firsturl_part stringByAppendingString:@"%@",str];
    
   // NSURL *tutorialsUrl = [NSURL URLWithString:@"https://twitter.com/oleg02171931"];
    NSURL *tutorialsUrl = [NSURL URLWithString:firsturl_part];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    NSString *tutorialsXpathQueryString = @"//div[@class='js-tweet-text-container']/p";
    NSArray *tutorialsNodes = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    
    NSString *XpathQueryString_fornick = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']/span[@class='username u-dir u-textTruncate']/b";
    NSArray *Nodes_nick = [tutorialsParser searchWithXPathQuery:XpathQueryString_fornick];

    
    NSString *XpathQueryString_forimage = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']//img[@class='avatar js-action-profile-avatar']";
    NSArray *Nodes_image = [tutorialsParser searchWithXPathQuery:XpathQueryString_forimage];
    
    
    NSMutableArray *newTweet = [[NSMutableArray alloc] initWithCapacity:0];
    
    //dispatch_queue_t checkUSers = dispatch_queue_create("CheckUsers", NULL);
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        int index = 0;
        
        for (TFHppleElement *element in tutorialsNodes) {
        
            TweetObj *tweet = [[TweetObj alloc] init];
            [newTweet addObject:tweet];
        
            tweet.text = [[element firstChild] content];
        
            TFHppleElement *author = [Nodes_nick objectAtIndex:index];
            tweet.author = [[author firstChild] content];
        
            TFHppleElement *url = [Nodes_image objectAtIndex:index];
            tweet.image_url = [url objectForKey:@"src"];
            
            index++;
        }
       // if (completeBlock) completeBlock(newTweet);
    });
    
    if (completeBlock) completeBlock(newTweet);
}



- (IBAction)search:(UIButton *)sender {
    
    [self.task_tweets removeAllObjects];
    timeSec = 0;
    
    NSString *str = self.text_field.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:str forKey:@"username"];
    [defaults synchronize];
    
    
    
    [self parse:^(NSMutableArray *resultArray) {
        //NSLog(@"%@", resultArray);
        self.task_tweets = resultArray;
    }];
    
    // });
    
   // NSLog(@"%@",self.task_tweets);
    
    [self.table_tweet reloadData];
    
}



-(NSInteger)tableView:(UITableView *)table_tweet numberOfRowsInSection:(NSInteger)section {
    
    return [self.task_tweets count];
    
}



-(UITableViewCell *)tableView:(UITableView *)table_tweet cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Tweet_cell";
    UITableViewCell *cell = [table_tweet dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    TweetObj *t_tweet = [self.task_tweets objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:t_tweet.author]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:t_tweet.text]];
    
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setAttributedText:str];
    
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:
                                              [NSURL  URLWithString:t_tweet.image_url]]];
    [[cell imageView] setImage:image];
    
    return cell;
}




@end
