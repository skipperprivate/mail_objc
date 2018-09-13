//
//  TweetObj.h
//  mail_task_objective
//
//  Created by Олег Максименко on 09.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TweetObj : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *image_url;

@end
