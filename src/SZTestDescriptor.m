//
// SZTestDescriptor.m
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

#import "SZTestDescriptor.h"


@implementation SZTestDescriptor
@synthesize type;
@synthesize state;
@synthesize enabled;
@synthesize name;
@synthesize index;

-(id)initSuite:(NSString*)theName
{
    self = [super init];
    if(self != nil)
    {
        self.name = theName;
        self.state = TestUnknown;
        self.type = TestsuiteType;
        self.enabled = YES;
        self.index = ~0;
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
        self.type = TestcaseType;
        self.enabled = YES;
        self.index = ~0;
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
    test.enabled = self.enabled;
    return test;
}

@end
