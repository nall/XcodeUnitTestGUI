//
//  SZUnitTestCell.h
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum TestState
{
    testPassed,
    testFailed,
    testUnknown
};

@interface SZUnitTestCell : NSBrowserCell
{
    enum TestState state;
    
    @private
    NSImage* curImage;
    NSImage* passedImage;
    NSImage* failedImage;
    NSImage* unknownImage;
    
}
@property (assign) enum TestState state;

@end
