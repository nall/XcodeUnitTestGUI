//
// SZTestSuiteDataSource.m
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

#import "SZTestSuiteDataSource.h"
#import "SZTestDescriptor.h"

@implementation SZTestSuiteDataSource
@synthesize suites;
@synthesize tests;

-(id)init
{
    self = [super init];
    if(self != nil)
    {
        testCell = [[NSBrowserCell alloc] init];
        [testCell setLeaf:YES];
        
        enableCell = [[NSButtonCell alloc] init];
        [enableCell setEnabled:YES];
        [enableCell setAllowsMixedState:YES];
        [enableCell setButtonType:NSSwitchButton];
        [enableCell setStringValue:@""];
        [enableCell setAlternateTitle:@""];
        [enableCell setAttributedTitle:@""];
        [enableCell setTarget:self];
        [enableCell setAction:@selector(enableClicked:)];
        
        passedImage = [[NSImage imageNamed:@"testStatePassed"] retain];
        failedImage = [[NSImage imageNamed:@"testStateFailed"] retain];
        unknownImage = [[NSImage imageNamed:@"testStateUnknown"] retain];        
    }
    return self;
}

-(void)dealloc
{
    [testCell release];
    [enableCell release];
    [super dealloc];
}

-(NSInteger)suiteState:(const NSUInteger)theIndex
{
    NSInteger buttonState = NSOnState;
    
    NSArray* testArray = [tests objectAtIndex:theIndex];
    BOOL foundOn = NO;
    for(SZTestDescriptor* t in testArray)
    {
        if(t.enabled == NO)
        {
            // If we find anything off, transition to mixed
            buttonState = NSMixedState;
        }
        
        // Track if we found any that were on
        foundOn |= t.enabled;
    }
    
    // If we found none on, transition to off
    if(foundOn == NO)
    {
        buttonState = NSOffState;
    }
    
    return buttonState;
}

-(void)enableClicked:(id)sender
{
    const NSUInteger row = [outlineView clickedRow];
    SZTestDescriptor* t = [outlineView itemAtRow:row];
    if(t.type == TestcaseType)
    {
        t.enabled = !t.enabled;      
    }
    else
    {
        const NSInteger state = [self suiteState:t.index];
        BOOL updateTests = NO;
        NSInteger newState = state;
        switch(state)
        {
            case NSOffState:
            {
                newState = NSOnState;
                updateTests = YES;
                break;
            }
            case NSOnState:
            {
                newState = NSOffState;
                updateTests = YES;
                break;
            }
            case NSMixedState:
                // Do nothing
                updateTests = NO;
                break;
            default:
                NSBeep();
                NSLog(@"Unexpected Button State: %d", state);
        }
        
        if(updateTests)
        {
            NSArray* testArray = [tests objectAtIndex:t.index];
            for(SZTestDescriptor* test in testArray)
            {
                test.enabled = (newState == NSOnState) ? YES : NO;
            }
            
            t.enabled = (newState == NSOnState) ? YES : NO;
        }
    }
    [outlineView reloadData];
}

-(NSImage*)stateToImage:(const enum TestState)theState
{
    switch(theState)
    {
        case TestPassed: return passedImage;
        case TestFailed: return failedImage;
        case TestUnknown: return unknownImage;
        default:
        {
            NSBeep();
            NSLog(@"Unexpected state: %d", theState);
        }
    }
    return nil;            
}

-(id)outlineView:(NSOutlineView*)outlineView
            child:(NSInteger)index
          ofItem:(id)item
{    
    if(item == nil)
    {
        return [suites objectAtIndex:index];
    }
    else
    {
        SZTestDescriptor* t = item;
        return [[tests objectAtIndex:t.index] objectAtIndex:index];
    }
    return nil;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
  isItemExpandable:(id)item
{
    SZTestDescriptor* t = item;
    return t.type == TestsuiteType;
}

-(NSInteger)outlineView:(NSOutlineView*)outlineView
 numberOfChildrenOfItem:(id)item
{
    if(item == nil)
    {
        return [suites count];
    }
    else
    {
        SZTestDescriptor* t = item;
        return [[tests objectAtIndex:t.index] count];
    }
    return 0;
}

-(void)outlineView:(NSOutlineView*)outlineView
   willDisplayCell:(id)theCell
    forTableColumn:(NSTableColumn*)tableColumn
               item:(id)item
{
    SZTestDescriptor* test = item;
    if([[tableColumn identifier] isEqualToString:@"tests"])
    {
        NSBrowserCell* c = theCell;
        [c setImage:[self stateToImage:test.state]];
        [c setStringValue:test.name];
    }
    else
    {
        NSButtonCell* c = theCell;
        if(test.type == TestcaseType)
        {
            [c setState:(test.enabled) ? NSOnState : NSOffState];            
        }
        else
        {
            [c setState:[self suiteState:test.index]];
        }
    }
    
}

-(id)outlineView:(NSOutlineView*)outlineView
objectValueForTableColumn:(NSTableColumn*)tableColumn
          byItem:(id)item
{
    return item;
}

-(NSCell*)outlineView:(NSOutlineView*)outlineView
dataCellForTableColumn:(NSTableColumn*)tableColumn
                 item:(id)item
{
    if(tableColumn == nil)
    {
        // Use different cells for each column
        return nil;
    }
    
    if([[tableColumn identifier] isEqualToString:@"tests"])
    {
        return testCell;        
    }
    else
    {
        return enableCell;
    }
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
shouldEditTableColumn:(NSTableColumn *)tableColumn
              item:(id)item
{
    // No editing ever allowed
    return NO;
}

-(void)invalidateStates
{
    for(SZTestDescriptor* t in suites)
    {
        t.state = TestUnknown;
    }
    for(NSArray* a in tests)
    {
        for(SZTestDescriptor* t in a)
        {
            t.state = TestUnknown;
        }
    }
}


@end
