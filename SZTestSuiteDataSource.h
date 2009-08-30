//
//  SZTestSuiteDataSource.h
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SZTestSuiteDataSource : NSObject
{
    NSArray* suites;
    NSArray* tests;
}
-(void)invalidateStates;
@property (retain) NSArray* suites;
@property (retain) NSArray* tests;

@end
