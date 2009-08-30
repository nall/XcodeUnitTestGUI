//
//  SZAppDelegate.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/29/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZAppDelegate.h"
#include <objc/objc-runtime.h>
#include <SenTestingKit/SenTestingKit.h>

@implementation SZAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification*)theNotification
{
    xcodeController = [[SZXCodeController alloc] init];
    
    NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
    NSDate* nextTime = [NSDate dateWithTimeIntervalSinceNow:1.0];
    const double rate = 1.0;
    NSTimer* timer = [[NSTimer alloc] initWithFireDate:nextTime
                                              interval:rate
                                                target:self
                                              selector:@selector(monitorXcode)
                                              userInfo:nil
                                               repeats:YES];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector:@selector(testStarted:)
                                                            name:SenTestCaseDidStartNotification
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector:@selector(testStopped:)
                                                            name:SenTestCaseDidStopNotification
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector:@selector(testFailed:)
                                                            name:SenTestCaseDidFailNotification
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector:@selector(suiteStarted:)
                                                            name:SenTestSuiteDidStartNotification
                                                          object:nil];
    [[NSDistributedNotificationCenter defaultCenter] addObserver: self
                                                        selector:@selector(suiteStopped:)
                                                            name:SenTestSuiteDidStopNotification
                                                          object:nil];
}

-(void)testStarted:(NSNotification*)theNotification
{
    NSLog(@"test started: %@", theNotification);
}

-(void)testStopped:(NSNotification*)theNotification
{
    NSLog(@"test stopped: %@", theNotification);
}

-(void)testFailed:(NSNotification*)theNotification
{
    NSLog(@"test failed: %@", theNotification);
}

-(void)suiteStarted:(NSNotification*)theNotification
{
    NSLog(@"suite started: %@", theNotification);
}

-(void)suiteStopped:(NSNotification*)theNotification
{
    NSLog(@"suite stopped: %@", theNotification);
}

-(void)applicationWillTerminate:(NSNotification*)theNotification
{
    [xcodeController release];
    [curProject release];
    [bundles release];
}

-(void)setCurBundle:(NSBundle*)theBundle
{
    [self willChangeValueForKey:@"curBundle"];
    [curBundle unload];
    [theBundle retain];
    [curBundle release];
    curBundle = theBundle;
    [self didChangeValueForKey:@"curBundle"];
}

-(NSBundle*)curBundle
{
    return curBundle;
}

-(void)setBundles:(NSArray*)theBundles
{
    [self willChangeValueForKey:@"bundles"];
    [theBundles retain];
    [bundles release];
    bundles = theBundles;
    [self didChangeValueForKey:@"bundles"];
}

-(NSArray*)bundles
{
    return bundles;
}

-(void)setCurProject:(NSString*)theProject
{
    [self willChangeValueForKey:@"curProject"];
    [theProject retain];
    [curProject release];
    curProject = theProject;
    [self didChangeValueForKey:@"curProject"];
}

-(NSString*)curProject
{
    return curProject;
}

-(void)loadBundle:(NSString*)theBundleName
{
    NSString* basePath = [xcodeController pathToBundle:theBundleName];
    [self setCurBundle:[NSBundle bundleWithPath:basePath]];
    if(curBundle == nil)
    {
        NSLog(@"ERROR Loading Bundle");
        return;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bundleDidLoad:)
                                                     name:NSBundleDidLoadNotification
                                                   object:curBundle];

        // Force loading of classes
        [curBundle principalClass];
    }    
}

-(void)monitorXcode
{
    // Check XCode periodically to see if the main project has changed.
    // If so, reload the unit test bundles
    
    NSString* project = [xcodeController currentProject];
    if([project isEqualToString:curProject] == NO)
    {
        [self setCurProject:project];
        [self setBundles:[xcodeController unitTestBundles]];
        if([bundles count] > 0)
        {
            NSLog(@"bundle: %@", [bundleButton titleOfSelectedItem]);
            [self loadBundle:[bundleButton titleOfSelectedItem]];            
        }
        else
        {
            dataSource.classes = [NSArray array];
            dataSource.methods = [NSArray array];
            [outlineView reloadData];
        }
    }
}

-(void)bundleDidLoad:(NSNotification*)theNotification
{
    NSArray* classes = [[theNotification userInfo] objectForKey:@"NSLoadedClasses"];
    NSMutableArray* methods = [NSMutableArray arrayWithCapacity:[classes count]];
    
    for(NSString* className in classes)
    {
        Class klass = NSClassFromString(className);
        unsigned int numMethods;
        Method* methodList = class_copyMethodList(klass, &numMethods);
    
        [methods addObject:[NSMutableArray arrayWithCapacity:numMethods]];
        
        NSLog(@"CLASS: %@", className);
        for(uint32_t i = 0; i < numMethods; ++i)
        {
            const char* methNameC = sel_getName(method_getName(methodList[i]));
            NSString* methName = [NSString stringWithCString:methNameC];
            if([methName hasPrefix:@"test"])
            {
                
                // TODO: Check out using SenTestCase::testInvocations
                NSLog(@"\tTEST: %@", methName);                
                [[methods lastObject] addObject:methName];
            }
        }
    }
    
    dataSource.classes = classes;
    dataSource.methods = methods;
    [outlineView reloadData];
}


-(IBAction)runTests:(id)sender
{
    NSString* transcript = [xcodeController runUnitTestBundle:[bundleButton titleOfSelectedItem]];
    NSLog(@"TRANSCRIPT: %@", @"foo", transcript);
}

@end
