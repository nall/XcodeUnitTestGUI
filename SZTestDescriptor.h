//
//  SZTestDescriptor.h
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum TestType
{
    TestcaseType,
    TestsuiteType
};

enum TestState
{
    TestPassed,
    TestFailed,
    TestUnknown
};

@interface SZTestDescriptor : NSObject
{
    enum TestType type;
    enum TestState state;
    NSString* name;
    NSString* parentName;
    
}
-(id)initSuite:(NSString*)theName;
-(id)initTest:(NSString*)theName inSuite:(NSString*)theSuiteName;

@property (assign) enum TestType type;
@property (assign) enum TestState state;
@property (retain) NSString* name;
@end
