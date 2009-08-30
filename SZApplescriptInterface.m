//
//  SZApplescriptInterface.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZApplescriptInterface.h"
#include <Carbon/Carbon.h>

@interface SZApplescriptInterface(Private)
-(id)descriptorToObject:(NSAppleEventDescriptor *)theDescriptor;
-(NSArray*)descriptorToArray:(NSAppleEventDescriptor*)theDescriptor;
-(NSDictionary*)descriptorToDict:(NSAppleEventDescriptor*)theDescriptor;
@end

@implementation SZApplescriptInterface

-(NSAppleScript*)loadScript:(NSURL*)theURL
{
    NSDictionary* errors = [NSDictionary dictionary];
    NSAppleScript* script = [[NSAppleScript alloc] initWithContentsOfURL:theURL
                                                                   error:&errors];
    if(script == nil)
    {
        NSLog(@"ERROR LOADING SCRIPT: %@", errors);
    }
    else
    {
        NSLog(@"Script loaded OK");
    }
    
    return [script autorelease];
}

-(id)runSubroutine:(NSString*)theRoutine
          ofScript:(NSAppleScript*)theScript
          withArgs:(NSArray*)theArgs
{
    NSAppleEventDescriptor* parameters = [NSAppleEventDescriptor listDescriptor];
    for(NSUInteger paramIdx = 0; paramIdx < [theArgs count]; ++paramIdx)
    {
        // List indices are 1-based
        [parameters insertDescriptor:[theArgs objectAtIndex:paramIdx] atIndex:(paramIdx + 1)];
    }
    
    // create the AppleEvent target
    ProcessSerialNumber psn = {0, kCurrentProcess};
    NSAppleEventDescriptor* target = [NSAppleEventDescriptor descriptorWithDescriptorType:typeProcessSerialNumber
                                                                                    bytes:&psn
                                                                                   length:sizeof(ProcessSerialNumber)];
    
    NSAppleEventDescriptor* handler = [NSAppleEventDescriptor descriptorWithString:[theRoutine lowercaseString]];
    
    // create the event for an AppleScript subroutine,
    // set the method name and the list of parameters
    NSAppleEventDescriptor* event = [NSAppleEventDescriptor appleEventWithEventClass:kASAppleScriptSuite
                                                                             eventID:kASSubroutineEvent
                                                                    targetDescriptor:target
                                                                            returnID:kAutoGenerateReturnID
                                                                       transactionID:kAnyTransactionID];
    [event setParamDescriptor:handler
                   forKeyword:keyASSubroutineName];
    [event setParamDescriptor:parameters
                   forKeyword:keyDirectObject];
    
    // call the event in AppleScript
    NSDictionary* errors = [NSDictionary dictionary];
    NSAppleEventDescriptor* result = [theScript executeAppleEvent:event error:&errors];
    if(result == nil)
    {
        NSLog(@"EXECUTE ERROR: %@", errors);
        return nil;
    }
    else
    {
        return [self descriptorToObject:result];
    }
}
@end

@implementation SZApplescriptInterface(Private)
-(id)descriptorToObject:(NSAppleEventDescriptor *)theDescriptor
{
    switch ([theDescriptor descriptorType]) {
        case typeChar:
        case typeUnicodeText:
            return [theDescriptor stringValue];
        case typeAEList:
            return [self descriptorToArray:theDescriptor];
        case typeAERecord:
            return [self descriptorToDict:theDescriptor];
            
        case typeBoolean:
            return [NSNumber numberWithBool:(BOOL)[theDescriptor booleanValue]];
        case typeTrue:
            return [NSNumber numberWithBool:YES];
        case typeFalse:
            return [NSNumber numberWithBool:NO];
        case typeType:
            return [NSNumber numberWithUnsignedLong:(unsigned long)[theDescriptor typeCodeValue]];
        case typeEnumerated:
            return [NSNumber numberWithUnsignedLong:(unsigned long)[theDescriptor enumCodeValue]];
        case typeNull:
            return [NSNull null];
            
        case typeSInt16:
            return [NSNumber numberWithInt:(short)[theDescriptor int32Value]];
        case typeSInt32:
            return [NSNumber numberWithInt:(int)[theDescriptor int32Value]];
        case typeUInt32:
            return [NSNumber numberWithLong:(unsigned int)[theDescriptor int32Value]];
        case typeSInt64:
            return [NSNumber numberWithLong:(long)[theDescriptor int32Value]];
    }
    
    NSLog(@"WARNING: Unexpected type: %@", theDescriptor);
    return [theDescriptor data];
}

-(NSDictionary*)descriptorToDict:(NSAppleEventDescriptor*)theDescriptor
{
    assert(FALSE);
    return nil;
}

-(NSArray*)descriptorToArray:(NSAppleEventDescriptor*)theDescriptor
{
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[theDescriptor numberOfItems]];
    for(NSUInteger i = 0; i < [theDescriptor numberOfItems]; ++i)
    {
        // Descriptor list is 1-based
        NSAppleEventDescriptor* descriptor = [theDescriptor descriptorAtIndex:(i + 1)];
        [result addObject:[self descriptorToObject:descriptor]];
    }
    
    return result;
}
@end

