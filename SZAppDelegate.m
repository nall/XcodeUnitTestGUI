//
//  SZAppDelegate.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/29/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZAppDelegate.h"
#include <objc/objc-runtime.h>

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
    
}

-(void)applicationWillTerminate:(NSNotification*)theNotification
{
    [xcodeController release];
    [curProject release];
    [bundles release];
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
    NSBundle* unitTestBundle = [NSBundle bundleWithPath:basePath];
    if(unitTestBundle == nil)
    {
        NSLog(@"ERROR Loading Bundle");
        return;
    }
    else
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bundleDidLoad:)
                                                     name:NSBundleDidLoadNotification
                                                   object:unitTestBundle];

        // Force loading of classes
        [unitTestBundle principalClass];
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
            [self loadBundle:[bundles objectAtIndex:0]];            
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
                NSLog(@"\tTEST: %@", methName);                
                [[methods lastObject] addObject:methName];
            }
        }
    }
    
    dataSource.classes = classes;
    dataSource.methods = methods;
    [outlineView reloadData];
}


-(IBAction)showFiles:(id)sender
{
    if([bundles count] > 0)
    {
        NSString* bundleName = [bundles objectAtIndex:0];
        NSString* basePath = [xcodeController pathToBundle:bundleName];
        NSString* executable = [[[basePath stringByAppendingPathComponent:@"Contents"]
                                stringByAppendingPathComponent:@"MacOS"]
                                stringByAppendingPathComponent:bundleName];
        NSLog(@"%@ -> %@", bundleName, executable);
        
        NSBundle* unitTestBundle = [[NSBundle alloc] initWithPath:basePath];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bundleDidLoad:)
                                                     name:NSBundleDidLoadNotification
                                                   object:unitTestBundle];
        
        if(unitTestBundle == nil)
        {
            NSLog(@"ERROR Loading Bundle");
            return;
        }
        
        NSLog(@"bundle info: %@", [unitTestBundle infoDictionary]);
        NSLog(@"principal class: %@", [unitTestBundle principalClass]);
    }
}

@end
