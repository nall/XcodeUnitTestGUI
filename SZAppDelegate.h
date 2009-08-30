//
//  SZAppDelegate.h
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/29/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SZXCodeController.h"

@interface SZAppDelegate : NSObject
{
    SZXCodeController* xcodeController;
}
-(IBAction)showFiles:(id)sender;
@end
