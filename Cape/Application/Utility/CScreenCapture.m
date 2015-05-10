// CScreenCapture.m
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

#import "CScreenCapture.h"

#import "CCommand.h"

@interface CScreenCapture ()
@property (nonatomic, strong, readwrite, nullable) NSURL *URL;
@property (nonatomic, strong, readwrite, nullable) NSData *data;
@property (nonatomic, strong, readwrite, nullable) NSString *filename;
@end

@implementation CScreenCapture

- (instancetype)init {
    self = [super init];
    if (self) {
        self.URL = [self temporaryFileURL];
        self.data = nil;
    }
    return self;
}

- (nonnull instancetype)initWithURL:(NSURL *__nonnull)url {
    self = [super init];
    if (self) {
        self.URL = url;
        self.filename = url.lastPathComponent;
        self.data = nil;
    }
    return self;
}

+ (nonnull instancetype)launch {
    CScreenCapture *capture = [[CScreenCapture alloc] init];
    [capture launch];
    return capture;
}

+ (void)launchWithCompletionHandler:(void (^ __nullable)(CScreenCapture * __nonnull))completionBlock {
    CScreenCapture *capture = [[CScreenCapture alloc] init];
    [capture launchWithCompletionHandler:completionBlock];
}

- (int)launch {
    [CCommand launch:@"screencapture" withArguments:@[@"-i", [NSString stringWithFormat:@"\"%@\"", self.URL.path]]];
    return [CCommand lastTerminationStatus];
}

- (void)launchWithCompletionHandler:(void (^ __nullable)(CScreenCapture *__nonnull))completionBlock {
    [CCommand launch:@"screencapture" withArguments:@[@"-i", [NSString stringWithFormat:@"\"%@\"", self.URL.path]] completionHandler:^(NSTask *task) {
        if (completionBlock) {
            completionBlock(self);
        }
    }];
}

- (NSURL *)temporaryFileURL {
    self.filename = [NSString stringWithFormat:@"%d.png", (int)[NSDate date].timeIntervalSince1970];
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:self.filename];
    return [[NSURL alloc] initFileURLWithPath:path];
}

- (NSData * __nullable)data {
    if (_data == nil && self.URL) {
        _data = [NSData dataWithContentsOfURL:self.URL];
    }
    return _data;
}

@end
