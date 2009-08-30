//
//  SZSenTestNotifier.h
//  Charts
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SenTestingKit/SenTestingKit.h>

// To enable notications, compile this class with your unit test target and
// issue the following in Terminal:
//
// defaults write -globalDomain SenTestObserverClass -string "SZSenTestNotifier"

@interface SZSenTestNotifier : SenTestObserver
{

}

@end
