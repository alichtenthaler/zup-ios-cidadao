//
//  TIRequestManager.m
//  TriedBy
//
//  Created by Bruno Mazzo on 11/23/12.
//  Copyright (c) 2012 #tipis mobile. All rights reserved.
//

#import "TIRequestManager.h"
#import "TIRequest.h"
#import "ServerOperations.h"

static NSString * const keyRequest = @"REQUEST";
static NSString * const keyOperation = @"OPERATION";

@interface TIRequestManager()

@property(atomic, retain) NSMutableArray* RequestWaiting;
@property(atomic, retain) NSMutableArray* RequestPerforming;

@end

@implementation TIRequestManager

static TIRequestManager* _defaultManager;

+(TIRequestManager*)defaultManager{
    if (_defaultManager) {
        return _defaultManager;
    }else{
        _defaultManager = [[TIRequestManager alloc]init];
        return [TIRequestManager defaultManager];
    }
}

-(id)init{
    self = [super init];
    if (self) {
        self->_RequestWaiting = [[NSMutableArray alloc]init];
        self->_RequestPerforming = [[NSMutableArray alloc]init];
    }
    
    return self;
}

-(BOOL)startRequest:(NSURLRequest*)urlRequest forOperation:(TIRequestOperation*)requestOperation{
    TIRequest* request = [[TIRequest alloc]init];
    request.delegate = self;
    if ([request startConnection:urlRequest]) {
        NSDictionary* OperationRequest = @{ keyOperation : requestOperation, keyRequest : request };
        [self.RequestPerforming addObject:OperationRequest];
        [self checkStatus];
        [request release];
        return YES;
    }else{
        if (requestOperation.target && requestOperation.actionErro) {
            [requestOperation.target performSelector:requestOperation.actionErro withObject:[NSError errorWithDomain:@"HTTP" code:1 userInfo:nil] withObject:requestOperation];
        }
    }
    [request release];
    return NO;
}

-(void)cancelRequestForOperation:(TIRequestOperation*)operation{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.%@ = %@", keyOperation, operation];
    NSArray* arrayRequest = [self.RequestPerforming filteredArrayUsingPredicate:predicate];
    
    if (arrayRequest.count > 0) {
        NSDictionary* dictionary = [arrayRequest objectAtIndex:0];
        
        TIRequest* request = [dictionary objectForKey:keyRequest];
        [request cancel];
        
        [self.RequestPerforming removeObject:dictionary];
        [self checkStatus];
        

    }
}

-(void)request:(TIRequest*)request DidFinishWithError:(NSError*)erro{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.%@ = %@", keyRequest, request];
    NSArray* arrayRequest = [self.RequestPerforming filteredArrayUsingPredicate:predicate];
    
    NSDictionary* dictionary = [arrayRequest objectAtIndex:0];
    TIRequestOperation* operation = [dictionary objectForKey:keyOperation];
    if (operation.target && operation.actionErro) {
        [operation.target performSelector:operation.actionErro withObject:erro withObject:operation];
    }
    
    [self.RequestPerforming removeObject:dictionary];
    [self checkStatus];
}

-(void)request:(TIRequest*)request DidFinishLoadingWithResult:(NSData*)result{
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"self.%@ = %@", keyRequest, request];
    NSArray* arrayRequest = [self.RequestPerforming filteredArrayUsingPredicate:predicate];
    
    NSString *stringData = [[NSString alloc]initWithData:result encoding:NSUTF8StringEncoding];
    [stringData release];
    
    NSDictionary* dictionary = [arrayRequest objectAtIndex:0];
    TIRequestOperation* operation = [dictionary objectForKey:keyOperation];
    if (operation.target && operation.action) {
        [operation.target performSelector:operation.action withObject:result withObject:operation];
    }
    
    [self.RequestPerforming removeObject:dictionary];
    [self checkStatus];
    
}


-(void)checkStatus{
    if (self.RequestPerforming.count > 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

@end
