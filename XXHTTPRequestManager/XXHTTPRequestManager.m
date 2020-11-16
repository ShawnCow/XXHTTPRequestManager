//
//  XXHTTPRequestManager.m
//  XXHTTPRequestManager
//
//  Created by Shawn on 2019/3/7.
//  Copyright © 2019 Shawn. All rights reserved.
//

#import "XXHTTPRequestManager.h"

NSString * const XXHTTPRequestManagerAdapterNullExceptionName = @"XXHTTPRequestManagerAdapterNullExceptionName";
NSString * const XXHTTPRequestManagerErrorDomain = @"XXHTTPRequestManagerErrorDomain";

@interface XXHTTPRequestManager ()
{
    NSRecursiveLock *adapterLock;
    NSRecursiveLock *interceptLock;
    NSMutableArray *interceptArray;
    id<XXHTTPRequestManagerAdapter> requestAdapter;
//    dispatch_queue_t queue;
}
@end

@implementation XXHTTPRequestManager

+ (instancetype)defaultRequestManager
{
    static dispatch_once_t onceToken;
    static XXHTTPRequestManager *mgr;
    dispatch_once(&onceToken, ^{
        mgr = [[self alloc]initWithRequestAdapterClass:nil];
    });
    return mgr;
}

- (instancetype)initWithRequestAdapterClass:(Class)adapterClass
{
    self = [super init];
    if (self) {
        requestAdapter = [adapterClass new];
        adapterLock = [NSRecursiveLock new];
        interceptLock = [NSRecursiveLock new];
        interceptArray = [NSMutableArray array];
//        queue = dispatch_queue_create([[NSString stringWithFormat:@"com.shawn.network.%p",self] UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)registerIntercept:(id<XXHTTPRequestManagerIntercept>)intercept
{
    if (intercept == nil) {
        return;
    }
    [interceptLock lock];
    if ([interceptArray containsObject:intercept] == NO) {
        [interceptArray addObject:intercept];
    }
    [interceptLock unlock];
}

- (void)unregisterIntercept:(id<XXHTTPRequestManagerIntercept>)intercept
{
    if (intercept == nil) {
        return;
    }
    [interceptLock lock];
    [interceptArray removeObject:intercept];
    [interceptLock unlock];
}

- (NSArray *)intercepts
{
    [interceptLock lock];
    NSArray *items = [interceptArray copy];
    [interceptLock unlock];
    return items;
}

#pragma mark - getter and setter

- (id<XXHTTPRequestManagerAdapter>)requestAdapter
{
    id<XXHTTPRequestManagerAdapter> d = nil;
    [adapterLock lock];
    d = requestAdapter;
    [adapterLock unlock];
    return d;
}

- (void)setRequestAdapter:(id<XXHTTPRequestManagerAdapter>)aRequestAdapter
{
    if (aRequestAdapter == nil) {
#ifdef DEBUG
        [[NSException exceptionWithName:XXHTTPRequestManagerAdapterNullExceptionName reason:@"aequestAdapter is null" userInfo:nil] raise];
#endif
    }
    [adapterLock lock];
    requestAdapter = aRequestAdapter;
    [adapterLock unlock];
}

- (id<XXRequestOperation>)sendRequest:(id<XXRequest>)request completion:(XXHTTPRequestHandleCompletion)completion
{
    if (request == nil) {
        return nil;
    }
    
    if ([self _checkCanPostRequest:request]) {
        id<XXRequest> newRequest = [self _modifyRequest:request];
        id<XXHTTPRequestManagerAdapter> tempRequestAdapter = [self requestAdapter];
#ifdef DEBUG
        if (tempRequestAdapter == nil) {
            [[NSException exceptionWithName:XXHTTPRequestManagerAdapterNullExceptionName reason:@"aequestAdapter is null" userInfo:nil] raise];
        }
#endif
        return [tempRequestAdapter sendRequest:newRequest successCompletion:^(id<XXResponse> response) {
            id<XXResponse> newResponse = [self _modifyResponse:response request:newRequest];
            if (completion) {
                completion(newResponse);
            }
        }];;
    }
    
    return nil;
}

- (BOOL)_checkCanPostRequest:(id<XXRequest>)request
{
    NSArray * tempInterceptArray = [self intercepts];
    for (int i = 0; i < tempInterceptArray.count; i ++) {
        id<XXHTTPRequestManagerIntercept> tempItem = tempInterceptArray[i];
        if ([tempItem respondsToSelector:@selector(HTTPRequestManager:refuseRequest:)]) {
            if ([tempItem HTTPRequestManager:self refuseRequest:request]) {
                return NO;
            }
        }
    }
    return YES;
}

- (id<XXRequest>)_modifyRequest:(id<XXRequest>)request
{
    id<XXRequest> newRequest = request;
    NSArray * tempInterceptArray = [self intercepts];
    for (int i = 0; i < tempInterceptArray.count; i ++) {
        id<XXHTTPRequestManagerIntercept> tempItem = tempInterceptArray[i];
        if ([tempItem respondsToSelector:@selector(HTTPRequestManager:modifyRequest:)]) {
            newRequest = [tempItem HTTPRequestManager:self modifyRequest:newRequest];
        }
    }
    return newRequest;
}

- (id<XXResponse>)_modifyResponse:(id<XXResponse>)response request:(id<XXRequest>)request
{
    id<XXResponse> newResponse = response;
    NSArray * tempInterceptArray = [self intercepts];
    for (int i = 0; i < tempInterceptArray.count; i ++) {
        id<XXHTTPRequestManagerIntercept> tempItem = tempInterceptArray[i];
        if ([tempItem respondsToSelector:@selector(HTTPRequestManager:modifyResponse:request:)]) {
            newResponse = [tempItem HTTPRequestManager:self modifyResponse:newResponse request:request];
        }
    }
    return newResponse;
}

@end
