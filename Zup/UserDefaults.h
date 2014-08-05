//
//  UserDefaults.h
//  DengueMap
//
//  Created by Renato Toshio Kuroe on 07/06/13.
//  Copyright (c) 2013 Renato Toshio Kuroe. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kSocialNetworFacebook,
    kSocialNetworTwitter,
    kSocialNetworGooglePlus,
    kSocialNetworkAnyone,
} SocialNetworkType;

@interface UserDefaults : NSObject

+(void)setIsUserLoggedOnSocialNetwork:(SocialNetworkType)type;
+(SocialNetworkType)getSocialNetworkType;

+(void)setIsUserLogged:(BOOL)isLogged;
+(BOOL)isUserLogged;

+(void)setUserId:(NSString*)userId;
+(NSString*)getUserId;

+(NSString*)getPass;
+(void)setPass:(NSString*)pass;

+(void)setFacebookImage:(UIImage*)image;
+(UIImage*)getFacebookImage;

+(void)setToken:(NSString*)token;
+(NSString*)getToken;

+(void)setDeviceToken:(NSString*)token;
+(NSString*)getDeviceToken;

+(void)setIsFromPush:(BOOL)isFromPush;
+(BOOL)isFromPush;

+(void)setFbToken:(NSString*)token;
+(NSString*)getFbToken;

+(void)setFbPublishToken:(NSString*)token;
+(NSString*)getFbPublishToken;

+(void)setReportCategories:(NSArray*)arr;
+(NSArray*)getReportCategories;
+(NSDictionary*)getCategory:(int)idCat;

+(void)setInventoryCategories:(NSArray*)arr;
+(NSArray*)getInventoryCategories;
+(NSDictionary*)getInventoryCategory:(int)idCat;
+ (NSArray*)getSectionsFroInventoryId:(int)idCat;
+ (NSString*)getTitleForFieldId:(int)idField idCat:(int)idCat;

@end
