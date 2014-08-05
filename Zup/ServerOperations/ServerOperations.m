//
//  ServerOperations.m
//  Ezzi
//
//  Created by Renato Kuroe on 01/02/13.
//  Copyright (c) 2013 Tipis. All rights reserved.
//

#import "ServerOperations.h"
#import "TIRequestOperation.h"
#import "TIRequest.h"
#import "NSData+Base64.h"

NSString * const URL = @"";
NSString * const URLgetAddress = @"http://maps.googleapis.com/maps/api/geocode/json?latlng=";
NSString * const URLauthenticate = @"http://staging.zup.sapience.io/authenticate.json";
NSString * const URLupdateUser = @"http://staging.zup.sapience.io/users/";
NSString * const URLcreate = @"http://staging.zup.sapience.io/users.json";
NSString * const URLrecoveryPass = @"http://staging.zup.sapience.io/recover_password.json";
NSString * const URLuserDetails = @"http://staging.zup.sapience.io/users/";
NSString * const URLgetPoints = @"http://staging.zup.sapience.io/reports/users/";
NSString * const URLpost = @"http://staging.zup.sapience.io/reports/";
NSString * const URLreportCategoriesList = @"http://staging.zup.sapience.io/reports/categories.json";
NSString * const URLgetAddressStreey = @"http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=";
NSString * const URLgetItems = @"http://staging.zup.sapience.io/inventory/items.json";
NSString * const URLgetReportItems = @"http://staging.zup.sapience.io/reports/items.json";
NSString * const URLgetReportItemsForInventory = @"http://staging.zup.sapience.io/reports/items.json?inventory_item_id=";
NSString * const URLgetInventoryCategories = @"http://staging.zup.sapience.io/inventory/categories.json?display_type=full";
NSString * const URLgetReportsForCategory = @"http://staging.zup.sapience.io/reports/";
NSString * const URLgetUserPosts = @"http://staging.zup.sapience.io/reports/users/";
NSString * const URLgetInventoryWithId = @"http://staging.zup.sapience.io/reports/inventory/";
NSString * const URLgetStats = @"http://staging.zup.sapience.io/reports/stats.json";

@implementation ServerOperations

// Método exemplo para os POSTs
-(BOOL)method:(NSString*)param{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URL]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* jsonData = @{ @"param" : param,
                                };
    
    [postRequest setHTTPMethod:@"POST"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getAddressWitLatitude:(float)latitude andLongitude:(float)longitude{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%f,%f&sensor=false", URLgetAddress, latitude, longitude]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    return [self StartRequest:postRequest];
}


-(BOOL)getAddressWithString:(NSString*)keyString{
    
    keyString = [keyString stringByReplacingOccurrencesOfString:@" " withString:@","];
    NSString *encodedSearchString = [keyString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", URLgetAddressStreey, encodedSearchString]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    return [self StartRequest:postRequest];
}


-(BOOL)getAddressWithString:(NSString*)keyString andGeo:(float)lat lng:(float)lng southLat:(float)latSouth southLng:(float)lngSouth{
    
    keyString = [keyString stringByReplacingOccurrencesOfString:@" " withString:@","];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?sensor=false&address=%@&bounds=%f,%f|%f,%f", keyString, latSouth, lngSouth, lat, lng];

    NSString *encodedSearchString = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    NSURL *url = [NSURL URLWithString:encodedSearchString];
    
//    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@&latlng=%f,%f&sensor=true&components=country:BR", URLgetAddressStreey, encodedSearchString, lat, lng]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    return [self StartRequest:postRequest];
}

-(BOOL)authenticate:(NSString*)email pass:(NSString*)pass{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URLauthenticate]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* jsonData = @{ @"email" : email,
                                @"password" : pass
                                };
    
    [postRequest setHTTPMethod:@"POST"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)createUser:(NSString*)email
             pass:(NSString*)pass
             name:(NSString*)name
            phone:(NSString*)phone
         document:(NSString*)document
          address:(NSString*)address
addressAdditional:(NSString*)addressAdditional
       postalCode:(NSString*)postalCode
         district:(NSString*)district{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URLcreate]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    document = [document stringByReplacingOccurrencesOfString:@"." withString:@""];
    document = [document stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSDictionary* jsonData = @{ @"email" : email,
                                @"password" : pass,
                                @"password_confirmation" : pass,
                                @"name" : name,
                                @"phone" : phone,
                                @"document" : document,
                                @"address" : address,
                                @"address_additional" : addressAdditional,
                                @"postal_code" : postalCode,
                                @"district" : district,
                                @"device_token" : [UserDefaults getDeviceToken],
                                @"device_type" : @"ios"
                                };
    
    [postRequest setHTTPMethod:@"POST"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)updateUser:(NSString*)email
             pass:(NSString*)pass
             name:(NSString*)name
            phone:(NSString*)phone
         document:(NSString*)document
          address:(NSString*)address
addressAdditional:(NSString*)addressAdditional
       postalCode:(NSString*)postalCode
         district:(NSString*)district{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", URLupdateUser, [UserDefaults getUserId]]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    document = [document stringByReplacingOccurrencesOfString:@"." withString:@""];
    document = [document stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSDictionary* jsonData = @{
                               @"id" : [UserDefaults getUserId],
                               @"token" : [UserDefaults getToken],
                                @"email" : email,
                                @"password" : pass,
                                @"password_confirmation" : pass,
                                @"name" : name,
                                @"phone" : phone,
                                @"document" : document,
                                @"address" : address,
                                @"address_additional" : addressAdditional,
                                @"postal_code" : postalCode,
                                @"district" : district
                                };
    
    [postRequest setHTTPMethod:@"PUT"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)recoveryPass:(NSString*)pass{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URLrecoveryPass]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSDictionary* jsonData = @{ @"email" : pass
                                };
    
    [postRequest setHTTPMethod:@"PUT"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getDetails{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json", URLuserDetails, [UserDefaults getUserId]]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getItems{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URLgetItems]];
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getItemsForPosition:(float)latitude longitude:(float)longitude radius:(double)radius zoom:(float) zoom{
    
    int maxCount = 0;
    if ([Utilities isIpad] || [Utilities isIphone4inch]) maxCount = maxMarkersCountiPhone5iPad;
    else maxCount = maxMarkersCountiPhone4;
    
#warning Raio esta estranho
    radius = radius;

    NSString *strUrl = [NSString stringWithFormat:@"%@?position[latitude]=%f&position[longitude]=%f&position[distance]=%f&limit=%i&zoom=%f", URLgetItems, latitude, longitude, radius, maxCount, zoom];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getItemsForPosition:(float)latitude longitude:(float)longitude radius:(double)radius zoom:(float) zoom categoryId:(NSString*)catId{
    
    int maxCount = 0;
    if ([Utilities isIpad] || [Utilities isIphone4inch]) maxCount = maxMarkersCountiPhone5iPad;
    else maxCount = maxMarkersCountiPhone4;
    
//    NSString *strUrl = @"http://staging.zup.sapience.io/inventory/items.json?limit=30&position%5Bdistance%5D=518.0249592829191&position%5Blatitude%5D=-23.5481173&position%5Blongitude%5D=-46.63609300000002&zoom=17";
    
    NSString *strUrl = [NSString stringWithFormat:@"http://staging.zup.sapience.io/inventory/items.json?limit=%i&position[distance]=%f&position[latitude]=%f&position[longitude]=%f&zoom=%f", maxCount,radius, latitude, longitude, zoom];
    
//    NSString *strUrl = [NSString stringWithFormat:@"%@?position[latitude]=%f&position[longitude]=%f&position[distance]=%f&limit=%i&zoom=%f&inventory_category_id=%@", URLgetItems, latitude, longitude, radius, maxCount, zoom, catId];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getReportItemsForPosition:(float)latitude longitude:(float)longitude radius:(double)radius zoom:(float) zoom{
    
    int maxCount = 0;
    if ([Utilities isIpad] || [Utilities isIphone4inch]) maxCount = maxMarkersCountiPhone5iPad;
    else maxCount = maxMarkersCountiPhone4;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@?position[latitude]=%f&position[longitude]=%f&position[distance]=%f&position[max_items]=%i&zoom=%f", URLgetReportItems, latitude, longitude, radius, maxCount, zoom];

    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getReportItemsForInventory:(NSString*)inventId{
    
    int maxCount = 0;
    if ([Utilities isIpad] || [Utilities isIphone4inch]) maxCount = maxMarkersCountiPhone5iPad;
    else maxCount = maxMarkersCountiPhone4;
    
    NSString *strUrl = [NSString stringWithFormat:@"%@%@", URLgetReportItemsForInventory, inventId];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getInventoryCategories{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", URLgetInventoryCategories]];    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getReportCategories{
    NSURL* url = [NSURL URLWithString:URLreportCategoriesList];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getReportsForIdCategory:(int)idCategory{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/items.json", URLgetReportsForCategory, [NSNumber numberWithInt:idCategory]]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getInventoryForIdCategory:(int)idCategory{
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/items.json", URLgetInventoryWithId, [NSNumber numberWithInt:idCategory]]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)post:(NSString*)latitude
  longitude:(NSString*)longitude
inventory_item_id:(NSString*)inventory_item_id
description:(NSString*)description
    address:(NSString*)address
     images:(NSArray*)images
categoryId:(NSString*)catId
  reference:(NSString*)reference{
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/items.json", URLpost, catId]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (UIImage *img in images) {
        NSData *dataImage = UIImageJPEGRepresentation(img, 0.5);
        NSString *strBase64 = [dataImage base64EncodedStringWithOptions:0];
        [arr addObject:strBase64];
    }
    
    NSDictionary* jsonData;
    if (inventory_item_id.length > 0) {
        jsonData= @{
                                    @"category_id" : catId,
                                    @"inventory_item_id" : inventory_item_id,
                                    @"description" : description,
                                    @"reference" : reference,
                                    @"images" : [NSArray arrayWithArray:arr],
                                    @"token" : [UserDefaults getToken],
                                    @"id" : [UserDefaults getUserId],
                                    };

    } else {
        jsonData = @{ 
                                    @"longitude" : longitude,
                                    @"latitude" : latitude,
                                    @"category_id" : catId,
                                    @"description" : description,
                                    @"reference" : reference,
                                    @"address" : address,
                                    @"images" : [NSArray arrayWithArray:arr],
                                    @"token" : [UserDefaults getToken],
                                    @"id" : [UserDefaults getUserId],
                                    };

    }
    
    
    [postRequest setHTTPMethod:@"POST"];
    
    NSError *error;
    
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:&error];
    
    
    [postRequest setHTTPBody:postdata];
    [postRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[postdata length]] forHTTPHeaderField:@"Content-Length"];
    [postRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return [self StartRequest:postRequest];

}

-(BOOL)getUserPostsWithPage:(int)page{
    
    int pageNum = 0;
    if ([Utilities isIpad]) {
        pageNum = 20;
    } else {
        pageNum = 10;
    }
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/items.json?per_page=%i&page=%i", URLgetUserPosts, [UserDefaults getUserId], pageNum, page]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}


-(BOOL)getReportDetailsWithId:(NSString*)idCategory {
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://staging.zup.sapience.io/reports/items/%@.json", idCategory]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}

-(BOOL)getInventoryDetailsWithId:(NSString*)idCategory idItem:(NSString*)idItem {
    
    NSString *token = [UserDefaults getToken];
    
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"http://staging.zup.sapience.io/inventory/categories/%@/items/%@.json?token=%@", idCategory, idItem, token]];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}


-(BOOL)getStats {
    
    NSURL* url = [NSURL URLWithString:URLgetStats];
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}


-(BOOL)getStatsWithFilter:(int)days categoryId:(int)categoryId{
    
    NSDate *today = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strToday = [formatter stringFromDate:today];
    
    NSString *earlierStr = [Utilities getDateStringFromDaysPassed:days];
    
    NSURL* url = nil;
    
    if (categoryId == 0) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?begin_date=%@&end_date=%@", URLgetStats, earlierStr, strToday]];
    } else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?category_id=%i&begin_date=%@&end_date=%@", URLgetStats, categoryId ,earlierStr, strToday]];
    }
    
    NSMutableURLRequest* postRequest = [NSMutableURLRequest requestWithURL:url];
    
    [postRequest setHTTPMethod:@"GET"];
    
    return [self StartRequest:postRequest];
}



@end
