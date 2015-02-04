//
//  TabBarController.h
//  Zup
//
//  Created by Renato Kuroe on 23/11/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TabBarController : UITabBarController <UITabBarDelegate, UITabBarControllerDelegate>
{
    BOOL removedUnusedTabs;
}

@end
