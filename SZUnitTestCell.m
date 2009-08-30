//
//  SZUnitTestCell.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZUnitTestCell.h"


@implementation SZUnitTestCell

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        state = testUnknown;
        
        // Load image resources
        passedImage = [[NSImage imageNamed:@"testStatePassed"] retain];
        failedImage = [[NSImage imageNamed:@"testStateFailed"] retain];
        unknownImage = [[NSImage imageNamed:@"testStateUnknown"] retain];
        
        if(passedImage == nil || failedImage == nil || unknownImage == nil)
        {
            NSLog(@"ERROR Loading Images");
            NSBeep();
        }
        
        [self setStringValue:@"<TESTING>"];
        [self setImage:unknownImage];
    }
    return self;
}

-(void)dealloc
{
    [passedImage release];
    [failedImage release];
    [unknownImage release];
    [super dealloc];
}

-(enum TestState)state
{
    return state;
}

-(BOOL)isLeaf
{
    // Don't want the NSBrowser disclosure triangles
    return YES;
}

-(void)setState:(const enum TestState)theState
{
    [self willChangeValueForKey:@"state"];
    state = theState;
    switch(state)
    {
        case testPassed:
        {
            curImage = passedImage;
            break;
        }
        case testFailed:
        {
            curImage = failedImage;
            break;
        }
        case testUnknown:
        {
            curImage = unknownImage;
            break;
        }
        default:
        {
            NSBeep();
            NSLog(@"Unexpected test state: %@", state);
        }
    }
    [self setImage:curImage];
    
    [self didChangeValueForKey:@"state"];
}


@end
