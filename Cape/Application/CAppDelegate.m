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

#import "CScreenCapture.h"
#import "CRequest.h"

@interface CAppDelegate ()
@property (weak) IBOutlet NSWindow *window;
@end

@implementation CAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    CScreenCapture *capture = [CScreenCapture launch];
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
                  NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
              } failure:^(NSError *error) {
                  NSLog(@"%@", error.localizedDescription);
              }];
    }
}

- (NSArray *__nonnull)routes {
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"Routes" withExtension:@"plist"];
    NSMutableArray *routes = [NSMutableArray arrayWithContentsOfURL:url];
    NSString *filename = @".cape";
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:filename];
    NSURL *infoURL = [[NSURL alloc] initFileURLWithPath:path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:infoURL.path]) {
        NSString *string = [NSString stringWithContentsOfURL:infoURL encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        if (json) {
            [routes addObjectsFromArray:json];
        }
    }
    return routes;
}

@end
