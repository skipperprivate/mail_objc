//
//  mail_task_objectiveTests.m
//  mail_task_objectiveTests
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface mail_task_objectiveTests : XCTestCase

@end



@implementation mail_task_objectiveTests



- (void)setUp {
    [super setUp];
    

}

- (void)tearDown {
    
    [super tearDown];
}


- (void)testExample {
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void)testIsEqualType {
    
    int var1 = 5;
    int var2 = 5;
    XCTAssertEqual(var1, var2, @"(%d) equal to (%d)", var1, var2);
}



- (void)testEqualObject {
    
    id obj1 = @[];
    id obj2 = @[];
    XCTAssertEqualObjects(obj1, obj2, @"obj1(%@) not equal to obj2(%@))", obj1, obj2);
}


- (void)testDataTask {
    
    
    NSURL *url = [NSURL URLWithString:@"https://twitter.com/oleg02171931"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        XCTAssertNil(error, @"dataTaskWithURL error %@", error);
        
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSInteger statusCode = [(NSHTTPURLResponse *) response statusCode];
            XCTAssertEqual(statusCode, 200, @"status code was not 200; was %d", statusCode);
        }
        
        XCTAssert(data, @"data nil");
        
    }];
    [task resume];
    
}



@end
