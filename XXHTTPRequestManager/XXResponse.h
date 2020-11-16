//
//  XXResponse.h
//  XXHTTPRequestManager
//
//  Created by Shawn on 2019/3/8.
//  Copyright © 2019 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XXResponse <NSObject>

- (NSUInteger)statusCode;

@optional

- (id)responseObject;

- (NSError *)error;

@end

