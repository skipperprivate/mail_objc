//
//  TweetViewController.m
//  mail_task_objective
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import "TweetViewController.h"
#import "Parse/TFHpple.h"
#import "Tweet/TweetObj.h"
#import "Tweet_obj+CoreDataClass.h"
#import "AppDelegate.h"


@interface TweetViewController ()

@property (weak, nonatomic) IBOutlet UITableView *table_tweet;
@property (weak, nonatomic) IBOutlet UILabel *time_label;
@property (weak, nonatomic) IBOutlet UITextField *text_field;
@property (weak, nonatomic) IBOutlet UIButton *search_btn;
@property (nonatomic, strong) NSMutableArray *task_tweets;


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
    _task_tweets = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self download];
    
}


- (void)download {
    
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue1, ^{
        
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        
        NSManagedObjectContext *context = delegate.persistentContainer.viewContext;
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Tweet_obj" inManagedObjectContext:context];
        [fetchRequest setEntity:entity];
        
        NSError *error = nil;
        NSArray *result = [context executeFetchRequest:fetchRequest error:&error];
        
        for(NSManagedObject *subArray in result) {
            
            TweetObj *tweet = [[TweetObj alloc] init];
            [self.task_tweets addObject:tweet];
            
            tweet.text = [subArray valueForKey:@"text"];
            tweet.author = [subArray valueForKey:@"author"];
            tweet.image_url = [subArray valueForKey:@"url"];
            
            
            [context deleteObject:subArray];
        }
        
        dispatch_queue_t mainThreadQueue = dispatch_get_main_queue();
        dispatch_async(mainThreadQueue, ^{
            
            [self.table_tweet reloadData]; 
        });
        
    });
    
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
        
        [self.task_tweets removeAllObjects];
        
        [self parse];
        
    }
    
    NSString* timeNow = [NSString stringWithFormat:@"%02d", timeSec];
    
    _time_label.text= timeNow;
}



- (void) show_error:(NSString *) message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}



- (void) parse{
    
    NSString *str = self.text_field.text;
    
    NSMutableString *firsturl_part = [NSMutableString stringWithString:@"https://twitter.com/"];
    [firsturl_part appendString:str];
    
    
    NSURL *tutorialsUrl = [NSURL URLWithString:firsturl_part];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    NSURLSessionDataTask *datatask = [session dataTaskWithURL:tutorialsUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        TFHpple *tutorialsParser = [TFHpple hppleWithHTMLData:data];
        
        NSMutableArray *newTweet = [[NSMutableArray alloc] initWithCapacity:0];
        
        NSString *tutorialsXpathQueryString = @"//div[@class='js-tweet-text-container']/p";
        NSArray *array_text = [tutorialsParser searchWithXPathQuery:tutorialsXpathQueryString];
        
        NSString *XpathQueryString_fornick = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']/span[@class='username u-dir u-textTruncate']/b";
        NSArray *array_nick = [tutorialsParser searchWithXPathQuery:XpathQueryString_fornick];
        
        
        NSString *XpathQueryString_forimage = @"//div[@class='stream-item-header']/a[@class='account-group js-account-group js-action-profile js-user-profile-link js-nav']//img[@class='avatar js-action-profile-avatar']";
        NSArray *array_image = [tutorialsParser searchWithXPathQuery:XpathQueryString_forimage];
        
        
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
            
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            NSManagedObjectContext *context = delegate.persistentContainer.viewContext;
            
            for (TweetObj *t in newTweet) {
                
                NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet_obj"
                                                                        inManagedObjectContext:context];
                [object setValue:t.text forKey:@"text"];
                [object setValue:t.author forKey:@"author"];
                [object setValue:t.image_url forKey:@"url"];
                
                NSError *error;
                if (![context save:&error]) {
                    NSLog(@"Failed to save - error: %@", [error localizedDescription]);
                }
            }
        
        
        
        dispatch_sync(dispatch_get_main_queue(),^{
            
            if ([newTweet count] !=0 ){
                self.task_tweets = newTweet;
                [self.table_tweet reloadData];
            } else {
                [self show_error:@"not found"];
            }

        });
    }];
    
    [datatask resume];
    
}



- (IBAction)search:(UIButton *)sender {
    
    [self.task_tweets removeAllObjects];
    
    timeSec = 0;
    
    NSString *str = self.text_field.text;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:str forKey:@"username"];
    [defaults synchronize];
    
    [self parse];
    
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
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"showimage"]) {
        UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:
                                              [NSURL  URLWithString:t_tweet.image_url]]];
        [[cell imageView] setImage:image];
    } else {
        
    }
    
    return cell;
}




@end
