//
//  XXResponse.h
//  XXHTTPRequestManager
//
//  Created by Shawn on 2019/3/8.
//  Copyright © 2019 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXRequest.h"
#import "XXResponse.h"

typedef void (^XXHTTPRequestHandleCompletion)(id<XXResponse> response);

@protocol XXHTTPRequestManagerAdapter <NSObject>

- (id<XXRequestOperation>)sendRequest:(id<XXRequest>)request successCompletion:(XXHTTPRequestHandleCompletion)completion;

@end

