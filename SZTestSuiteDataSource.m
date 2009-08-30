//
//  SZTestSuiteDataSource.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZTestSuiteDataSource.h"


@implementation SZTestSuiteDataSource
@synthesize classes;
@synthesize methods;

-(id)outlineView:(NSOutlineView*)outlineView
            child:(NSInteger)index
          ofItem:(id)item
{    
    if(item == nil)
    {
        return [classes objectAtIndex:index];
    }
    else
    {
        for(NSUInteger i = 0; i < [classes count]; ++i)
        {
            if([[classes objectAtIndex:i] isEqualToString:item])
            {
                return [[methods objectAtIndex:i] objectAtIndex:index];
            }
        }        
    }
    return nil;
}

-(BOOL)outlineView:(NSOutlineView*)outlineView
  isItemExpandable:(id)item
{
    for(NSUInteger i = 0; i < [classes count]; ++i)
    {
        if([[classes objectAtIndex:i] isEqualToString:item])
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
        return [classes count];
    }
    else
    {
        for(NSUInteger i = 0; i < [classes count]; ++i)
        {
            if([[classes objectAtIndex:i] isEqualToString:item])
            {
                return [[methods objectAtIndex:i] count];
            }
        }        
    }
    return 0;
}

-(id)outlineView:(NSOutlineView*)outlineView
objectValueForTableColumn:(NSTableColumn*)tableColumn
          byItem:(id)item
{
    return item;
}


@end
