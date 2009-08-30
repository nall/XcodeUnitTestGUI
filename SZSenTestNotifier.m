//
//  SZSenTestNotifier.m
//  Charts
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

@interface SZSenTestNotifier : SenTestObserver
{
}
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

