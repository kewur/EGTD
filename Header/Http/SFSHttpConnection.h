//
//  SFSHttpConnection.h
//  OkeyiPhoneClient (http extension)
//
//  Written by Sergey Prokhorchuk | Sergey.Prohorchuk@orneon.com.
//  2009 ORNEON Ltd.
//

#import <Foundation/Foundation.h>

extern NSString* SFS_HTTP_POLL_REQUEST;

@protocol SFSHttpConnectionDelegate<NSObject>
-(void) onHttpConnect;
-(void) onHttpClose;
-(void) onHttpError:(NSString*) error;
-(void) onHttpData:(NSString*) params;
@end

@interface SFSHttpConnection : NSObject {
    @private

    BOOL connected;
    NSString* sessionId;
    NSString* blueBoxUrl;
    
    NSMutableArray* activeRequests;
    
    id<SFSHttpConnectionDelegate> _delegate;
}

@property (nonatomic,assign) id<SFSHttpConnectionDelegate> delegate;

-(id) init;
-(NSString*) getSessionId;
-(BOOL) isConnected;
-(void) connectToAddr:(NSString*) addr;
-(void) connectToAddr:(NSString*) addr port:(NSInteger) port;
-(void) close;
-(void) send:(NSString*) message;

@end
