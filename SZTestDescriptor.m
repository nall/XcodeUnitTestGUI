//
//  SZTestDescriptor.m
//  XcodeUnitTestGUI
//
//  Created by Jon Nall on 8/30/09.
//  Copyright 2009 STUNTAZ!!!. All rights reserved.
//

#import "SZTestDescriptor.h"


@implementation SZTestDescriptor
@synthesize type;
@synthesize state;
@synthesize name;

-(id)initSuite:(NSString*)theName
{
    self = [super init];
    if(self != nil)
    {
        self.name = theName;
        self.state = TestUnknown;
        self.type = TestsuiteType;
    }
    return self;
}

-(id)initTest:(NSString*)theName inSuite:(NSString*)theSuiteName
{
    self = [super init];
    if(self != nil)
    {
        self.name = theName;
        parentName = [theSuiteName retain];
        self.state = TestUnknown;
        self.type = TestsuiteType;
    }
    return self;    
}

-(void)dealloc
{
    [name release];
    [parentName release];
    [super dealloc];
}

-(NSString*)description
{
    return name;
}

-(id)copyWithZone:(NSZone*)theZone
{
    SZTestDescriptor* test = nil;
    
    if(self.type == TestsuiteType)
    {
        test = [[[self class] allocWithZone:theZone] initSuite:self.name];
    }
    else
    {
        test = [[[self class] allocWithZone:theZone] initTest:self.name inSuite:parentName];
    }

    test.state = self.state;
    return test;
}

@end
