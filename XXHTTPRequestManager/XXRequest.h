//
//  XXRequest.h
//  XXHTTPRequestManager
//
//  Created by Shawn on 2019/3/7.
//  Copyright © 2019 Shawn. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XXPostFormBodyPart,XXRequestSerializer,XXResponseSerializer;

@protocol XXRequest <NSMutableCopying>

- (NSString *)baseURL;

- (NSString *)URLString;

- (NSString *)HTTPMethod;

@optional

- (NSArray<id<XXPostFormBodyPart>> *)formBodyParts;

- (NSDictionary *)parameter;

- (NSDictionary *)headers;

@property (nonatomic, strong) id<XXRequestSerializer>requestSerializer;

@property (nonatomic, strong) id<XXResponseSerializer>responseSerializer;

@end

@protocol XXRequestSerializer <NSObject>

- (NSURLRequest *)serializerRequest:(id<XXRequest>)request;

@end

@protocol XXResponseSerializer <NSObject>

- (id)serializerResponse:(id)responseObject error:(NSError **)error request:(id<XXRequest>)request;

@end

@protocol XXPostFormBodyPart <NSObject>

- (NSString *)partName;

- (long long)partLenght;

@optional

- (NSString *)partFileName;

- (NSData *)partData;

- (NSStream *)partDataStream;

- (NSString *)partMimeType;

@end

@protocol XXRequestOperation <NSObject>

- (void)cancel;

@end
