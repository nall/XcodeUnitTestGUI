//
//  SZAppDelegate.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/29/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#include <objc/objc-runtime.h>
#include <SenTestingKit/SenTestingKit.h>

#import "SZAppDelegate.h"
#import "SZTestDescriptor.h"

static NSString* const kszSenTestAllTests = @"All tests";

@implementation SZAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification*)theNotification
{
    xcodeController = [[SZXCodeController alloc] init];
    queue = [[NSOperationQueue alloc] init];
    
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
                                                        selector:@selector(TestFailed:)
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

-(void)applicationWillTerminate:(NSNotification*)theNotification
{
    [xcodeController release];
    [queue release];
    [curProject release];
    [bundles release];
}

-(void)parse:(NSString*)theName
    intoTest:(NSString**)theTestName
   intoSuite:(NSString**)theSuiteName
{
    NSRange firstSpace = [theName rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];

    // Account for leading "-["
    NSRange suiteRange = NSMakeRange(2, firstSpace.location - 2);
    
    NSUInteger testnameLocation = firstSpace.location + firstSpace.length;
    
    // Account for trailing "]"
    NSRange testRange = NSMakeRange(testnameLocation, [theName length] - testnameLocation - 1);
    
    *theTestName = [theName substringWithRange:testRange];
    *theSuiteName = [theName substringWithRange:suiteRange];
}

-(void)testStarted:(NSNotification*)theNotification
{
//    NSLog(@"test started: %@", theNotification);
}

-(void)testStopped:(NSNotification*)theNotification
{
//    NSLog(@"test stopped: %@", theNotification);
    NSString* name = [[theNotification userInfo] objectForKey:@"name"];
    const BOOL hadFailures = [[[theNotification userInfo] objectForKey:@"failureCount"] boolValue];
    
    NSString* testName;
    NSString* suiteName;
    [self parse:name intoTest:&testName intoSuite:&suiteName];    
    
    for(NSUInteger i = 0; i < [dataSource.suites count]; ++i)
    {
        SZTestDescriptor* suite = [dataSource.suites objectAtIndex:i];
        if([[suite name] isEqualToString:suiteName])
        {
            for(SZTestDescriptor* test in [dataSource.tests objectAtIndex:i])
            {
                NSLog(@"%@ <> %@", test, testName);
                if([[test name] isEqualToString:testName])
                {
                    test.state = hadFailures ? TestFailed : TestPassed;                                    
                    break;
                }
            }
            break;
        }        
    }
    [outlineView reloadData];
}

-(void)testFailed:(NSNotification*)theNotification
{
//    NSLog(@"test failed: %@", theNotification);
}

-(void)suiteStarted:(NSNotification*)theNotification
{
//    NSLog(@"suite started: %@", theNotification);
}

-(void)suiteStopped:(NSNotification*)theNotification
{
//    NSLog(@"suite stopped: %@", theNotification);
    NSString* name = [[theNotification userInfo] objectForKey:@"name"];
    const BOOL hadFailures = [[[theNotification userInfo] objectForKey:@"failureCount"] boolValue];
    for(SZTestDescriptor* test in dataSource.suites)
    {
        if([[test name] isEqualToString:name])
        {
            test.state = hadFailures ? TestFailed : TestPassed;
        }
    }
    [outlineView reloadData];
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
            [self loadBundle:[bundleButton titleOfSelectedItem]];            
        }
        else
        {
            dataSource.suites = [NSArray array];
            dataSource.tests = [NSArray array];
            [outlineView reloadData];
        }
    }
}

-(void)runTestsThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];

    NSString* transcript = [xcodeController runUnitTestBundle:[bundleButton titleOfSelectedItem]];
    (void)transcript;
    
    [pool release];
}

// Do this to avoid instantiating objects
-(BOOL)isClass:(Class)theClass aMemberOf:(Class)theSuperclass
{
    const char* superName = class_getName(theSuperclass);
    BOOL found = strcmp(class_getName(theClass), superName) == 0;
    Class curClass = theClass;
    while(found == NO)
    {
        curClass = class_getSuperclass(curClass);
        if(curClass == Nil)
        {
            // Reached top of hierarchy
            break;
        }
        else if(strcmp(class_getName(curClass), superName) == 0)
        {
            found = YES;
            break;
        }
    }
    
    return found;
}

-(void)bundleDidLoad:(NSNotification*)theNotification
{
    NSArray* classes = [[theNotification userInfo] objectForKey:@"NSLoadedClasses"];
    NSMutableArray* suites = [NSMutableArray arrayWithCapacity:[classes count]];
    NSMutableArray* tests = [NSMutableArray arrayWithCapacity:[classes count]];
    
    
    for(NSString* className in classes)
    {
        Class klass = NSClassFromString(className);
        
        if([self isClass:klass aMemberOf:[SenTestCase class]] == NO)
        {
            continue;
        }
        
        [suites addObject:[[[SZTestDescriptor alloc] initSuite:className] autorelease]];
        
        unsigned int numMethods;
        Method* methodList = class_copyMethodList(klass, &numMethods);
    
        [tests addObject:[NSMutableArray arrayWithCapacity:numMethods]];
        
        for(unsigned int i = 0; i < numMethods; ++i)
        {
            const char* methNameC = sel_getName(method_getName(methodList[i]));
            NSString* methName = [NSString stringWithCString:methNameC];
            if([methName hasPrefix:@"test"])
            {
                [[tests lastObject] addObject:
                 [[[SZTestDescriptor alloc] initTest:methName inSuite:className] autorelease]];
            }
        }
    }
    
    dataSource.suites = suites;
    dataSource.tests = tests;
    [outlineView reloadData];
}

-(IBAction)bundleChanged:(id)sender
{
    if([bundles count] > 0)
    {
        [self loadBundle:[bundleButton titleOfSelectedItem]];
    }
}

-(IBAction)runTests:(id)sender
{
    [dataSource invalidateStates];
    [outlineView reloadData];
    
    NSInvocationOperation* op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                     selector:@selector(runTestsThread)
                                                                       object:nil];
    [queue addOperation:op];
}

@end
