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
    NSArray* classes;
    NSArray* methods;
}
@property (retain) NSArray* classes;
@property (retain) NSArray* methods;

@end
