// CRequest.h
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

#import <Foundation/Foundation.h>

@protocol CMultipartFormData
- (void)appendPartWithFileData:(NSData *__nonnull)data
                          name:(NSString *__nonnull)name
                      filename:(NSString *__nonnull)filename;
@end

@interface CRequest : NSObject
- (void)requestWithMethod:(NSString *__nonnull)method
                URLString:(NSString *__nonnull)urlString
               parameters:(NSDictionary *__nullable)parameters
         constructingBody:(void (^ __nullable)(id <CMultipartFormData> __nonnull))constructingBody
                  success:(void (^ __nullable)(NSData *__nonnull))success
                  failure:(void (^ __nullable)(NSError *__nullable))failure;
@end
