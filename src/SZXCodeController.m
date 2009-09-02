//
// SZXCodeController.m
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

#import "SZXCodeController.h"


@implementation SZXCodeController
-(id)init
{
    self = [super init];
    if(self != nil)
    {
        // TODO: Check if XCode is running
        NSString* path = [[NSBundle mainBundle] pathForResource:@"XcodeUnitTestGUI"
                                                         ofType:@"scpt"
                                                    inDirectory:@"Scripts"];
        if (path != nil)
        {
            NSURL* url = [NSURL fileURLWithPath:path];
            if(url != nil)
            {
                scriptInterface = [[SZApplescriptInterface alloc] init];
                script = [[scriptInterface loadScript:url] retain];
            }
            else
            {
                NSLog(@"Can't create URL");
            }
        }
        else
        {
            NSLog(@"Can't locate script");
        }
    }
    return self;
}

-(void)dealloc
{
    [scriptInterface release];
    [script release];
    [super dealloc];
}

-(NSString*)currentProject
{
    NSString* result = [scriptInterface runSubroutine:@"getActiveProjectName"
                                             ofScript:script
                                             withArgs:[NSArray array]];
    return result;    
}

-(NSArray*)unitTestTargets
{
    NSArray* result = [scriptInterface runSubroutine:@"getUnitTestTargets"
                                            ofScript:script
                                            withArgs:[NSArray array]];
    return result;
}

-(NSArray*)unitTestConfigs:(NSString*)theTargetName
{
    NSAppleEventDescriptor* nameDescr = [NSAppleEventDescriptor descriptorWithString:theTargetName];

    NSArray* result = [scriptInterface runSubroutine:@"getUnitTestConfigs"
                                            ofScript:script
                                            withArgs:[NSArray arrayWithObject:nameDescr]];
    return result;
}

-(NSString*)runUnitTest
{    
    NSString* result = [scriptInterface runSubroutine:@"doBuild"
                                             ofScript:script
                                             withArgs:[NSArray array]];
    return result;
}

-(NSString*)currentBuildConfig
{
    NSString* result = [scriptInterface runSubroutine:@"getCurrentBuildConfig"
                                             ofScript:script
                                             withArgs:[NSArray array]];    
    return result;
}

-(void)setCurrentBuildConfig:(NSString*)theConfigName
{
    NSAppleEventDescriptor* configName = [NSAppleEventDescriptor descriptorWithString:theConfigName];
    
    [scriptInterface runSubroutine:@"setCurrentBuildConfig"
                          ofScript:script
                          withArgs:[NSArray arrayWithObject:configName]];    
}

-(NSString*)currentTarget
{
    NSString* result = [scriptInterface runSubroutine:@"getCurrentTarget"
                                             ofScript:script
                                             withArgs:[NSArray array]];    
    return result;
}

-(void)setCurrentTarget:(NSString*)theTargetName
{
    NSAppleEventDescriptor* targetDescr = [NSAppleEventDescriptor descriptorWithString:theTargetName];

    [scriptInterface runSubroutine:@"setCurrentTarget"
                          ofScript:script
                          withArgs:[NSArray arrayWithObject:targetDescr]];
}

-(NSString*)pathToTarget:(NSString*)theName
{
    NSAppleEventDescriptor* nameDescr = [NSAppleEventDescriptor descriptorWithString:theName];
    NSString* result = [scriptInterface runSubroutine:@"getUnitTestTargetPath"
                                             ofScript:script
                                             withArgs:[NSArray arrayWithObject:nameDescr]];
    return result;
}

-(void)updateBuildSetting:(NSString*)theTargetName
                buildConf:(NSString*)theBuildConf
              settingName:(NSString*)theSettingName
                    value:(NSString*)theValue
{
    NSAppleEventDescriptor* targetName = [NSAppleEventDescriptor descriptorWithString:theTargetName];
    NSAppleEventDescriptor* buildConf = [NSAppleEventDescriptor descriptorWithString:theBuildConf];
    NSAppleEventDescriptor* settingName = [NSAppleEventDescriptor descriptorWithString:theSettingName];
    NSAppleEventDescriptor* settingValue = [NSAppleEventDescriptor descriptorWithString:theValue];
    [scriptInterface runSubroutine:@"modifyBuildSetting"
                          ofScript:script
                          withArgs:[NSArray arrayWithObjects:targetName, buildConf, settingName, settingValue, nil]];

}
@end
