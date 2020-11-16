//
//  XXHTTPRequestManager.h
//  XXHTTPRequestManager
//
//  Created by Shawn on 2019/3/7.
//  Copyright © 2019 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XXRequest.h"
#import "XXHTTPRequestManagerAdapter.h"

extern NSString * const XXHTTPRequestManagerAdapterNullExceptionName;

extern NSString * const XXHTTPRequestManagerErrorDomain;

@class XXHTTPRequestManager;

@protocol XXHTTPRequestManagerIntercept <NSObject>

@optional

- (BOOL)HTTPRequestManager:(XXHTTPRequestManager *)requestManager refuseRequest:(id<XXRequest>)request;

- (id<XXRequest>)HTTPRequestManager:(XXHTTPRequestManager *)requestManager modifyRequest:(id<XXRequest>)request;

- (id<XXResponse>)HTTPRequestManager:(XXHTTPRequestManager *)requestManager modifyResponse:(id<XXResponse>)response request:(id<XXRequest>)request;

@end

@interface XXHTTPRequestManager : NSObject

+ (instancetype)defaultRequestManager;

- (instancetype)initWithRequestAdapterClass:(Class)adapterClass;

#pragma mark - request

- (id<XXHTTPRequestManagerAdapter>)requestAdapter;

- (void)setRequestAdapter:(id<XXHTTPRequestManagerAdapter>)requestAdapter;

- (id<XXRequestOperation>)sendRequest:(id<XXRequest>)request completion:(XXHTTPRequestHandleCompletion)completion;

#pragma mark - Intercept

- (void)registerIntercept:(id<XXHTTPRequestManagerIntercept>)intercept;

- (void)unregisterIntercept:(id<XXHTTPRequestManagerIntercept>)intercept;

- (NSArray *)intercepts;

@end
