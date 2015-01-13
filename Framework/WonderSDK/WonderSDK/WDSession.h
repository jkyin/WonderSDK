//
//  WDSession.h
//  WonderSDK
//
//  Created by Wonder on 14/12/22.
//  Copyright (c) 2014年 Yin Xiaoyu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDSession;

typedef void(^WDSessionCompleteHandler)(WDSession *session, NSError *error);

@interface WDSession : NSObject

@property (nonatomic, copy) NSString *token;

/*!
 @methodgroup Instance methods
 */

/*!
 @method
 
 @abstract Opens a session for the Facebook.
 
 @discussion
 A session may not be used with <FBRequest> and other classes in the SDK until it is open. If, prior
 to calling open, the session is in the <FBSessionStateCreatedTokenLoaded> state, then no UX occurs, and
 the session becomes available for use. If the session is in the <FBSessionStateCreated> state, prior
 to calling open, then a call to open causes login UX to occur, either via the Facebook application
 or via mobile Safari.
 
 Open may be called at most once and must be called after the `FBSession` is initialized. Open must
 be called before the session is closed. Calling an open method at an invalid time will result in
 an exception. The open session methods may be passed a block that will be called back when the session
 state changes. The block will be released when the session is closed.
 
 @param handler A block to call with the state changes. The default is nil.
 */
- (void)openWithCompletionHandler:(WDSessionCompleteHandler)handler;

@end
