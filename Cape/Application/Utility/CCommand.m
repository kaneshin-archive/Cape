// CCommand.m
//
// Copyright (c) 2015 Shintaro Kaneko
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CCommand.h"

#import "Common.h"

@implementation CCommand

static int lastTerminationStatus = 0;

+ (int)lastTerminationStatus {
    return lastTerminationStatus;
}

+ (NSString *__nullable)which:(NSString *__nonnull)command {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *standardOutput = [NSPipe pipe];
    NSPipe *standardError = [NSPipe pipe];
    [task setStandardOutput:standardOutput];
    [task setStandardError:standardError];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:[[NSBundle mainBundle].bundlePath stringByDeletingLastPathComponent]];

    NSArray *run = @[@"which", command];
    NSArray *args = [NSArray arrayWithObjects:@"-c", [run componentsJoinedByString:@" "], nil];
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];

    lastTerminationStatus = [task terminationStatus];
    if (lastTerminationStatus == 0) {
        NSData *data = standardOutput.fileHandleForReading.availableData;
        if (data) {
            NSString *path = [NSString stringWithUTF8String:(char *)data.bytes];
            return [path stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }

    return nil;
}

+ (int)launch:(NSString *__nonnull)command withArguments:(NSArray *__nullable)arguments {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:[[NSBundle mainBundle].bundlePath stringByDeletingLastPathComponent]];

    NSString *path = [[self class] which:command];
    if (!path) {
        path = command;
    }
    NSArray *run = [@[path] arrayByAddingObjectsFromArray:arguments];
    NSArray *args = [NSArray arrayWithObjects:@"-c", [run componentsJoinedByString:@" "], nil];
    [task setArguments:args];
    [task launch];
    [task waitUntilExit];

    lastTerminationStatus = [task terminationStatus];
    return lastTerminationStatus;
}

+ (void)launch:(NSString *__nonnull)command withArguments:(NSArray *__nullable)arguments completionHandler:(void (^ __nullable)(NSTask *__nonnull))completionBlock {
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    [task setCurrentDirectoryPath:[[NSBundle mainBundle].bundlePath stringByDeletingLastPathComponent]];

    NSString *path = [[self class] which:command];
    if (!path) {
        path = command;
    }
    NSArray *run = [@[path] arrayByAddingObjectsFromArray:arguments];
    NSArray *args = [NSArray arrayWithObjects:@"-c", [run componentsJoinedByString:@" "], nil];
    LogDebug(@"%@", args);
    [task setArguments:args];
    [task launch];
    [task setTerminationHandler:^(NSTask *task) {
        lastTerminationStatus = [task terminationStatus];
        if (completionBlock) {
            completionBlock(task);
        }
    }];
}

@end
