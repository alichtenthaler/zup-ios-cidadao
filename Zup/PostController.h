//
//  PostController.h
//  zup
//
//  Created by Renato Kuroe on 01/05/14.
//  Copyright (c) 2014 ntxdev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <Accounts/Accounts.h>
#import <GooglePlus/GooglePlus.h>
#import "TWAPIManager.h"

@class GPPSignInButton;

@interface PostController : NSObject <GPPSignInDelegate>

+ (void)postMessageWithFacebook:(NSString*)message link:(NSString*)link linkTitle:(NSString*)linkTitle linkDesc:(NSString*)linkDesc image:(NSString*)image;
- (void)postMessageWithGoogle:(NSString*)message;

@end
