//
//  TIRequestOperation.m
//  TriedBy
//
//  Created by Bruno Mazzo on 11/23/12.
//  Copyright (c) 2012 #tipis mobile. All rights reserved.
//

#import "TIRequestOperation.h"
#import "TIRequestManager.h"

@implementation TIRequestOperation

-(void)CancelRequest{
    [[TIRequestManager defaultManager] cancelRequestForOperation:self];
}

-(BOOL)StartRequest:(NSURLRequest*)request{
    return [[TIRequestManager defaultManager]startRequest:request forOperation:self];
}

-(void)dealloc{
    [_target release];
    [super dealloc];
}

@end
