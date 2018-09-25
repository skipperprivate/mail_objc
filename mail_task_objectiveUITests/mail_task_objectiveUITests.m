//
//  mail_task_objectiveUITests.m
//  mail_task_objectiveUITests
//
//  Created by Олег Максименко on 06.09.2018.
//  Copyright © 2018 Олег Максименко. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface mail_task_objectiveUITests : XCTestCase

@end

@implementation mail_task_objectiveUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testButton {
    
    XCUIApplication *app= [[XCUIApplication alloc] init];
    
    XCUIElement *btn = app.buttons[@"Search btn"];
    if (btn.isHittable) {
        [btn tap];
    } else {
        XCUICoordinate *c = [btn coordinateWithNormalizedOffset:CGVectorMake(0.0, 0.0)];
        [c tap];
    }
}
    
- (void) testTextField {
        
    XCUIApplication *app= [[XCUIApplication alloc] init];
    
    XCUIElement *search_text = app.textFields[@"Text field"];
    [search_text tap];
    [search_text typeText:@"hello world"];
    
}

@end
