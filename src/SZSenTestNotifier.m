//
//  SZSenTestNotifier.m
//  Charts
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

static NSString* const kszTestScope = @"XcodeUnitTestGUI";

@interface SZSenTestNotifier : SenTestObserver
{
}
@end

// Placate the compiler since this function exists only in the implementation file
@interface SenTestObserver(XcodeUnitTestGUI)
+(void)setCurrentObserver:(Class)anObserver;
@end

@implementation SZSenTestNotifier

-(void)postNotificationName:(NSString*) aName
                     userInfo:(NSDictionary*) userInfo
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:aName
                                                                   object:NSStringFromClass([self class])
                                                                 userInfo:userInfo
                                                       deliverImmediately:NO];
}

+(NSDictionary*)userInfoForObject:(id)anObject
                         userInfo:(NSDictionary*)userInfo
{
    if([anObject isKindOfClass:[SenTestRun class]])
    {
        SenTestCaseRun* run = anObject;
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                              [[run test] name], @"name",
                              [run startDate], @"start",
                              [run stopDate], @"stop",
                              [NSNumber numberWithUnsignedInt:[run failureCount]], @"failureCount",
                              [NSNumber numberWithUnsignedInt:[run unexpectedExceptionCount]], @"unexpectedFailureCount",
                              nil];
        return dict;
    }
    else
    {
        return nil;
    }
}

+(void)postNotificationName:(NSString*)aNotificationName
                     object:(id)anObject
                   userInfo:(NSDictionary*)userInfo
{
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:aNotificationName
                                                                   object:NSStringFromClass([self class])
                                                                 userInfo:[self userInfoForObject:anObject userInfo:userInfo]
                                                       deliverImmediately:YES];
}


+(void)testSuiteDidStart:(NSNotification*)aNotification
{
    [self postNotificationName:[aNotification name]
                        object:[aNotification object]
                      userInfo:[aNotification userInfo]];
    [SenTestLog testSuiteDidStart:aNotification];
}


+(void)testSuiteDidStop:(NSNotification*)aNotification
{
    [self postNotificationName:[aNotification name]
                        object:[aNotification object]
                      userInfo:[aNotification userInfo]];
    [SenTestLog testSuiteDidStop:aNotification];
}


+(void)testCaseDidStart:(NSNotification*)aNotification
{
    [self postNotificationName:[aNotification name]
                        object:[aNotification object]
                      userInfo:[aNotification userInfo]];

    [SenTestLog testCaseDidStart:aNotification];
}


+(void)testCaseDidStop:(NSNotification*)aNotification
{
    [self postNotificationName:[aNotification name]
                        object:[aNotification object]
                      userInfo:[aNotification userInfo]];

    [SenTestLog testCaseDidStop:aNotification];
}


+(void)testCaseDidFail:(NSNotification*)aNotification
{
    [self postNotificationName:[aNotification name]
                        object:[aNotification object]
                      userInfo:[aNotification userInfo]];

    [SenTestLog testCaseDidFail:aNotification];
}

@end

// Thanks to the good folks at Rogue Amoeba who shared this idea. 
//
// http://www.rogueamoeba.com/utm/2006/04/22/ocunitxcode-additions/
//
@interface SenTestProbe(XcodeUnitTestGUI)
+(SenTestSuite*)specifiedTestSuite;
@end

@interface SZTestProbe : SenTestProbe
@end

@implementation SZTestProbe

//Have to use a +load because +initialize will be called too late
+(void)load 
{
    [self poseAsClass: [SenTestProbe class]];
    [SZSenTestNotifier class];
}

+(SenTestSuite *)specifiedTestSuite
{
    SenTestSuite* suite = nil;
    
    NSString* testString = [[NSUserDefaults standardUserDefaults] stringForKey:kszTestScope];
    if(testString != nil)
    {
        suite = [[[SenTestSuite alloc] initWithName:kszTestScope] autorelease];
        NSArray* tests = [testString componentsSeparatedByCharactersInSet:
                          [NSCharacterSet characterSetWithCharactersInString:@","]];

        for(NSString* test in tests)
        {
            SenTestSuite* curSuite = [SenTestSuite testSuiteForTestCaseWithName:test];
            [suite addTest:curSuite];
        }
    }
    else
    {
        // If the user doesn't specify -XcodeUnitTestGUI, fall back to the old way
        suite = [super specifiedTestSuite];                
    }

    return suite;
}
@end

