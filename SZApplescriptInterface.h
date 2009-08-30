//
//  SZApplescriptInterface.h
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SZApplescriptInterface : NSObject
{

}
-(NSAppleScript*)loadScript:(NSURL*)theURL;
-(id)runSubroutine:(NSString*)theRoutine
          ofScript:(NSAppleScript*)theScript
          withArgs:(NSArray*)theArgs;
@end
