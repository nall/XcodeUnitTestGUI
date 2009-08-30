//
//  SZAppDelegate.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/29/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZAppDelegate.h"

@implementation SZAppDelegate

-(void)applicationDidFinishLaunching:(NSNotification*)theNotification
{
    xcodeController = [[SZXCodeController alloc] init];
    
}

-(void)applicationWillTerminate:(NSNotification*)theNotification
{
    [xcodeController release];
}

-(void)bundleDidLoad:(NSNotification*)theNotification
{
    NSArray* classes = [[theNotification userInfo] objectForKey:@"NSLoadedClasses"];
    NSLog(@"LOADED: %@", classes);
}


-(IBAction)showFiles:(id)sender
{
    NSArray* bundles = [xcodeController unitTestBundles];
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
