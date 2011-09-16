//
//  INFSmartFoxiPhoneClient.mm
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxiPhoneClient.h"
#import "INFSmartFoxIMessageHandler.h"
#import "INFSmartFoxSysHandler.h"
#import "INFSmartFoxExtHandler.h"
#import "INFSmartFoxBuddy.h"
#import "INFSmartFoxUser.h"
#import "INFSmartFoxRoom.h"
#import "INFSmartFoxRoomVariable.h"
#import "INFSmartFoxEntities.h"
#import "INFSmartFoxRoomCreateParams.h"
#import "INFSmartFoxSFSEvent.h"
#import "INFSmartFoxObjectSerializer.h"
#import "TouchXML.h"
#import "JSON.h"

@implementation INFSmartFoxiPhoneClient

@dynamic rawProtocolSeparator;

- (NSString *)rawProtocolSeparator {
    return _MSG_STR;	
}

- (void)setrawProtocolSeparator:(NSString *)value {
	if ([value isEqualToString:@"<"] && [value isEqualToString:@"{"]) {
		[_MSG_STR release];
		_MSG_STR = [value copy];
	}
}

@synthesize defaultZone = _defaultZone;
@synthesize isConnected = _connected;
@synthesize delegate = _delegate;
@synthesize amIModerator = _amIModerator;
@synthesize myUserId = _myUserId;
@synthesize playerId = _playerId;
@synthesize myUserName = _myUserName;
@synthesize activeRoomId = _activeRoomId;
@synthesize changingRoom = _changingRoom;
@synthesize mach_timebase_info_data = _mach_timebase_info_data;
@synthesize myBuddyVars = _myBuddyVars;
@synthesize buddyList = _buddyList;

@synthesize INFSMARTFOXCLIENT_EOM;
@synthesize INFSMARTFOXCLIENT_MSG_XML;
@synthesize INFSMARTFOXCLIENT_MSG_JSON;
@synthesize INFSMARTFOXCLIENT_MODMSG_TO_USER;
@synthesize INFSMARTFOXCLIENT_MODMSG_TO_ROOM;
@synthesize INFSMARTFOXCLIENT_MODMSG_TO_ZONE;
@synthesize INFSMARTFOXCLIENT_XTMSG_TYPE_XML;
@synthesize INFSMARTFOXCLIENT_XTMSG_TYPE_STR;
@synthesize INFSMARTFOXCLIENT_XTMSG_TYPE_JSON;
@synthesize INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED;
@synthesize INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET;
@synthesize INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP;

@dynamic httpPollSpeed;

- (NSInteger)httpPollSpeed
{
	return _httpPollSpeed;
}

- (void)sethttpPollSpeed:(NSInteger)sp
{
	// Acceptable values: 0 <= sp <= 10sec
	if (sp >= 0 && sp <= 10000)
		_httpPollSpeed = sp;
}

/*
 *
 * Private functions
 *
*/
- (void)initialize:(BOOL)isLogOut
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:initialize isLogOut:%d", isLogOut]];
	
	// Clear local properties
	_changingRoom = NO;
	_amIModerator = NO;
	_playerId = -1;
	_activeRoomId = -1;
	_myUserId = -1;
	_myUserName = @"";
	
	// Clear data structures
	[_roomList removeAllObjects];
	[_buddyList removeAllObjects];
	[_myBuddyVars removeAllObjects];
	
	// Set connection status
	if (!isLogOut)
	{
		_connected = NO;
		_isHttpMode = NO;
	}
}

- (void)addMessageHandler:(NSString *)key handler:(id <INFSmartFoxIMessageHandler>)handler
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:addMessageHandler key:%@ handler:%@", key, [handler class]]];
	
	if (![_messageHandlers objectForKey:key]) {
	 	[_messageHandlers setObject:handler forKey:key]; 
	}
	else {
	 	[self debugMessage:[NSString stringWithFormat:@"Warning, message handler called: %@ already exist!", key]];
	}
}

- (void)setupMessageHandlers
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:setupMessageHandlers"]];
	
	[self addMessageHandler:@"sys" handler:[INFSmartFoxSysHandler sysHandler:self]];
	[self addMessageHandler:@"xt" handler:[INFSmartFoxExtHandler extHandler:self]];
}

- (void)writeToSocket:(NSString *)data
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:writeToSocket data:%@ len:%ld", data, [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1]];
	
	[_sendLock lock];
	
	if (_noDataSent == YES) {	
		NSInteger len;
		len = [_outStream write:(const uint8_t *)[data cStringUsingEncoding:NSUTF8StringEncoding] maxLength:[data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1];
		_noDataSent = NO;
		
		[self debugMessage:[NSString stringWithFormat:@"WRITE - Written directly to outStream len:%ld", len]];
		
		if (len < [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1) {
			[self debugMessage:[NSString stringWithFormat:@"WRITE - Creating a new buffer for remaining data len:%ld", ([data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1) - len]];
			
			_lastSendBuffer = [INFSendBuffer dataWithNSData:[NSData dataWithBytes:(const uint8_t *)[data cStringUsingEncoding:NSUTF8StringEncoding] + len length:([data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1) - len]];
			[_sendBuffers addObject:_lastSendBuffer];
		}

		[_sendLock unlock];
		return;
	}
	
	if (_lastSendBuffer) {	
		NSInteger lastSendBufferLength;
		NSInteger newDataLength;
		
		lastSendBufferLength = [_lastSendBuffer length];
		newDataLength = [data lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		
		if (lastSendBufferLength < 1024) {
			[self debugMessage:[NSString stringWithFormat:@"WRITE - Have a buffer with enough space, appending data to it"]];
			
			[_lastSendBuffer appendBytes:[data cStringUsingEncoding:NSUTF8StringEncoding] length:newDataLength + 1];
			
			[_sendLock unlock];
			return;
		}
	}	
	
	[self debugMessage:[NSString stringWithFormat:@"WRITE - Creating a new buffer"]];
	
	_lastSendBuffer = [INFSendBuffer dataWithNSData:[NSData dataWithBytes:[data cStringUsingEncoding:NSUTF8StringEncoding] length:[data lengthOfBytesUsingEncoding:NSUTF8StringEncoding] + 1]];
	[_sendBuffers addObject:_lastSendBuffer];
	
	[_sendLock unlock];
}

- (NSString *)makeXmlHeader:(NSDictionary *)headerObj
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:makeXmlHeader"]];
	
	NSString *xmlData = @"<msg";
	 
	NSEnumerator *enumerator = [headerObj keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		xmlData = [xmlData stringByAppendingFormat:@" %@='%@'", key, [headerObj objectForKey:key]];
	}
	 
	xmlData = [xmlData stringByAppendingString:@">"];
	 
	return xmlData;
}

- (NSString *)closeHeader
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:closeHeader"]];
	
	return @"</msg>";
}


- (NSString *)getXmlRoomVariable:(INFSmartFoxRoomVariable *)rVar
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getXmlRoomVariable rVar:%@", rVar]];
	
	NSString *vPrivate = (rVar.priv) ? @"1" : @"0";
	NSString *vPersistent = (rVar.persistent) ? @"1" : @"0";
	NSString *t;
	NSString *val;
	
	t = nil;
	
	// Check types	
	if ([[rVar.value className] isEqualToString:@"NSCFBoolean"]) {
		t = @"b";
		val = [rVar.value stringValue];
	}
	else if ([[rVar.value className] isEqualToString:@"NSCFNumber"]) {
		t = @"n";
		val = [rVar.value stringValue];
	}		
	else if ([rVar.value isKindOfClass:[NSString class]] || [[rVar.value className] isEqualToString:@"NSCFString"]) {	
		t = @"s";
		val = rVar.value;
	}
	
	/*
	 * !!Warning!!
	 * Dynamic typed vars (*) when set to null:
	 * 	type = object, val = "null". 
	 * 	Also they can use undefined type.
	 *
	 * Static typed vars when set to null:
	 * 	type = null, val = "null"
	 * 	undefined = null 
	 */
	else if (rVar.value == nil || rVar.name == nil)	{
		t = @"x";
		val = @"";
	}
	
	if (t) {
		return [NSString stringWithFormat:@"<var n='%@' t='%@' pr='%@' pe='%@'><![CDATA[%@]]></var>", rVar.name, t, vPrivate, vPersistent, val];
	}
	else {
		return @"";
	}
}

- (NSString *)getXmlUserVariable:(NSDictionary *)uVars
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getXmlUserVariable uVars:%@", uVars]];
	
	NSString *xmlStr = [NSString stringWithString:@"<vars>"];
	NSString *t;
	NSString *val;
	
	NSEnumerator *enumerator = [uVars keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		t = nil;
		
		// Check types
		if ([[[uVars objectForKey:key] className] isEqualToString:@"NSCFBoolean"]) {
			t = @"b";
			val = [[uVars objectForKey:key] stringValue];
		}
		else if ([[[uVars objectForKey:key] className] isEqualToString:@"NSCFNumber"]) {
			t = @"n";
			val = [[uVars objectForKey:key] stringValue];
		}		
		else if ([[uVars objectForKey:key] isKindOfClass:[NSString class]] || [[uVars className] isEqualToString:@"NSCFString"]) {
			t = @"s";
			val = [uVars objectForKey:key];
		}
		
		/*
		 * !!Warning!!
		 * Dynamic typed vars (*) when set to null:
		 * 	type = object, val = "null". 
		 * 	Also they can use undefined type.
		 *
		 * Static typed vars when set to null:
		 * 	type = null, val = "null"
		 * 	undefined = null 
		 */
		else if ([[uVars objectForKey:key] isKindOfClass:[NSNull class]] || [key isKindOfClass:[NSNull class]])	{
			t = @"x";
			val = @"";
		}
		
		if (t) {
			xmlStr = [xmlStr stringByAppendingString:[NSString stringWithFormat:@"<var n='%@' t='%@'><![CDATA[%@]]></var>", key, t, val]];
		}			
	}
	
	xmlStr = [xmlStr stringByAppendingString:@"</vars>"];
	
	return xmlStr;
}

-(BOOL)checkBuddyDuplicates:(NSString *)buddyName
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:checkBuddyDuplicates buddyName:%@", buddyName]];
	
	// Check for buddy duplicates in the current buddy list
	NSEnumerator *enumerator = [_buddyList objectEnumerator];
	INFSmartFoxBuddy *value;
	
	while ((value = [enumerator nextObject])) {
		if ([value.name isEqualToString:buddyName]) {
			return true;
		}
	}
	
	return false;
}

- (void)strReceived:(NSString *)msg
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:strReceived"]];
	
	// Got String response
	NSArray *params = [[msg substringWithRange:NSMakeRange(1, [msg length] - 2)] componentsSeparatedByString:_MSG_STR];
		
	NSString *handlerId = [params objectAtIndex:0];
	id<INFSmartFoxIMessageHandler> handler = [_messageHandlers objectForKey:handlerId];
	
	if (handler != nil) {
		[handler handleMessage:[params subarrayWithRange:NSMakeRange(1, [params count] - 1)] type:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_STR delegate:_delegate];
	}
	else {
		[self debugMessage:[NSString stringWithFormat:@"No handlers found for type:%@", handlerId]];
	}
}


- (void)xmlReceived:(NSString *)msg
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:xmlReceived"]];
	
	// Got XML response		
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:msg options:0 error:&error];
	NSArray *nodes = [doc nodesForXPath:@"./msg/@t" error:&error];
	
	if ([nodes count] > 0) {
		CXMLElement *handlerId = [nodes objectAtIndex:0];
		
		id<INFSmartFoxIMessageHandler> handler = [_messageHandlers objectForKey:[handlerId stringValue]];
		
		if (handler != nil) {
			[handler handleMessage:msg type:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_XML delegate:_delegate];
		}
		else {
			[self debugMessage:[NSString stringWithFormat:@"No handler found for type:%@", [handlerId stringValue]]];
		}
	}
	
	[doc release];		
}

- (void)jsonReceived:(NSString *)msg
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:jsonReceived"]];
	
	NSDictionary *jsonObject = [msg JSONValue];
	
	id<INFSmartFoxIMessageHandler> handler = [_messageHandlers objectForKey:[jsonObject objectForKey:@"t"]];
	
	if (handler != nil) {
		[handler handleMessage:[jsonObject objectForKey:@"b"] type:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_JSON delegate:_delegate];
	}
	else {
		[self debugMessage:[NSString stringWithFormat:@"No handler found for type:%@", [jsonObject objectForKey:@"t"]]];
	}	
}

- (void)handleMessage:(NSString *)msg
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:handleMessage"]];
	
	if ([msg isEqualToString:@"ok"])
	 	[self debugMessage:[NSString stringWithFormat:@"[ RECEIVED ]: %@, (len: %ld)", msg, [msg length]]];
		
	NSString *type = [msg substringWithRange:NSMakeRange(0, 1)];
	
	if ([type isEqualToString:(NSString *)INFSMARTFOXCLIENT_MSG_XML]) {
		[self xmlReceived:msg];
	}else if ([type isEqualToString:_MSG_STR]) {
		[self strReceived:msg];
	}else if ([type isEqualToString:(NSString *)INFSMARTFOXCLIENT_MSG_JSON]) {
		[self jsonReceived:msg];
	}	
}

- (void)send:(NSDictionary *)header action:(NSString *)action fromRoom:(NSInteger)fromRoom message:(NSString *)message
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:send action:%@ fromRoom:%ld message:%@", action, fromRoom, message]];
	
	// Setup Msg Header
	NSString *xmlMsg = [self makeXmlHeader:header];
	
	// Setup Body
	xmlMsg = [xmlMsg stringByAppendingFormat:@"<body action='%@' r='%ld'>%@</body>%@", action, fromRoom, message, [self closeHeader]];
		
	if (_isHttpMode) {
		[httpConnection send:xmlMsg];
	}
	else {
		[self writeToSocket:xmlMsg];
	};
}

- (void)handleSocketConnection
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:handleSocketConnection"]];
	
	NSString *xmlMsg;
	
	xmlMsg = [NSString stringWithFormat:@"<ver v='%ld%ld%ld' />", _majVersion, _minVersion, _subVersion];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"verChk" fromRoom:0 message:xmlMsg];
}


- (void)handleSocketDisconnection
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:handleSocketDisconnection"]];
	
	if (_isHttpMode) {
	    [NSObject cancelPreviousPerformRequestsWithTarget: self selector: @selector(handleDelayedPoll) object: nil];
	}
	
	[self initialize:NO];
	
	if ([_delegate respondsToSelector:@selector(onConnectionLost:)]) {			
		[_delegate onConnectionLost:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];
	}
}

- (void)tryBlueBoxConnection
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:tryBlueBoxConnection"]];
	
	if (!_connected) {
		if (_smartConnect) {
			[self debugMessage:[NSString stringWithFormat:@"Socket connection failed. Trying BlueBox"]];
            
            [self releaseSocketConnectionResources];
			
			_isHttpMode = true;						

            NSString* addr = _blueBoxIpAddress != nil ? _blueBoxIpAddress : _ipAddress;
            NSInteger port = _blueBoxPort != 0 ? _blueBoxPort : _port;
            
            [httpConnection connectToAddr: addr port: port];
		}
		else {
			if ([_delegate respondsToSelector:@selector(onConnection:)]) {			
				[_delegate onConnection:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"success", @"I/O Error", @"error", nil]]];
			}			
		}
	}
	else {
		if ([_delegate respondsToSelector:@selector(onIOError:)]) {			
			[_delegate onIOError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];
		}			
	}
}

-(void) onHttpConnect {
    [self handleSocketConnection];
    [httpConnection send: SFS_HTTP_POLL_REQUEST];
}

-(void) onHttpClose {
    [self handleSocketDisconnection];
}

-(void) onHttpError:(NSString*) error {
    if (!_connected) {
        if ([_delegate respondsToSelector:@selector(onConnection:)]) {			
            [_delegate onConnection:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:false], @"success", @"I/O Error", @"error", nil]]];
        }
    }
	else {
		if ([_delegate respondsToSelector:@selector(onIOError:)]) {			
			[_delegate onIOError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];
		}			
	}
}

-(void) onHttpData:(NSString*) params {
    NSArray* messages = [params componentsSeparatedByString: @"\n"];
    NSUInteger index;
    NSUInteger count = [messages count];

    if (count > 0) {
        if ([[messages objectAtIndex: 0] length] > 0) {
            for (index = 0; index < count - 1; index++) {
                NSString* message = [messages objectAtIndex: index];
                
                if ([message length] > 0) {
                    [self handleMessage: message];
                }
            }
            
            [self performSelector: @selector(handleDelayedPoll) withObject: nil afterDelay: (double)_httpPollSpeed / 1000.0 ];
        }
    }
}

-(void) handleDelayedPoll {
    [httpConnection send: SFS_HTTP_POLL_REQUEST];
}

- (void)handleIOError
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:handleIOError"]];

    [self tryBlueBoxConnection];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
//	NSString *streamType = (stream == _inStream) ? @"read" : @"write";
	
//    NSLog(@"SmartFoxiPhoneClient:stream:handleEvent Stream type: %@", streamType);
	
    switch(eventCode) {
	case NSStreamEventNone:
			NSLog(@"Event type: EventNone");
			break;
		case NSStreamEventOpenCompleted:
			NSLog(@"Event type: EventOpenCompleted");
			
			if (stream == _outStream) {
				[self handleSocketConnection];
			}
			break;
		case NSStreamEventHasSpaceAvailable:
			NSLog(@"Event type: EventHasSpaceAvailable");
			
			[_sendLock lock];
			
			if (![_sendBuffers count]) {
				NSLog(@"WRITE - No data to send");
				_noDataSent = YES;
				
				[_sendLock unlock];				
				break;
			}
			
			INFSendBuffer *sendBuffer = [_sendBuffers objectAtIndex:0];
			
			NSInteger sendBufferLength = [sendBuffer length];
			
			if (!sendBufferLength) {
				if (sendBuffer == _lastSendBuffer) {
					_lastSendBuffer = nil;
				}
				
				[_sendBuffers removeObjectAtIndex:0];
				
				NSLog(@"WRITE - No data to send");
				
				_noDataSent = YES;
				
				[_sendLock unlock];
				break;
			}
			
			NSInteger len = ((sendBufferLength - [sendBuffer sendPos] >= 1024) ? 1024 : (sendBufferLength - [sendBuffer sendPos]));
			if (!len) {
				if (sendBuffer == _lastSendBuffer) {
					_lastSendBuffer = nil;
				}
				
				[_sendBuffers removeObjectAtIndex:0];
				
				NSLog(@"WRITE - No data to send");
				
				_noDataSent = YES;
				
				[_sendLock unlock];
				break;
			}
			
//			NSLog(@"write %ld bytes", len);
			len = [_outStream write:((const uint8_t *)[sendBuffer mutableBytes] + [sendBuffer sendPos]) maxLength:len];
			[self debugMessage:[NSString stringWithFormat:@"WRITE - Written directly to outStream len:%ld", len]];
			
			[sendBuffer consumeData:len];
			
			if (![sendBuffer length]) {
				if (sendBuffer == _lastSendBuffer) {
					_lastSendBuffer = nil;
				}
				
				[_sendBuffers removeObjectAtIndex:0];
			}
			
			_noDataSent = NO;
			
			[_sendLock unlock];
			break;
		case NSStreamEventErrorOccurred:
			NSLog(@"Event type: EventErrorOccured");
			
			[self handleIOError];			
			break;
		case NSStreamEventEndEncountered:
			NSLog(@"Event type: EventEndOccured");
			
			[self handleSocketDisconnection];			
			break;
        case NSStreamEventHasBytesAvailable:
        {			
			NSLog(@"Event type: EventHasBytesAvailable");
			
            uint8_t buf[1024];
            NSInteger len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
			[self debugMessage:[NSString stringWithFormat:@"Read directly from inStream len:%ld", len]];
			
			/*if (len < 0) {
			    [self handleSocketDisconnection];
				break;
			} */			
			
            if (len > 0) {
				int start = 0, i;
				for (i = 0; i < len; i++) {
					if (buf[i] == 0) {
						[_receiveLock lock];
						[_receiveBuffer appendBytes:(const void *)(buf + start) length:(i - start) + 1];
						
						if ([_receiveBuffer length] > 0) {
							NSString *msgStr = [NSString stringWithCString:(const char *)[_receiveBuffer bytes] encoding:NSUTF8StringEncoding];
							[_receiveBuffer setLength:0];
							
							[self handleMessage:msgStr];
						}
						
						start = i + 1;
						[_receiveLock unlock];
					}
				}
				
				if (start < i) {
					[_receiveLock lock];
					[_receiveBuffer appendBytes:(const void *)(buf + start) length:(i - start)];
					[_receiveLock unlock];
				}								
            }
			else {
                NSLog(@"No buffer!");
            }
			
            break;
        }
	}
}
/*
 *
 * End of Private functions
 *
 */

/*
 *
 * Public functions
 *
 */

+ (id)iPhoneClient:(BOOL)debug delegate:(id <INFSmartFoxISFSEvents>)delegate
{
	INFSmartFoxiPhoneClient *obj = [INFSmartFoxiPhoneClient alloc];
	return [[obj initWithParams:debug delegate:delegate] autorelease];
}

- (id)initWithParams:(BOOL)debug delegate:(id <INFSmartFoxISFSEvents>)delegate
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:initWithParams debug:%d delegate:%@", debug, delegate]];
	
	self = [super init];
	if (self) {
		NSLog(@"SmartFoxiPhoneClient:init");

		_delegate = delegate;
		
		mach_timebase_info(&_mach_timebase_info_data);

		// -------------------------------------------------------
		// Constants
		// -------------------------------------------------------
		
		INFSMARTFOXCLIENT_EOM = 0x00;
		INFSMARTFOXCLIENT_MSG_XML = @"<";
		INFSMARTFOXCLIENT_MSG_JSON = @"{";
		INFSMARTFOXCLIENT_MODMSG_TO_USER = @"u";
		INFSMARTFOXCLIENT_MODMSG_TO_ROOM = @"r";
		INFSMARTFOXCLIENT_MODMSG_TO_ZONE = @"z";
		INFSMARTFOXCLIENT_XTMSG_TYPE_XML = @"xml";
		INFSMARTFOXCLIENT_XTMSG_TYPE_STR = @"str";
		INFSMARTFOXCLIENT_XTMSG_TYPE_JSON = @"json";
		INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED = @"disconnected";
		INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET = @"socket";
		INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP = @"http";
		
		_MSG_STR  = @"%";
		
		_MIN_POLL_SPEED = 0;
		_DEFAULT_POLL_SPEED = 750;
		_MAX_POLL_SPEED = 10000;
		_HTTP_POLL_REQUEST = @"poll";
		
		_autoConnectOnConfigSuccess = false;
		_port = 9339;
		_isHttpMode = false;
		_httpPollSpeed = _DEFAULT_POLL_SPEED;
		_blueBoxPort = 0;	
		_smartConnect = true;
		_httpPort = 8080;
		
		// Initialize properties 
		_majVersion = 1;
		_minVersion = 5;
		_subVersion = 4;
		
		_activeRoomId = -1;
		_debug = debug;
		
		_roomList = [[NSMutableDictionary dictionary] retain];
		_buddyList = [[NSMutableDictionary dictionary] retain];
		_myBuddyVars = [[NSMutableDictionary dictionary] retain];
		
		_messageHandlers = [[NSMutableDictionary dictionary] retain];
		[self setupMessageHandlers];
		
		httpConnection = [[SFSHttpConnection alloc] init];
		httpConnection.delegate = self;		
	}
	
	return self;
}

- (void)setRoomList:(NSMutableDictionary *)newRoomList
{
	[_roomList release];
	_roomList = [newRoomList retain];
}

- (void)debugMessage:(NSString *)message
{
	if (_debug)	{
		NSLog(@"%@", message);
		
		if ([_delegate respondsToSelector:@selector(onDebugMessage:)]) {			
			[_delegate onDebugMessage:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:message, @"message", nil]]];
		}
	}
}

- (void)loadConfig:(NSString *)configFile autoConnect:(BOOL)autoConnect
{
	[self debugMessage:@"INFSmartFoxiPhoneClient::loadConfig"];
	
	_autoConnectOnConfigSuccess = autoConnect;

	NSError *error;
	CXMLDocument *doc;
	
	NSURL *url = (NSURL *)CFBundleCopyResourceURL(CFBundleGetMainBundle(), (CFStringRef)configFile, CFSTR("xml"), NULL);
	
	if (!url) {
		if ([_delegate respondsToSelector:@selector(onConfigLoadFailure:)]) {
			[_delegate onConfigLoadFailure:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];			
		}
		
		return;
	}
	
	doc = [[CXMLDocument alloc] initWithContentsOfURL:url options:0 error:&error];
	[url release];
	
	_ipAddress =  [[[[doc nodesForXPath:@".//ip" error:&error] objectAtIndex:0] stringValue] copy];
	
	_port = [[[[doc nodesForXPath:@".//port" error:&error] objectAtIndex:0] stringValue] integerValue];
	_defaultZone = [[[[doc nodesForXPath:@".//zone" error:&error] objectAtIndex:0] stringValue] copy];
	
	if ([[doc nodesForXPath:@".//blueBoxIpAddress" error:&error] count]) {
		_blueBoxIpAddress = [[[[doc nodesForXPath:@".//blueBoxIpAddress" error:&error] objectAtIndex:0] stringValue] copy];
	}
	else {
		_blueBoxIpAddress = [_ipAddress copy];
	}
		
	if ([[doc nodesForXPath:@".//blueBoxPort" error:&error] count]) {
		_blueBoxPort = [[[[doc nodesForXPath:@".//blueBoxPort" error:&error] objectAtIndex:0] stringValue] integerValue];
	}
			
	if ([[doc nodesForXPath:@".//debug" error:&error] count]) {
		_debug = [[[[doc nodesForXPath:@".//debug" error:&error] objectAtIndex:0] stringValue] isEqualToString:@"true"] ? YES : NO;
	}
	
	if ([[doc nodesForXPath:@".//smartConnect" error:&error] count]) {
		_smartConnect = [[[[doc nodesForXPath:@".//smartConnect" error:&error] objectAtIndex:0] stringValue] isEqualToString:@"true"] ? YES : NO;
	}
					
	if ([[doc nodesForXPath:@".//httpPort" error:&error] count]) {
		_httpPort = [[[[doc nodesForXPath:@".//httpPort" error:&error] objectAtIndex:0] stringValue] integerValue];
	}
						
	if ([[doc nodesForXPath:@".//httpPollSpeed" error:&error] count]) {
		_httpPollSpeed = [[[[doc nodesForXPath:@".//httpPollSpeed" error:&error] objectAtIndex:0] stringValue] integerValue];
	}
							
	if ([[doc nodesForXPath:@".//rawProtocolSeparator" error:&error] count]) {
		_MSG_STR = [[[[doc nodesForXPath:@".//rawProtocolSeparator" error:&error] objectAtIndex:0] stringValue] copy];
	}
	
	if (_autoConnectOnConfigSuccess) {
		[self connect:_ipAddress port:_port];
	}
	else {
		// Dispatch onConfigLoadSuccess event
		if ([_delegate respondsToSelector:@selector(onConfigLoadSuccess:)]) {
			[_delegate onConfigLoadSuccess:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];			
		}	
	}
	
	[doc release];
}

- (NSString *)getConnectionMode
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getConnectionMode"]];
	
	NSString *mode = (NSString *)INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED;
	
	if (self.isConnected)
	{
		if (_isHttpMode)
			mode = (NSString *)INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP;
		else
			mode = (NSString *)INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET;
	}
	
	return mode;
}

- (void)connect:(NSString *)ipAdr  port:(NSInteger)port
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:connect ipAdr:%@ port:%ld", ipAdr, port]];
	
	if (!_connected) {
		[self initialize:NO];
		_ipAddress = [ipAdr copy];
		_port = port;
		
		_receiveBuffer = [[NSMutableData data] retain];
		_sendBuffers = [[NSMutableArray array] retain];
		_noDataSent = NO;
		_lastSendBuffer = nil;
		
		_receiveLock = [[NSLock alloc] init];
		_sendLock = [[NSLock alloc] init];
		
//		NSHost *host = [NSHost hostWithAddress:ipAdr];
		
		// iStream and oStream are instance variables
//		[NSStream getStreamsToHost:host port:port inputStream:&_inStream outputStream:&_outStream];
		[NSStream getStreamsToHostNamed:ipAdr port:port inputStream:&_inStream outputStream:&_outStream];
		
		[_inStream retain];
		[_outStream retain];
		
		[_inStream setDelegate:self];
		[_outStream setDelegate:self];
		
		[_inStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		[_outStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
		[_inStream open];
		[_outStream open];		
	}
	else
		[self debugMessage:@"*** ALREADY CONNECTED ***"];
}

- (void)releaseSocketConnectionResources
{
    [_receiveLock release];
	[_sendLock release];
	_receiveLock = nil;
	_sendLock = nil;

    [_inStream close];
	[_inStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_inStream release];
	_inStream = nil;

	[_outStream close];
	[_outStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[_outStream release];
	_outStream = nil;

	[_receiveBuffer release];
	[_sendBuffers release];
	_receiveBuffer = nil;
	_sendBuffers = nil;

	_lastSendBuffer = nil;
}

- (void)disconnect
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:disconnect"]];
	
	_connected = NO;
	
	if (!_isHttpMode) {
		[self releaseSocketConnectionResources];
	}
	else {
		[httpConnection close];
	}
			
	// dispatch event
	[[_messageHandlers objectForKey:@"sys"] dispatchDisconnection];
}

- (void)addBuddy:(NSString *)buddyName
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:addBuddy buddyName:%@", buddyName]];
	
	if (![buddyName isEqualToString:_myUserName] && ![self checkBuddyDuplicates:buddyName])
	{
		NSString *xmlMsg = [NSString stringWithFormat:@"<n>%@</n>", buddyName];
		[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"addB" fromRoom:-1 message:xmlMsg];
	}
}

- (void)autoJoin
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:autoJoin"]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"autoJoin" fromRoom:_activeRoomId message:@""];
}

- (void)clearBuddyList
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:clearBuddyList"]];
	
	[self debugMessage:@"SmartFoxiPhoneClient:clearBuddyList - deprecated"];
}

- (void)createRoom:(INFSmartFoxRoomCreateParams *)roomObj roomId:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:createRoom roomObj:%@ roomId:%ld", roomObj, roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	NSString *isGame = (roomObj.isGame) ? @"1" : @"0";
	NSString *exitCurrentRoom = @"1";
	
	if (roomObj.isGame)
		exitCurrentRoom = roomObj.exitCurrentRoom ? @"1" : @"0";
		
	NSString *xmlMsg  = [NSString stringWithFormat:@"<room tmp='1' gam='%@' spec='%ld' exit='%@'>", isGame, roomObj.maxSpectators, exitCurrentRoom];
	
	xmlMsg = [xmlMsg stringByAppendingFormat:@"<name><![CDATA[%@]]></name>", (roomObj.name == nil ? @"" : roomObj.name)];
	xmlMsg = [xmlMsg stringByAppendingFormat:@"<pwd><![CDATA[%@]]></pwd>", (roomObj.password == nil ? @"" : roomObj.password)];
	xmlMsg = [xmlMsg stringByAppendingFormat:@"<max>%ld</max>", roomObj.maxUsers];
	
	xmlMsg = [xmlMsg stringByAppendingFormat:@"<uCnt>%@</uCnt>", (roomObj.uCount ? @"1" : @"0")];
		
	// Set extension for room
	if (roomObj.extensionName != nil)
	{
		xmlMsg = [xmlMsg stringByAppendingFormat:@"<xt n='%@", roomObj.extensionName];
		xmlMsg = [xmlMsg stringByAppendingFormat:@"' s='%@' />", roomObj.extensionScript];
	}

	// Set Room Variables on creation
	if (roomObj.vars == nil)
		xmlMsg = [xmlMsg stringByAppendingString:@"<vars></vars>"];
	else
	{
		xmlMsg = [xmlMsg stringByAppendingString:@"<vars>"];
		
		for (int i = 0; i < [roomObj.vars count]; i++) {
			xmlMsg = [xmlMsg stringByAppendingString:[self getXmlRoomVariable:[roomObj.vars objectAtIndex:i]]];
		}
				
		xmlMsg = [xmlMsg stringByAppendingString:@"</vars>"];
	}
	
	xmlMsg = [xmlMsg stringByAppendingString:@"</room>"];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"createRoom" fromRoom:roomId message:xmlMsg];
}

- (NSMutableDictionary *)getAllRooms
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getAllRooms"]];
	
	return _roomList;
}

- (INFSmartFoxBuddy *)getBuddyByName:(NSString *)buddyName
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getBuddyByName buddyName:%@", buddyName]];
	
	// Check for buddy duplicates in the current buddy list
	NSEnumerator *enumerator = [_buddyList objectEnumerator];
	INFSmartFoxBuddy *value;
	
	while ((value = [enumerator nextObject])) {
		if ([value.name isEqualToString:buddyName]) {
			return value;
		}
	}
	
	return nil;
}

- (INFSmartFoxBuddy *)getBuddyById:(NSInteger)id
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getBuddyById id:%ld", id]];
	
	NSEnumerator *enumerator = [_buddyList objectEnumerator];
	INFSmartFoxBuddy *value;
	
	while ((value = [enumerator nextObject])) {			
		if (value.buddyId == id) {
			return value;
		}
	}
	
	return nil;
}

- (void)getBuddyRoom:(INFSmartFoxBuddy *)buddy
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getBuddyRoom"]];
	
	// If buddy is active...
	if (buddy.buddyId != -1)
		[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", [NSNumber numberWithInt:buddy.buddyId], @"bid", nil] action:@"roomB" fromRoom:-1 message:[NSString stringWithFormat:@"<b id='%ld' />", buddy.buddyId]];
}

- (INFSmartFoxRoom *)getRoom:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getRoom roomId:%ld", roomId]];
	
	return [_roomList objectForKey:[NSNumber numberWithInt:roomId]];
}

- (INFSmartFoxRoom *)getRoomByName:(NSString *)roomName
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getRoomByName roomName:%@", roomName]];
	
	NSEnumerator *enumerator = [_roomList objectEnumerator];
	INFSmartFoxRoom *value;
	
	while ((value = [enumerator nextObject])) {			
		if ([[value getName] isEqualToString:roomName])	{
			return value;
		}
	}
	
	return nil;
}

- (void)getRoomList
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getRoomList"]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"getRmList" fromRoom:_activeRoomId message:@""];
}

- (INFSmartFoxRoom *)getActiveRoom
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getActiveRoom"]];
	
	return [_roomList objectForKey:[NSNumber numberWithInt:_activeRoomId]];
}

- (void)getRandomKey
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getRandomKey"]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"rndK" fromRoom:-1 message:@""];
}

- (NSString *)getUploadPath
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getUploadPath"]];
	
	return [NSString stringWithFormat:@"http://%@:%@/default/uploads/", _ipAddress, _httpPort];
}

- (NSString *)getVersion
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getVersion"]];
	
	return [NSString stringWithFormat:@"%@.%@.%@", _majVersion, _minVersion, _subVersion];
}

- (void)joinRoom:(id)newRoom pword:(NSString *)pword isSpectator:(BOOL)isSpectator dontLeave:(BOOL)dontLeave oldRoom:(NSInteger)oldRoom
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:joinRoom newRoom:%@ pword:%@ isSpectator:%d dontLeave:%d oldRoom:%ld", newRoom, pword, isSpectator, dontLeave, oldRoom]];
	
	NSInteger newRoomId = -1;
	NSInteger isSpec = isSpectator ? 1 : 0;
	
	if (!_changingRoom) {
		if ([newRoom isKindOfClass:[NSNumber class]] || [[newRoom className] isEqualToString:@"NSCFNumber"]) {
			newRoomId = [newRoom intValue];
		}	
		else if ([newRoom isKindOfClass:[NSString class]] || [[newRoom className] isEqualToString:@"NSCFString"]) {
			// Search the room
			NSEnumerator *enumerator = [_roomList objectEnumerator];
			INFSmartFoxRoom *value;
			
			while ((value = [enumerator nextObject])) {			
				if ([[value getName] isEqualToString:newRoom])	{
					newRoomId = [value getId];
					break;
				}
			}
		}
		
		if (newRoomId != -1) {
			NSString *leaveCurrRoom = dontLeave ? @"0": @"1";
			
			// Set the room to leave
			NSInteger roomToLeave = oldRoom > -1 ? oldRoom : _activeRoomId;
			
			// CHECK: activeRoomId == -1 no room has already been entered
			if (_activeRoomId == -1) {
				leaveCurrRoom = @"0";
				roomToLeave = -1;
			}
			
			NSString *message = [NSString stringWithFormat:@"<room id='%ld' pwd='%@' spec='%d' leave='%@' old='%ld' />", newRoomId, pword, isSpec, leaveCurrRoom, roomToLeave];
			
			[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"joinRoom" fromRoom:_activeRoomId message:message];
			_changingRoom = true;
		}			
		else {
			[self debugMessage:@"SmartFoxError: requested room to join does not exist!"];
		}
	}
}

- (void)leaveRoom:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:leaveRoom roomId:%ld", roomId]];
	
	NSString *xmlMsg = [NSString stringWithFormat:@"<rm id='%ld' />", roomId];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"leaveRoom" fromRoom:roomId message:xmlMsg];
}

- (void)loadBuddyList
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:loadBuddyList"]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"loadB" fromRoom:-1 message:@""];
}

- (void)login:(NSString *)zone name:(NSString *)name pass:(NSString *)pass
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:login zone:%@ name:%@ pass:%@", zone, name, pass]];
	
	NSString *message = [NSString stringWithFormat:@"<login z='%@'><nick><![CDATA[%@]]></nick><pword><![CDATA[%@]]></pword></login>", zone, name, pass];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"login" fromRoom:0 message:message];
}

- (void)logout
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:logout"]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"logout" fromRoom:-1 message:@""];
}

- (void)removeBuddy:(NSString *)buddyName
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:removeBuddy buddyName:%@", buddyName]];
	
	BOOL found = NO;

	NSEnumerator *enumerator = [_buddyList keyEnumerator];
	id value;
	
	while ((value = [enumerator nextObject])) {
		if ([buddyName isEqualToString:((INFSmartFoxBuddy *)[_buddyList objectForKey:value]).name]) {
			[_buddyList removeObjectForKey:value];
			found = YES;
			break;
		}
	}
	
	if (found) {
		NSString *xmlMsg = [NSString stringWithFormat:@"<n>%@</n>", buddyName];
		
		[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"remB" fromRoom:-1 message:xmlMsg];
		
		// Fire event!
		if ([_delegate respondsToSelector:@selector(onBuddyList:)]) {			
			[_delegate onBuddyList:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:_buddyList, @"list", nil]]];
		}
	}
}

- (void)roundTripBench
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:roundTripBench"]];
	
	_benchStartTime = mach_absolute_time();
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"roundTrip" fromRoom:_activeRoomId message:@""];
}

- (void)sendBuddyPermissionResponse:(BOOL)allowBuddy targetBuddy:(NSString *)targetBuddy
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendBuddyPermissionResponse allowBuddy:%d targetBuddy:%@", allowBuddy, targetBuddy]];
	
	NSString *xmlMsg;
	
	xmlMsg = [NSString stringWithFormat:@"<n res='%@'>%@</n>", (allowBuddy ? @"g" : @"r"), targetBuddy];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"bPrm" fromRoom:-1 message:xmlMsg];
}

- (void)sendPublicMessage:(NSString *)message roomId:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendPublicMessage message:%@ roomId:%ld", message, roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
	
	NSString *xmlMsg;
	
	xmlMsg = [NSString stringWithFormat:@"<txt><![CDATA[%@]]></txt>", [INFSmartFoxEntities encodeEntities:message]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"pubMsg" fromRoom:roomId message:xmlMsg];
}

- (void)sendPrivateMessage:(NSString *)message recipientId:(NSInteger)recipientId roomId:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendPrivateMessage message:%@ recipientId:%ld roomId:%ld", message, recipientId, roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	NSString *xmlMsg;
	
	xmlMsg = [NSString stringWithFormat:@"<txt rcp='%ld'><![CDATA[%@]]></txt>", recipientId, [INFSmartFoxEntities encodeEntities:message]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"prvMsg" fromRoom:roomId message:xmlMsg];
}

- (void)sendModeratorMessage:(NSString *)message type:(NSString *)type id:(NSInteger)id
{	
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendModeratorMessage message:%@ type:%@ id:%ld", message, type, id]];
	
	NSString *xmlMsg;
	
	xmlMsg = [NSString stringWithFormat:@"<txt t='%@' id='%ld'><![CDATA[%@]]></txt>", type, id, [INFSmartFoxEntities encodeEntities:message]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"modMsg" fromRoom:_activeRoomId message:xmlMsg];
}

- (void)sendObject:(NSDictionary *)obj roomId:(NSInteger)roomId
{
	if (roomId == -1) {
		roomId = _activeRoomId;
	}
		
	NSString *xmlData = [NSString stringWithFormat:@"<![CDATA[%@]]>", [INFSmartFoxObjectSerializer serialize:obj]];
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"asObj" fromRoom:roomId message:xmlData];
}

- (void)sendObjectToGroup:(NSMutableDictionary *)obj userList:(NSArray *)userList roomId:(NSInteger)roomId
{
	if (roomId == -1) {
		roomId = _activeRoomId;
	}
	
	NSString *strList = @"";
	
	for (NSNumber *userId in userList) {
		strList = [strList stringByAppendingFormat:@"%ld,", [userId integerValue]];
	}
	
	strList = [strList substringWithRange:NSMakeRange(0, [strList length] - 1)];
	
	[obj setObject:strList forKey:@"_$$_"];
	
	NSString *xmlMsg = [NSString stringWithFormat:@"<![CDATA[%@]]>", [INFSmartFoxObjectSerializer serialize:obj]];
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"asObjG" fromRoom:roomId message:xmlMsg];
}

- (void)sendXtMessage:(NSString *)xtName cmd:(NSString *)cmd paramObj:(NSDictionary *)paramObj type:(NSString *)type roomId:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendXtMessage xtName:%@ cmd:%@ roomId:%ld", xtName, cmd, roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	// Send XML
	if ([type isEqualToString:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_XML])
	{
		NSString *xmlMsg = [NSString stringWithFormat:@"<![CDATA[%@]]>", [INFSmartFoxObjectSerializer serialize:[NSDictionary dictionaryWithObjectsAndKeys:xtName, @"name", cmd, @"cmd", paramObj, @"param", nil]]];
		[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"xt", @"t", nil] action:@"xtReq" fromRoom:roomId message:xmlMsg];
	}
	// Send raw/String
	else if ([type isEqualToString:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_STR])
	{
		NSString *hdr = [NSString stringWithFormat:@"%@xt%@%@%@%@%@%ld%@", _MSG_STR, _MSG_STR, xtName, _MSG_STR, cmd, _MSG_STR, roomId, _MSG_STR];
		
		NSEnumerator *enumerator = [paramObj objectEnumerator];
		id value;
		NSString *val = @"";
		
		while ((value = [enumerator nextObject])) {
			if ([[value className] isEqualToString:@"NSCFBoolean"])	{
				val = [value stringValue];
			}
			else if ([[value className] isEqualToString:@"NSCFNumber"])	{
				val = [value stringValue];
			}		
			else if ([value isKindOfClass:[NSString class]] || [[value className] isEqualToString:@"NSCFString"]) {
				val = value;
			}
			else if ([value isKindOfClass:[NSNull class]]) {
				val = @"null";
			}
			hdr = [hdr stringByAppendingFormat:@"%@%@",val, _MSG_STR];
		}
			
		[self sendString:hdr];
	}
	// Send JSON
	else if ([type isEqualToString:(NSString *)INFSMARTFOXCLIENT_XTMSG_TYPE_JSON])
	{
		NSDictionary *jsonObjectBody = [NSDictionary dictionaryWithObjectsAndKeys:xtName, @"x", cmd, @"c", [NSNumber numberWithInt:roomId], @"r", paramObj, @"p", nil];
		NSDictionary *jsonObject = [NSDictionary dictionaryWithObjectsAndKeys:@"xt", @"t", jsonObjectBody, @"b", nil];		
		
		[self sendJSON:[jsonObject JSONRepresentation]];
	}
}

- (void)setBuddyBlockStatus:(NSString *)buddyName status:(BOOL)status
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:setBuddyBlockStatus buddyName:%@ status:%d", buddyName, status]];
	
	INFSmartFoxBuddy *b = [self getBuddyByName:buddyName];
	
	if (b != nil)
	{
		if (b.isBlocked != status)
		{
			b.isBlocked = status;
			
			NSString *xmlMsg = [NSString stringWithFormat:@"<n x='%@'>%@</n>", (status ? @"1" : @"0", buddyName)];
			[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"setB" fromRoom:-1 message:xmlMsg];
			
			// Fire internal update
			if ([_delegate respondsToSelector:@selector(onBuddyListUpdate:)]) {			
				[_delegate onBuddyListUpdate:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:b, @"buddy", nil]]];
			}
		}
	}
}

- (void)setBuddyVariables:(NSDictionary *)varList
{			
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:setBuddyVariables"]];
	
	// Encapsulate Variables
	NSString *xmlMsg = @"<vars>";
	
	// Reference to the user setting the variables
	NSEnumerator *enumerator = [varList keyEnumerator];
	NSString *key;
	
	while ((key = [enumerator nextObject])) {
		if (![[varList objectForKey:key] isEqualToString:[_myBuddyVars objectForKey:key]]) {
			[_myBuddyVars setObject:[varList objectForKey:key] forKey:key];
			xmlMsg = [xmlMsg stringByAppendingString:[NSString stringWithFormat:@"<var n='%@'><![CDATA[%@]]></var>", key, [varList objectForKey:key]]];
		}
	}		
	
	xmlMsg = [xmlMsg stringByAppendingString:@"</vars>"];						
	
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"setBvars" fromRoom:-1 message:xmlMsg];
}

- (void)setRoomVariables:(NSArray *)varList roomId:(NSInteger)roomId setOwnership:(BOOL)setOwnership
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:setRoomVariables roomId:%ld setOwnership:%d", roomId, setOwnership]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	NSString *xmlMsg;
	
	if (setOwnership)
		xmlMsg = @"<vars>";
	else
		xmlMsg = @"<vars so='0'>";

	for (int i = 0; i < [varList count]; i++) {
		xmlMsg = [xmlMsg stringByAppendingString:[self getXmlRoomVariable:[varList objectAtIndex:i]]];
	}
	
	xmlMsg = [xmlMsg stringByAppendingString:@"</vars>"];						
				
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"setRvars" fromRoom:roomId message:xmlMsg];
}

- (void)setUserVariables:(NSDictionary *)varObj roomId:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:setUserVariables roomId:%ld", roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	INFSmartFoxRoom *currRoom = [self getActiveRoom];
	INFSmartFoxUser *user = [currRoom getUser:[NSNumber numberWithInt:_myUserId]];
	
	// Update local client
	[user setVariables:varObj];
	
	// Prepare and send message
	NSString *xmlMsg = [self getXmlUserVariable:varObj];
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"setUvars" fromRoom:roomId message:xmlMsg];
}

- (void)switchSpectator:(NSInteger)roomId
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:switchSpectator roomId:%ld", roomId]];
	
	if (roomId == -1)
		roomId = _activeRoomId;
		
	[self send:[NSDictionary dictionaryWithObjectsAndKeys:@"sys", @"t", nil] action:@"swSpec" fromRoom:roomId message:@""];
}

- (void)__logout
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:__logout"]];
	
	[self initialize:YES];
}

- (void)sendString:(NSString *)strMessage
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendString strMessage:%@", strMessage]];
	
	if (_isHttpMode) {
		[httpConnection send:strMessage];
	}
	else {
		[self writeToSocket:strMessage];
	}
}

- (void)sendJSON:(NSString *)jsonMessage
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:sendString jsonMessage:%@", jsonMessage]];
	
	if (_isHttpMode) {
		[httpConnection send:jsonMessage];
	}
	else {
		[self writeToSocket:jsonMessage];
	}
}

- (NSInteger)getBenchStartTime
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:getBenchStartTime"]];
	
	return _benchStartTime;
}

- (void)clearRoomList
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:clearRoomList"]];
	
	[_roomList removeAllObjects];
}

/*
 *
 * End of Public functions
 *
 */

- (void)dealloc
{
	[self debugMessage:[NSString stringWithFormat:@"INFSmartFoxiPhoneClient:dealloc"]];
	
	[_messageHandlers release];
	
	[INFSMARTFOXCLIENT_MSG_XML release];
	[INFSMARTFOXCLIENT_MSG_JSON release];
	
	[INFSMARTFOXCLIENT_MODMSG_TO_USER release];
	[INFSMARTFOXCLIENT_MODMSG_TO_ROOM release];
	[INFSMARTFOXCLIENT_MODMSG_TO_ZONE release];
	[INFSMARTFOXCLIENT_XTMSG_TYPE_XML release];
	[INFSMARTFOXCLIENT_XTMSG_TYPE_STR release];
	[INFSMARTFOXCLIENT_XTMSG_TYPE_JSON release];
	[INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED release];
	[INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET release];
	[INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP release];
	[_MSG_STR release];
	[_HTTP_POLL_REQUEST release];	
	[_ipAddress release];
	[_defaultZone release];
	[_blueBoxIpAddress release];
	[_myUserName release];
	
	[self releaseSocketConnectionResources];
	
    [super dealloc];
}

@end
