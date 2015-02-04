//
//  TIRequest.m
//  TriedBy
//
//  Created by Bruno Mazzo on 11/23/12.
//  Copyright (c) 2012 #tipis mobile. All rights reserved.
//

#import "TIRequest.h"
#import "TIRequestManager.h"

@interface TIRequest ()

@property(nonatomic) NSInteger statusCode;

@end

@implementation TIRequest

-(BOOL)startConnection:(NSURLRequest*)request{
    
    self.currentConnection = [[[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:YES]autorelease];
    
    if (self.currentConnection) {
        self.serverResponse = [NSMutableData data];
        return YES;
    } else {
        return NO;
    }
}

-(void)cancel{
    [self.currentConnection cancel];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [self.serverResponse setLength:0];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    self.statusCode = [httpResponse statusCode];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.serverResponse appendData:data];
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    
    // receivedData is declared as a method instance elsewhere
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    if ([self.delegate respondsToSelector:@selector(request:DidFinishWithError:)]) {
        [self.delegate request:self DidFinishWithError:error];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"STATUS_CODE: %i", self.statusCode);
    if (self.statusCode == 400 || self.statusCode == 404) {
        NSError* error = [NSError errorWithDomain:@"HTTP Error" code:self.statusCode userInfo:nil];
        if ([self.delegate respondsToSelector:@selector(request:DidFinishWithError:)]) {
            [self.delegate request:self DidFinishWithError:error];
        }
        
        NSLog(@"%@ yielded an error", [connection.originalRequest.URL absoluteString]);
        
    }else if ([self.delegate respondsToSelector:@selector(request:DidFinishLoadingWithResult:)]) {
        [self.delegate request:self DidFinishLoadingWithResult:self.serverResponse];
    }
    
    // release the connection, and the data object
    [self clearMemory];
}

-(NSURLRequest *)connection:(NSURLConnection *)connection
            willSendRequest:(NSURLRequest *)request
           redirectResponse:(NSURLResponse *)redirectResponse
{
    if (redirectResponse) {
        return request;
    } else {
        return request;
    }
}

-(void)clearMemory{
    self.currentConnection = nil;
    self.serverResponse = nil;
}

+(NSString*)createUrlFrom:(NSString*)url{
    NSString* urlFormString = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                  NULL,
                                                                                  (CFStringRef)url,
                                                                                  NULL,
                                                                                  (CFStringRef)@" !*'();@&=+$,?%#[]{}<>",
                                                                                  kCFStringEncodingUTF8 );
    return [urlFormString autorelease];
}
@end
