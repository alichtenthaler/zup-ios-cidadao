//
//  InfoWindow.m
//  Zup
//
//  Created by Renato Kuroe on 08/12/13.
//  Copyright (c) 2013 Renato Kuroe. All rights reserved.
//

#import "InfoWindow.h"

@interface InfoWindow ()

@end

@implementation InfoWindow

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.lbltitle setFont:[Utilities fontOpensSansWithSize:15]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
