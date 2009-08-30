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
    @private
    NSArray* suites;
    NSArray* tests;
    NSBrowserCell* testCell;
    NSButtonCell* enableCell;

    NSImage* passedImage;
    NSImage* failedImage;
    NSImage* unknownImage;  
    
    IBOutlet NSOutlineView* outlineView;
}
-(void)invalidateStates;
@property (retain) NSArray* suites;
@property (retain) NSArray* tests;

@end
