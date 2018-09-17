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
#import "Tweet_obj+CoreDataClass.h"
#import "AppDelegate.h"


@interface TweetViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table_tweet;
@property (weak, nonatomic) IBOutlet UILabel *time_label;
@property (weak, nonatomic) IBOutlet UITextField *text_field;
@property (weak, nonatomic) IBOutlet UIButton *search_btn;
@property (nonatomic, strong) NSMutableArray *task_tweets;
@property (nonatomic, strong) NSString *str22;
@property (nonatomic, strong) TweetObj *twt;


@end



int timeSec = 0;
NSTimer *timer;


@implementation TweetViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table_tweet.delegate = self;
    _table_tweet.dataSource = self;
    
    [self StartTimer];
    
    NSString *name = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
    
    _text_field.text = name;
    
    [self download];
}


- (void)download {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSManagedObjectContext *context = delegate.persistentContainer.viewContext;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet_obj" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    NSError *error = nil;
    NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
    NSLog(@"from db");
    
   // _twt  = [[TweetObj alloc] init];
    
    NSMutableArray *newTweet = [[NSMutableArray alloc] initWithCapacity:0];
    _task_tweets = [[NSMutableArray alloc] initWithCapacity:0];
    for(NSManagedObject *subArray in result) {
        
        //NSLog(@"Array in myArray: %@",[subArray valueForKey:@"text"]);
        TweetObj *tweet = [[TweetObj alloc] init];
        [_task_tweets addObject:tweet];
        
        tweet.text = [subArray valueForKey:@"text"];
        tweet.author = [subArray valueForKey:@"author"];
        tweet.image_url = [subArray valueForKey:@"url"];
        
        
        [context deleteObject:subArray];
    }
    
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
    
    if (timeSec == 22) {
        timeSec = 0;
        
        //[self show_error];
        
        [self.task_tweets removeAllObjects];
        //[task_tweets1 removeAllObjects];
        
        [self parse:^(NSMutableArray *resultArray) {
            //NSLog(@"%@", resultArray);
            self.task_tweets = resultArray;
            //task_tweets1 = resultArray;
            [self.table_tweet reloadData];
        }];
        
    }
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d", timeSec];
    
    _time_label.text= timeNow;
}



- (void) show_error {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:@"Something went wrong"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}



- (void) parse:(void(^)(NSMutableArray * resultArray))completeBlock {
    
    NSString *str = self.text_field.text;
    
    NSMutableString *firsturl_part = [NSMutableString stringWithString:@"https://twitter.com/"];
    [firsturl_part appendString:str];
    
    
    
    NSURL *tutorialsUrl = [NSURL URLWithString:firsturl_part];
    NSData *tutorialsHtmlData = [NSData dataWithContentsOfURL:tutorialsUrl];
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://twitter.com/realDonaldTrump"]];

    
    [urlRequest setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (httpResponse.statusCode == 200) {
            NSLog(@"%@", data);
        }
        else
        {
            NSLog(@"Error");
        }
    }];
    
    [dataTask resume];
    
    
    NSMutableArray *newTweet = [[NSMutableArray alloc] initWithCapacity:0];
    
    TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:tutorialsHtmlData];
    
    NSString *tutorialsXpathQueryString = @"//div[@class='js-tweet-text-container']/p";
    NSArray *array_text = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
    
    if ([array_text count]!=0) {
    
    
        NSString *XpathQueryString_fornick = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']/span[@class='username u-dir u-textTruncate']/b";
        NSArray *array_nick = [tutorialsParser searchWithXPathQuery:XpathQueryString_fornick];

    
        NSString *XpathQueryString_forimage = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']//img[@class='avatar js-action-profile-avatar']";
        NSArray *array_image = [tutorialsParser searchWithXPathQuery:XpathQueryString_forimage];
    
    
        //NSMutableArray *newTweet = [[NSMutableArray alloc] initWithCapacity:0];
    
    
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
        
            int index = 0;
        
            for (TFHppleElement *element in array_text) {
        
                TweetObj *tweet = [[TweetObj alloc] init];
                [newTweet addObject:tweet];
        
                tweet.text = [[element firstChild] content];
        
                TFHppleElement *author = [array_nick objectAtIndex:index];
                tweet.author = [[author firstChild] content];
        
                TFHppleElement *url = [array_image objectAtIndex:index];
                tweet.image_url = [url objectForKey:@"src"];
                
                index++;
            }
            
            for (TweetObj *t in newTweet) {
                AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                
                NSManagedObjectContext *context = delegate.persistentContainer.viewContext;
                
                
                NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet_obj"
                                                                        inManagedObjectContext:context];
                [object setValue:t.text forKey:@"text"];
                [object setValue:t.author forKey:@"author"];
                [object setValue:t.image_url forKey:@"url"];
                //[object setValue:12 forKey:@"numberValue"];
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }
            
        });
        
        
    } else {
        
        [self show_error];
 
    }
    
    
    if (completeBlock) completeBlock(newTweet);
}



- (IBAction)search:(UIButton *)sender {
    
    [self.task_tweets removeAllObjects];
    //[task_tweets1 removeAllObjects];
    timeSec = 0;
    
    NSString *str = self.text_field.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:str forKey:@"username"];
    [defaults synchronize];
    
    
    
    [self parse:^(NSMutableArray *resultArray) {
        //NSLog(@"%@", resultArray);
        self.task_tweets = resultArray;
       // task_tweets1 = resultArray;
    }];
    
    [self.table_tweet reloadData];
    
}



-(NSInteger)tableView:(UITableView *)table_tweet numberOfRowsInSection:(NSInteger)section {
    
    //return [task_tweets1 count];
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
   // TweetObj *t_tweet = [task_tweets1 objectAtIndex:indexPath.row];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] init];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:t_tweet.author]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:t_tweet.text]];
    
    cell.textLabel.numberOfLines = 0;
    [cell.textLabel setAttributedText:str];
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showimage"]) {
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:
                                              [NSURL  URLWithString:t_tweet.image_url]]];
        [[cell imageView] setImage:image];
    } else {
        
    }
    
    return cell;
}




@end
