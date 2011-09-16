//
//  SFSHttpConnection.m
//  OkeyiPhoneClient (http extension)
//
//  Written by Sergey Prokhorchuk | Sergey.Prohorchuk@orneon.com.
//  2009 ORNEON Ltd.
//

#import "SFSHttpConnection.h"

#define SFS_HTTP_CONNECTION_DEFAULT_PORT (8080)
#define SFS_HTTP_CONNECTION_SESSION_ID_LEN (32)

#define SFS_HTTP_SIMULTANEOUS_REQUESTS_APPROX_COUNT (2)

NSString* SFS_HTTP_POLL_REQUEST = @"poll";
static NSString* SFS_HTTP_HANDSHAKE_REQUEST = @"connect";
static NSString* SFS_HTTP_DISCONNECT_REQUEST = @"disconnect";
static NSString* SFS_HTTP_CONNECTION_LOST_RESPONSE = @"ERR#01";

static NSString* SFS_HTTP_REQUEST_PREFIX = @"sfsHttp=";
static NSString* SFS_SERVLET_PATH = @"BlueBox/HttpBox.do";

@protocol SFSHttpAsyncRequestDelegate;

@interface SFSHttpAsyncRequest : NSObject {
    NSURLConnection* _connection;
    NSMutableData* _data;
    id<SFSHttpAsyncRequestDelegate> _delegate;
}

-(id) initWithRequest:(NSURLRequest*) request delegate:(id<SFSHttpAsyncRequestDelegate>) delegate;
-(void) dealloc;

-(void) cancel;

-(BOOL) isEqual:(id) anObject;

/* NSURLConnection delegate methods */

-(void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response;
-(void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data;
-(void) connectionDidFinishLoading:(NSURLConnection*) connection;
-(void) connection:(NSURLConnection*) connection didFailWithError:(NSError*) error;

@end

@protocol SFSHttpAsyncRequestDelegate<NSObject>
-(void) asyncRequest:(SFSHttpAsyncRequest*) request dataReceived:(NSData*) data;
-(void) asyncRequest:(SFSHttpAsyncRequest*) request requestFailed:(NSString*) error;
@end

@implementation SFSHttpAsyncRequest

-(id) initWithRequest:(NSURLRequest*) request delegate:(id<SFSHttpAsyncRequestDelegate>) delegate {
    self = [super init];
    
    if (self != nil) {
        _connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];

        if (_connection != nil) {
            _data = [[NSMutableData alloc] init];
            
            if (_data != nil) {
                _delegate = delegate;
            }
            else {
                [delegate asyncRequest: self requestFailed: @"unable to allocate memory for http data"];

                [_connection cancel];
                [_connection release];
                
                _connection = nil;
            }
        }
        else {
            [delegate asyncRequest: self requestFailed: @"unable to create http request"];
        }
    }
    
    return self;
}

-(void) cancel {
    [_connection cancel];
}

-(void) dealloc {
    [_data release];
    [_connection release];
    
    [super dealloc];
}

-(BOOL) isEqual:(id) anObject {
    return anObject == self;
}

-(void) connection:(NSURLConnection*) connection didReceiveResponse:(NSURLResponse*) response {
    [_data setLength: 0];
}

-(void) connection:(NSURLConnection*) connection didReceiveData:(NSData*) data {
    [_data appendData: data];
}

-(void) connection:(NSURLConnection*) connection didFailWithError:(NSError*) error {
    [_delegate asyncRequest: self requestFailed: [error localizedDescription]];
    
    [_data release]; _data = nil;
    [_connection release]; _connection = nil;
}

-(void) connectionDidFinishLoading:(NSURLConnection*) connection {
    [_delegate asyncRequest: self dataReceived: _data];

    [_data release]; _data = nil;
    [_connection release]; _connection = nil;
}

@end

@implementation SFSHttpConnection

@synthesize delegate = _delegate;

-(id) init {
    self = [super init];

    if (self != nil) {
        connected = NO;
        activeRequests = [[NSMutableArray alloc] initWithCapacity: SFS_HTTP_SIMULTANEOUS_REQUESTS_APPROX_COUNT];
    }

    return self;
}

-(void) dealloc {
    for (id request in activeRequests) {
        [request cancel];
    }

    [activeRequests release];
    [sessionId release];
    [blueBoxUrl release];
    [super dealloc];
}

-(NSString*) getSessionId {
    return sessionId;
}

-(BOOL) isConnected {
    return connected;
}

-(void) connectToAddr:(NSString*) addr {
    [self connectToAddr: addr port: SFS_HTTP_CONNECTION_DEFAULT_PORT];
}

-(void) connectToAddr:(NSString*) addr port:(NSInteger) port {
    for (id request in activeRequests) {
        [request cancel];
    }
    
    [activeRequests removeAllObjects];

    [sessionId release];
    sessionId = nil;
    [blueBoxUrl release];
    blueBoxUrl = [[NSString alloc] initWithFormat: @"http://%@:%d/%@",addr,port,SFS_SERVLET_PATH];
    
    [self send: SFS_HTTP_HANDSHAKE_REQUEST];
}

-(void) close {
    [self send: SFS_HTTP_DISCONNECT_REQUEST];
}

static unsigned char NibbleAsHexChar (unsigned char data) {
    return (data <= 9) ? ('0' + data) : ('A' + data - 10);
}

#define SFS_HTTP_PERCENT_ESCAPE_BUF_REQUIRED_SIZE (3)

static void URLEncodeCharWithPercentSequence (void* buf, unsigned char ch) {
    ((unsigned char*)buf)[0] = '%';
    ((unsigned char*)buf)[1] = NibbleAsHexChar(ch >> 4);
    ((unsigned char*)buf)[2] = NibbleAsHexChar(ch & 0x0F);
}

static char URLEncodingSpaceEscapeChar = '+';

static NSData* GetURLEncodedData (NSString* str) {
    const unsigned char* utf8Str = (const unsigned char*)[str UTF8String];
    size_t utf8StrLen = strlen((const char*)utf8Str);
    size_t index;
    unsigned char percentEscapeBuf[SFS_HTTP_PERCENT_ESCAPE_BUF_REQUIRED_SIZE];
    
    NSMutableData* encodedData = [NSMutableData dataWithCapacity: utf8StrLen];
    
    for (index = 0; index < utf8StrLen; index++) {
        char ch = utf8Str[index];
        
        if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z') ||
            (ch >= '0' && ch <= '9') ||
            (ch == '.') || (ch == '-') || (ch == '*') || (ch == '_')) {
            [encodedData appendBytes: &ch length: sizeof(ch)];
        }
        else if (ch == ' ') {
            [encodedData appendBytes: &URLEncodingSpaceEscapeChar length: sizeof(URLEncodingSpaceEscapeChar)];
        }
        else {
            URLEncodeCharWithPercentSequence(percentEscapeBuf,ch);

            [encodedData appendBytes: percentEscapeBuf length: sizeof(percentEscapeBuf)];
        }
    }
    
    return encodedData;
}

-(void) send:(NSString*) message {
    if (connected ||
        [message compare: SFS_HTTP_HANDSHAKE_REQUEST] == NSOrderedSame ||
        [message compare: SFS_HTTP_POLL_REQUEST] == NSOrderedSame) {
        
        NSString* rawPostData;
        
        if (sessionId == nil) {
            rawPostData = [NSString stringWithString: message];
        }
        else {
            rawPostData = [NSString stringWithFormat: @"%@%@",sessionId,message];
        }

        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL: [NSURL URLWithString: blueBoxUrl]];
        [request setHTTPMethod: @"POST"];
        [request setValue: @"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData* postData = [NSMutableData data];
        [postData appendData: [SFS_HTTP_REQUEST_PREFIX dataUsingEncoding: NSUTF8StringEncoding]];
        [postData appendData: GetURLEncodedData(rawPostData)];
        
        [request setHTTPBody: postData];
/*
        NSString* debugStr = [[[NSString alloc] initWithData: requestData encoding: NSUTF8StringEncoding] autorelease];
        NSLog(@"Sending http: [%@]",debugStr);
*/        
        SFSHttpAsyncRequest* asyncRequest = [[[SFSHttpAsyncRequest alloc] initWithRequest: request delegate: self] autorelease];
        [activeRequests addObject: asyncRequest];
    }
}

-(void) asyncRequest:(SFSHttpAsyncRequest*) request dataReceived:(NSData*) data {
    [[request retain] autorelease];

    [activeRequests removeObject: request];

    if ([data length] > 0) {
        NSString* responseString = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];

//        NSLog(@"Received http: [%@]",responseString);

        if ([responseString characterAtIndex: 0] == '#') {
            if (sessionId == nil) {
                if ([responseString length] >= (SFS_HTTP_CONNECTION_SESSION_ID_LEN + 1)) {
                    sessionId = [responseString substringWithRange: NSMakeRange(1,SFS_HTTP_CONNECTION_SESSION_ID_LEN)];
                    [sessionId retain];
                    connected = YES;

                    [_delegate onHttpConnect];
                }
                else {
                    NSLog(@"SFSHttpConnection: malformed http response");
                }
            }
            else {
                NSLog(@"SFSHttpConnection: repeatable connection");
            }
        }
        else {
            NSRange range = [responseString rangeOfString: SFS_HTTP_CONNECTION_LOST_RESPONSE];

            if (range.location == 0) {
                [_delegate onHttpClose];
            }
            else {
                [_delegate onHttpData: responseString];
            }
        }

        [responseString release];
    }
}

-(void) asyncRequest:(SFSHttpAsyncRequest*) request requestFailed:(NSString*) error {
    [request retain];
    [request autorelease];
    
    [activeRequests removeObject: request];

    [_delegate onHttpError: error];
}

@end
