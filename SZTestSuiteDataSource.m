//
//  SZTestSuiteDataSource.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZTestSuiteDataSource.h"
#import "SZUnitTestCell.h"

@implementation SZTestSuiteDataSource
@synthesize suites;
@synthesize tests;


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
        for(NSUInteger i = 0; i < [suites count]; ++i)
        {
            if([[suites objectAtIndex:i] isEqualToString:item])
            {
                return [[tests objectAtIndex:i] objectAtIndex:index];
            }
        }        
    }
    return nil;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
  isItemExpandable:(id)item
{
    for(NSUInteger i = 0; i < [suites count]; ++i)
    {
        if([[suites objectAtIndex:i] isEqualToString:item])
        {            
            return YES;            
        }
    }
    
    return NO;
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
        for(NSUInteger i = 0; i < [suites count]; ++i)
        {
            if([[suites objectAtIndex:i] isEqualToString:item])
            {
                return [[tests objectAtIndex:i] count];
            }
        }        
    }
    return 0;
}

-(void)outlineView:(NSOutlineView*)outlineView
   willDisplayCell:(id)cell
    forTableColumn:(NSTableColumn*)tableColumn
               item:(id)item
{
    SZUnitTestCell* c = cell;
    if([item hasPrefix:@"test"])
    {
        [c setState:testPassed];
    }
    else
    {
        [c setState:testFailed];
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
    NSCell* cell = [[[SZUnitTestCell alloc] init] autorelease];
    return cell;    
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
shouldEditTableColumn:(NSTableColumn *)tableColumn
              item:(id)item
{
    // No editing ever allowed
    return NO;
}



@end
