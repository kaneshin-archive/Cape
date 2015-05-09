// CRequest.m
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

#import "CRequest.h"

#define BOUNDARY   @"CAPEBOUNDARY"
#define CRLF        @"\r\n"

static inline NSData *
dataFromString(NSString *str) {
    return [str dataUsingEncoding:NSUTF8StringEncoding];
}

@interface CConstructingBody : NSObject <CMultipartFormData>
@property (nonatomic, strong, nonnull) NSData *data;
@property (nonatomic, strong, nonnull) NSString *name;
@property (nonatomic, strong, nonnull) NSString *filename;
@end

@implementation CConstructingBody

- (void)appendPartWithFileData:(NSData *__nonnull)data
                          name:(NSString *__nonnull)name
                      filename:(NSString *__nonnull)filename
{
    self.data = data;
    self.name = name;
    self.filename = filename;
}

- (NSData *__nonnull)formData {
    NSMutableData *body = [NSMutableData data];
    if (self.data) {
        dataFromString(@"a");
        [body appendData:dataFromString([NSString stringWithFormat:@"--%@%@", BOUNDARY, CRLF])];
        [body appendData:dataFromString([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"%@",
                                         self.name, self.filename, CRLF])];
        [body appendData:dataFromString([NSString stringWithFormat:@"Content-Type: %@", [self mimeType]])];
        [body appendData:dataFromString([NSString stringWithFormat:@"%@%@", CRLF, CRLF])];
        [body appendData:self.data];
        [body appendData:dataFromString(CRLF)];
    }
    return body;
}

- (NSString *)mimeType {
    return [[self class] contentTypeFromImageData:self.data];
}

+ (NSString *)contentTypeFromImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];

    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

@end

@implementation CRequest


- (void)requestWithMethod:(NSString *__nonnull)method
                URLString:(NSString *__nonnull)urlString
               parameters:(NSDictionary *__nullable)parameters
         constructingBody:(void (^ __nullable)(id <CMultipartFormData> __nonnull))constructingBody
                  success:(void (^ __nullable)(NSData *__nonnull))success
                  failure:(void (^ __nullable)(NSError *__nullable))failure
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:method];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", BOUNDARY];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    for (NSString *name in parameters.allKeys) {
        [body appendData:dataFromString([NSString stringWithFormat:@"--%@%@", BOUNDARY, CRLF])];
        [body appendData:dataFromString([NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"", name])];
        [body appendData:dataFromString([NSString stringWithFormat:@"%@%@", CRLF, CRLF])];
        [body appendData:dataFromString([NSString stringWithFormat:@"%@", parameters[name]])];
        [body appendData:dataFromString(CRLF)];
    }
    if (constructingBody) {
        CConstructingBody *cb = [CConstructingBody new];
        constructingBody(cb);
        if (cb.data) {
            [body appendData:[cb formData]];
        }
    }
    [body appendData:dataFromString([NSString stringWithFormat:@"--%@--", BOUNDARY])];
    [request setHTTPBody:body];

    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURLSessionDataTask *uploadTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (response && data) {
            if (success) {
                success(data);
                return;
            }
        }
        if (failure) {
            failure(error);
        }
        return;
    }];
    [uploadTask resume];
}

@end
