//
// SZAppDelegate.m
//
// Xcode Unit Test GUI
// Copyright (c) 2009 Jon Nall, STUNTAZ!!!
// All rights reserved.
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

#include <objc/objc-runtime.h>
#include <SenTestingKit/SenTestingKit.h>

#import "SZAppDelegate.h"
#import "SZTestDescriptor.h"

static NSString* const kszTopLevelTestSuite = @"XcodeUnitTestGUI";

@implementation SZAppDelegate
@synthesize isBuilding;
@synthesize testsValid;
@synthesize bundles;
@synthesize configs;
@synthesize runTypes;

@synthesize curProject;
@synthesize curTarget;
@synthesize curConfig;

-(void)applicationDidFinishLaunching:(NSNotification*)theNotification
{
    xcodeController = [[SZXCodeController alloc] init];
    queue = [[NSOperationQueue alloc] init];
    self.isBuilding = NO;
    self.testsValid = NO;
    
    [resultLabel setStringValue:@""];
    
    self.runTypes = [NSArray arrayWithObjects:kszAllTests, kszSelectedTests, nil];
    
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

-(void)applicationWillTerminate:(NSNotification*)theNotification
{
    [xcodeController release];
    [queue release];
    [curProject release];
    [bundles release];
    [configs release];
    [runTypes release];
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

+(NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key
{
    NSMutableSet* set = [NSMutableSet set];
    if([key isEqualToString:@"runEnabled"])
    {
        [set addObject:@"isBuilding"];
        [set addObject:@"testsValid"];
    }
    
    [set unionSet:[super keyPathsForValuesAffectingValueForKey:key]];
    
    return set;
}

-(BOOL)runEnabled
{
    return isBuilding == NO && testsValid == YES;
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
    
    ++testTotalCount;
}

-(void)testFailed:(NSNotification*)theNotification
{
//    NSLog(@"test failed: %@", theNotification);
    ++testFailureCount;
}

-(void)suiteStarted:(NSNotification*)theNotification
{
//    NSLog(@"suite started: %@", theNotification);
}

-(void)suiteStopped:(NSNotification*)theNotification
{
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
    
    NSLog(@"Suite finished: %@", name);
    if([name isEqualToString:kszTopLevelTestSuite])
    {
        // All tests complete. Print results.
        NSString* result;
        if(testFailureCount > 0)
        {
            result = [NSString stringWithFormat:@"%d of %d tests failed",
                      testFailureCount, testTotalCount];
        }
        else
        {
            result = @"All tests passed";
        }
        [resultLabel setStringValue:result];
        
        // Update runtypes popup
        self.runTypes = [NSArray arrayWithObjects:kszAllTests, kszSelectedTests, nil];
        if(testFailureCount > 0)
        {
            // Enable re-run failures if needed
            self.runTypes = [NSArray arrayWithObjects:kszAllTests, kszSelectedTests, kszFailingTests, nil];
        }
    }
    else
    {
        ++suiteTotalCount;
        if(hadFailures)
        {
            ++suiteFailureCount;
        }
    }
}

-(void)setCurBundle:(NSBundle*)theBundle
{
    [self willChangeValueForKey:@"curBundle"];
    [curBundle unload];
    self.testsValid = NO;
    [theBundle retain];
    [curBundle release];
    curBundle = theBundle;
    [self didChangeValueForKey:@"curBundle"];
}

-(NSBundle*)curBundle
{
    return curBundle;
}

-(void)loadBundle
{
    NSString* basePath = [xcodeController pathToTarget:[targetButton titleOfSelectedItem]];
    [self setCurBundle:[NSBundle bundleWithPath:basePath]];
    
    // Clear out the outline view. If we find stuff in bundleDidLoad we'll re-populate it
    dataSource.suites = [NSArray array];
    dataSource.tests = [NSArray array];
    [outlineView reloadData];
    
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

    @synchronized(self)
    {
        if(self.isBuilding == NO)
        {
            NSString* project = [xcodeController currentProject];
            NSString* target = [xcodeController currentTarget];
            NSString* config = [xcodeController currentBuildConfig];
            
            // Something changed. Reload.
            if([project isEqualToString:curProject] == NO ||
               [target isEqualToString:curTarget] == NO ||
               [config isEqualToString:curConfig] == NO)
            {
                self.testsValid = NO;
                [resultLabel setStringValue:@""];
                [self setConfigs:[NSArray array]];
                
                [self setCurProject:project];
                [self setCurTarget:target];
                [self setCurConfig:config];
                
                [self setBundles:[xcodeController unitTestTargets]];
                
                if([bundles count] > 0)
                {
                    [self setConfigs:[xcodeController unitTestConfigs:[targetButton titleOfSelectedItem]]];
                    [configButton selectItemWithTitle:config];
                    
                    [self loadBundle];
                }
                else
                {
                    dataSource.suites = [NSArray array];
                    dataSource.tests = [NSArray array];
                    [outlineView reloadData];
                }
            }        
        }        
    }
}

-(void)runTestsThread
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
 
    testFailureCount = 0;
    testTotalCount = 0;
    suiteFailureCount = 0;
    suiteTotalCount = 0;

    [resultLabel setStringValue:@"Building & Running tests..."];
    NSString* transcript = [xcodeController runUnitTest];
    (void)transcript;
    
    if(suiteTotalCount == 0)
    {
        // No tests ran. Probably a build error
        [resultLabel setStringValue:@"Possible build error. Check Xcode"];
    }

    [pool release];
    self.isBuilding = NO;
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
        [[suites lastObject] setIndex:[suites count] - 1];
        
        unsigned int numMethods;
        Method* methodList = class_copyMethodList(klass, &numMethods);
    
        [tests addObject:[NSMutableArray arrayWithCapacity:numMethods]];
        
        for(unsigned int i = 0; i < numMethods; ++i)
        {
            const char* methNameC = sel_getName(method_getName(methodList[i]));
            NSString* methName = [NSString stringWithCString:methNameC encoding:NSASCIIStringEncoding];
            if([methName hasPrefix:@"test"])
            {
                self.testsValid = YES;
                NSMutableArray* testArray = [tests lastObject];
                [testArray addObject:[[[SZTestDescriptor alloc] initTest:methName
                                                                 inSuite:className]
                                      autorelease]];
                [[testArray lastObject] setIndex:[testArray count] - 1];
            }
        }
    }
    
    dataSource.suites = suites;
    dataSource.tests = tests;
    [outlineView reloadData];
}

-(NSString*)generateCommandLine
{
    NSMutableString* string = [NSMutableString stringWithString:
                               @"-SenTestObserverClass SZSenTestNotifier -XcodeUnitTestGUI "];
    for(SZTestDescriptor* suite in dataSource.suites)
    {
        if(suite.enabled == NSOnState)
        {
            [string appendFormat:@"%@,", suite.name];
        }
        else if(suite.enabled == NSMixedState)
        {
            for(SZTestDescriptor* test in [dataSource.tests objectAtIndex:suite.index])
            {
                if(test.enabled)
                {
                    [string appendFormat:@"%@/%@,", suite.name, test.name];
                }
            }
        }
        else
        {
            // No tests selected in this test suite
        }
    }
    
    // Trim last comma
    return [string substringToIndex:[string length] - 1];
}

-(IBAction)bundleChanged:(id)sender
{
    @synchronized(self)
    {
        if([bundles count] > 0)
        {
            [xcodeController setCurrentTarget:[targetButton titleOfSelectedItem]];
            [self setConfigs:[xcodeController unitTestConfigs:[targetButton titleOfSelectedItem]]];
            [configButton selectItemWithTitle:[xcodeController currentBuildConfig]];
            
            [self loadBundle];
        }
    }
}

-(IBAction)configChanged:(id)sender
{
    @synchronized(self)
    {
        [xcodeController setCurrentBuildConfig:[configButton titleOfSelectedItem]];
        [self loadBundle];        
    }
}


-(IBAction)filterTests:(id)sender
{
    NSString* filter = [sender titleOfSelectedItem];
    if([filter isEqualToString:kszAllTests])
    {
        for(NSArray* tests in dataSource.tests)
        {
            for(SZTestDescriptor* test in tests)
            {
                test.enabled = NSOnState;
            }
        }
    }
    else if([filter isEqualToString:kszSelectedTests])
    {
        // Do nothing
    }
    else if([filter isEqualToString:kszFailingTests])
    {
        for(NSArray* tests in dataSource.tests)
        {
            for(SZTestDescriptor* test in tests)
            {
                const NSInteger state = (test.state == TestFailed) ? NSOnState : NSOffState;
                test.enabled = state;
            }
        }
    }
    else
    {
        NSBeep();
        NSLog(@"Unexpected filter: %@", filter);
        assert(FALSE);
    }
    
    for(SZTestDescriptor* suite in dataSource.suites)
    {
        [dataSource updateSuiteState:suite];
    }
    [outlineView reloadData];
}

-(IBAction)runTests:(id)sender
{
    self.isBuilding = YES;

    [dataSource invalidateStates];
    [outlineView reloadData];
    
    [xcodeController setCurrentTarget:[targetButton titleOfSelectedItem]];
    [xcodeController setCurrentBuildConfig:[configButton titleOfSelectedItem]];
    
    NSString* target = [targetButton titleOfSelectedItem];
    NSString* buildConf = [configButton titleOfSelectedItem];
    NSString* setting = @"OTHER_TEST_FLAGS";
    NSString* values = [self generateCommandLine];
    NSLog(@"running [%@]", values);

    [xcodeController updateBuildSetting:target
                              buildConf:buildConf
                            settingName:setting
                                  value:values];

    NSInvocationOperation* op = [[NSInvocationOperation alloc] initWithTarget:self
                                                                     selector:@selector(runTestsThread)
                                                                       object:nil];
    [queue addOperation:op];
}

@end
