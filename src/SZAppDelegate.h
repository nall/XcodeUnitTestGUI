//
// SZAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import "SZXCodeController.h"
#import "SZTestSuiteDataSource.h"

@interface SZAppDelegate : NSObject
{
    SZXCodeController* xcodeController;
    NSString* curProject;
    NSString* curTarget;
    NSString* curConfig;

    NSArray* runTypes;
    NSArray* bundles;
    NSArray* configs;
    NSBundle* curBundle;
    NSOperationQueue* queue;
    BOOL isBuilding;
    BOOL testsValid;
    
    NSUInteger testFailureCount;
    NSUInteger testTotalCount;
    NSUInteger suiteFailureCount;
    NSUInteger suiteTotalCount;
    
    IBOutlet SZTestSuiteDataSource* dataSource;
    IBOutlet NSOutlineView* outlineView;
    IBOutlet NSPopUpButton* targetButton;
    IBOutlet NSPopUpButton* configButton;
    
    IBOutlet NSPopUpButton* runTypeButton;
    IBOutlet NSTextField* resultLabel;
}
@property (retain) NSArray* configs;
@property (retain) NSArray* bundles;
@property (retain) NSArray* runTypes;

@property (assign) BOOL isBuilding;
@property (assign) BOOL testsValid;
@property (readonly) BOOL runEnabled;

@property (retain) NSString* curProject;
@property (retain) NSString* curTarget;
@property (retain) NSString* curConfig;

-(IBAction)bundleChanged:(id)sender;
-(IBAction)configChanged:(id)sender;
-(IBAction)runTests:(id)sender;
-(IBAction)filterTests:(id)sender;
@end
