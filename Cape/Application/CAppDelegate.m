// CAppDelegate.m
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

#import "CAppDelegate.h"

#import "Common.h"
#import "CScreenCapture.h"
#import "CRequest.h"

@interface CAppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@property (nonatomic, strong) CScreenCapture *lastCapture;
@end

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    dispatch_after(0.3, dispatch_get_main_queue(), ^{
        [self newScreenCapture:nil];
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
}

- (NSURL *)URLOfRoutesFile {
    return [[NSBundle mainBundle] URLForResource:@"Routes" withExtension:@"plist"];
}

- (NSURL *)URLOfCapeFile {
    NSString *filename = @".cape";
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    return [[NSURL alloc] initFileURLWithPath:path];
}

- (NSArray *__nonnull)routes {
    NSMutableArray *routes = [NSMutableArray arrayWithContentsOfURL:[self URLOfRoutesFile]];
    NSURL *infoURL = [self URLOfCapeFile];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoURL.path]) {
        NSError *error = nil;
        NSString *string = [NSString stringWithContentsOfURL:infoURL encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            LogDebug(@"%@", error.localizedDescription);
        } else {
            NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error = nil;
            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
            if (error) {
                LogDebug(@"%@", error.localizedDescription);
            } else if (json) {
                [routes addObjectsFromArray:json];
            }
        }
    }
    return routes;
}

- (IBAction)newScreenCapture:(id)sender {
    __weak typeof(self) weakSelf = self;
    [CScreenCapture launchWithCompletionHandler:^(CScreenCapture *capture) {
        weakSelf.lastCapture = capture;
        [weakSelf sendScreenCapture:capture];
    }];
}

- (void)sendScreenCapture:(CScreenCapture *)capture {
    if (!capture.data) {
        LogDebug(@"There is no data.");
        return;
    }
    for (NSDictionary *route in [self routes]) {
        if (![route[@"enable"] boolValue]) {
            continue;
        }
        CRequest *req = [CRequest new];
        [req requestWithMethod:route[@"method"]
                     URLString:route[@"url"]
                    parameters:route[@"parameters"]
              constructingBody:^(id<CMultipartFormData> formData) {
                  [formData appendPartWithFileData:capture.data name:route[@"name"] filename:capture.filename];
              } success:^(NSData *data) {
                  LogDebug(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              } failure:^(NSError *error) {
                  LogDebug(@"%@", error.localizedDescription);
              }];
    }
}

- (IBAction)sendCaptureFile:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"png", @"jpg", @"jpeg", @"tiff"]];
    NSInteger result = [panel runModal];
    switch (result) {
        case NSOKButton: {
            CScreenCapture *capture = [[CScreenCapture alloc] initWithURL:panel.URL];
            [self sendScreenCapture:capture];
            break;
        }
        case NSCancelButton:
            break;
        default:
            break;
    }
}

- (IBAction)saveLastTakenCapture:(id)sender {
    if (!self.lastCapture) {
        return;
    }
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setAllowedFileTypes:@[@"png"]];
    panel.canCreateDirectories = YES;
    panel.showsTagField = NO;
    NSInteger result = [panel runModal];
    switch (result) {
        case NSOKButton:
            [[NSFileManager defaultManager] copyItemAtURL:self.lastCapture.URL toURL:panel.URL error:nil];
            break;
        case NSCancelButton:
            break;
        default:
            break;
    }
}

- (IBAction)openRoutesFile:(id)sender {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace openURL:[self URLOfRoutesFile]];
}

- (IBAction)openCapeFile:(id)sender {
    NSURL *url = [self URLOfCapeFile];
    if (![[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        NSURL *sample = [[NSBundle mainBundle] URLForResource:@"sample" withExtension:@"json"];
        NSData *contents = [NSData dataWithContentsOfURL:sample];
        [[NSFileManager defaultManager] createFileAtPath:url.path contents:contents attributes:nil];
    }
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    [workspace openURL:[self URLOfCapeFile]];
}

@end
