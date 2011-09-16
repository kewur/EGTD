//
//  INFSmartFoxiPhoneClient.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <CFNetwork/CFNetwork.h>
#import <mach/mach_time.h>

#import "NSStreamAddition.h"
#import "NSObjectAddition.h"
#import "INFSendBuffer.h"
#import "INFSmartFoxISFSEvents.h"
#import "SFSHttpConnection.h"

@class INFSmartFoxSysHandler, INFSmartFoxExtHandler, INFSmartFoxRoom, INFSmartFoxBuddy, INFSmartFoxRoomCreateParams;

/*! \mainpage Infosfer SmartFox iPhone Client Documentation
 *
 * SmartFox iPhone Client is developed by <b>Infosfer Game and Visualization Technologies Ltd.</b>
 * http://www.infosfer.com
 *
 * <b>Author:</b> Cem Uzunlar cem.uzunlar@infosfer.com
 */

/**
 * SmartFoxClient is the main class in the SmartFoxServer API.
 * This class is responsible for connecting to the server and handling all related events.
 * 
 * <b>NOTE</b>: in the provided examples, <b>smartFox</b> always indicates a SmartFoxClient instance.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.5.4
 * 
 */
@interface INFSmartFoxiPhoneClient : NSObject<SFSHttpConnectionDelegate> {
@private
	NSInteger INFSMARTFOXCLIENT_EOM;
	NSString *INFSMARTFOXCLIENT_MSG_XML;
	NSString *INFSMARTFOXCLIENT_MSG_JSON;
	
	NSString *INFSMARTFOXCLIENT_MODMSG_TO_USER;
	NSString *INFSMARTFOXCLIENT_MODMSG_TO_ROOM;
	NSString *INFSMARTFOXCLIENT_MODMSG_TO_ZONE;
	NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_XML;
	NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_STR;
	NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_JSON;
	NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED;
	NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET;
	NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP;
	
@private
	NSInputStream *_inStream;
	NSOutputStream *_outStream;
	
	NSLock *_receiveLock;	
	NSMutableData *_receiveBuffer;
	
	NSLock *_sendLock;	
	NSMutableArray *_sendBuffers;	
	INFSendBuffer *_lastSendBuffer;
	BOOL _noDataSent;
	
	id <INFSmartFoxISFSEvents>_delegate;
@private
	NSString *_MSG_STR;
	
	NSInteger _MIN_POLL_SPEED;
	NSInteger _DEFAULT_POLL_SPEED;
	NSInteger _MAX_POLL_SPEED;
	NSString *_HTTP_POLL_REQUEST;	
	// -------------------------------------------------------
	// Properties
	// -------------------------------------------------------	
@private
	NSMutableDictionary *_roomList;
	BOOL _connected;
	uint64_t _benchStartTime;
    mach_timebase_info_data_t _mach_timebase_info_data;
		
	NSInteger _majVersion;
	NSInteger _minVersion;
	NSInteger _subVersion;
	
	NSMutableDictionary *_messageHandlers;
	
	BOOL _autoConnectOnConfigSuccess;
	
@public	
	/**
	 * The SmartFoxServer IP address.
	 * 
	 * @see	connect:port:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 *
	 * @version	SmartFoxServer Pro
	 */
	NSString *_ipAddress;
	
	/**
	 * The SmartFoxServer connection port.
	 * The default port is <b>9339</b>.
	 * 
	 * @see	connect:port:
	 * 
	 * @version	SmartFoxServer Pro
	 */
	NSInteger _port;
	
	/**
	 * The default login zone.
	 * 
	 * @see	loadConfig:autoConnect:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Pro
	 */
	NSString *_defaultZone;
	
	//--- BlueBox settings (start) ---------------------------------------------------------------------
	
@private
	BOOL _isHttpMode;								// connection mode
	NSInteger _httpPollSpeed;					// bbox poll speed
    SFSHttpConnection* httpConnection;
	
@public
	/**
	 * The BlueBox IP address.
	 * 
	 * @see	_smartConnect
	 * @see	loadConfig:autoConnect:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @since	SmartFoxServer Pro v1.6.0
	 * 
	 * @version	SmartFoxServer Pro
	 */
	NSString *_blueBoxIpAddress;
	
	/**
	 * The BlueBox connection port.
	 * 
	 * @see	_smartConnect
	 * @see	loadConfig:autoConnect:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @since	SmartFoxServer Pro v1.6.0
	 * 
	 * @version	SmartFoxServer Pro
	 */
	NSInteger _blueBoxPort;
	
	/**
	 * A boolean flag indicating if the BlueBox http connection should be used in case a socket connection is not available.
	 * The default value is <b>true</b>.
	 * 
	 * @see	loadConfig:autoConnect:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @since	SmartFoxServer Pro v1.6.0
	 * 
	 * @version	SmartFoxServer Pro
	 */
	BOOL _smartConnect;
	
	//--- BlueBox settings (end) ---------------------------------------------------------------------
	
	/**
	 * An array containing the objects representing each buddy of the user's buddy list.
	 * The buddy list can be iterated with a <i>for-in</i> loop, or a specific object can be retrieved by means of the \link INFSmartFoxiPhoneClient#getBuddyById: getBuddyById \endlink and @link INFSmartFoxiPhoneClient#getBuddyByName: getBuddyByName @endlink methods.
	 * 
	 * <b>NOTE</b>: this property and all the buddy-related method are available only if the buddy list feature is enabled for the current zone. Check the SmartFoxServer server-side configuration.
	 * 
	 * Each element in the buddy list is an object with the following properties:
	 * @param	id :			(<b>int</b>) the buddy id.
	 * @param	name :		(<b>String</b>) the buddy name.
	 * @param	isOnline :	(<b>Boolean</b>) the buddy online status: <b>true</b> if the buddy is online; <b>false</b> if the buddy is offline.
	 * @param	isBlocked :	(<b>Boolean</b>) the buddy block status: <b>true</b> if the buddy is blocked; <b>false</b> if the buddy is not blocked; when a buddy is blocked, SmartFoxServer does not deliver private messages from/to that user.
	 * @param	variables :	(<b>Object</b>) an object with extra properties of the buddy (Buddy Variables); see also @link INFSmartFoxiPhoneClient#setBuddyVariables: setBuddyVariables @endlink.
	 * 
	 * @see		_myBuddyVars
	 * @see		loadBuddyList
	 * @see		getBuddyById:
	 * @see		getBuddyByName:
	 * @see		removeBuddy:
	 * @see		setBuddyBlockStatus:status:
	 * @see		setBuddyVariables:
	 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
	 * @see		@link INFSmartFoxISFSEvents-p#onBuddyListUpdate: onBuddyListUpdate (INFSmartFoxISFSEvents) @endlink
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @history	SmartFoxServer Pro v1.6.0 - Buddy's <i>isBlocked</i> property added.
	 * 
	 * @version	SmartFoxServer Basic (except block status) / Pro
	 */
	NSMutableDictionary *_buddyList;
	
	/**
	 * The current user's Buddy Variables.
	 * This is an associative array containing the current user's properties when he/she is present in the buddy lists of other users.
	 * See the @link INFSmartFoxiPhoneClient#setBuddyVariables: setBuddyVariables @endlink method for more details.
	 * 
	 * @see		setBuddyVariables:
	 * @see		getBuddyById:
	 * @see		getBuddyByName:
	 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
	 * @see		@link INFSmartFoxISFSEvents-p#onBuddyListUpdate: onBuddyListUpdate (INFSmartFoxISFSEvents) @endlink
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @since	SmartFoxServer Pro v1.6.0
	 * 
	 * @version	SmartFoxServer Pro
	 */
	NSMutableDictionary *_myBuddyVars;
	
	/**
	 * Toggle the client-side debugging informations.
	 * When turned on, the developer is able to inspect all server messages that are sent and received by the client in the Flash authoring environment.
	 * This allows a better debugging of the interaction with the server during application developement.
	 * 
	 * @see		@link INFSmartFoxISFSEvents-p#onDebugMessage: onDebugMessage (INFSmartFoxISFSEvents) @endlink
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	BOOL _debug;
	
	/**
	 * The current user's SmartFoxServer id.
	 * The id is assigned to a user on the server-side as soon as the client connects to SmartFoxServer successfully.
	 * 
	 * <b>NOTE:</b> client-side, the <b>myUserId</b> property is available only after a successful login is performed using the default login procedure.
	 * If a custom login process is implemented, this property must be manually set after the successful login! If not, various client-side modules (SmartFoxBits, RedBox, etc.) may not work properly.
	 * 
	 * @see		myUserName
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	NSInteger _myUserId;
	
	/**
	 * The current user's SmartFoxServer username.
	 * 
	 * <b>NOTE</b>: client-side, the <b>myUserName</b> property is available only after a successful login is performed using the default login procedure.
	 * If a custom login process is implemented, this property must be manually set after the successful login! If not, various client-side modules (SmartFoxBits, RedBox, etc.) may not work properly.
	 * 
	 * @see		myUserId
	 * @see		login:name:pass:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	NSString *_myUserName;
	
	/**
	 * The current user's id as a player in a game room.
	 * The <b>playerId</b> is available only after the user successfully joined a game room. This id is 1-based (player 1, player 2, etc.), but if the user is a spectator or the room is not a game room, its value is -1.
	 * When a user joins a game room, a player id (or "slot") is assigned to him/her, based on the slots available in the room at the moment in which the user entered it; for example:
	 * <ul>
	 * 	<li>in a game room for 2 players, the first user who joins it becomes player one (playerId = 1) and the second user becomes player two (player = 2);</li>
	 * 	<li>in a game room for 4 players where only player three is missing, the next user who will join the room will be player three (playerId = 3);</li>
	 * </ul>
	 * 
	 * <b>NOTE</b>: if multi-room join is allowed, this property contains only the last player id assigned to the user, and so it's useless.
	 * In this case the @link INFSmartFoxRoom#getMyPlayerIndex getMyPlayerIndex @endlink method should be used to retrieve the player id for each joined room.
	 * 
	 * @see		INFSmartFoxRoom#getMyPlayerIndex
	 * @see		INFSmartFoxRoom#isGame
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	NSInteger _playerId;
	
	/**
	 * A boolean flag indicating if the user is recognized as Moderator.
	 * 
	 * @see		sendModeratorMessage:type:id:
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	BOOL _amIModerator;
	
	/**
	 * The property stores the id of the last room joined by the current user.
	 * In most multiuser applications users can join one room at a time: in this case this property represents the id of the current room.
	 * If multi-room join is allowed, the application should track the various id(s) in an array (for example) and this property should be ignored.
	 * 
	 * @see		getActiveRoom
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	NSInteger _activeRoomId;
	
	/**
	 * A boolean flag indicating if the process of joining a new room is in progress.
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 */
	BOOL _changingRoom;
	
	/**
	 * The TCP port used by the embedded webserver.
	 * The default port is <b>8080</b>; if the webserver is listening on a different port number, this property should be set to that value.
	 * 
	 * @see		uploadFile
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 * 
	 * @since	SmartFoxServer Pro v1.5.0
	 * 
	 * @version	SmartFoxServer Basic / Pro
	 */
	NSInteger _httpPort;
	
}

/**
 * Get/set the character used as separator for the String (raw) protocol.
 * The default value is <b>%</b> (percentage character).
 * 
 * <b>NOTE</b>: this separator must match the one set in the SmartFoxServer server-side configuration file through the <b><RawProtocolSeparator></b> parameter.
 * 
 * @see		INFSMARTFOXCLIENT_XTMSG_TYPE_STR
 * @see		sendXtMessage:cmd:paramObj:type:roomId:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.5.5
 * 
 * @version	SmartFoxServer Pro
 */
@property (assign) NSString *rawProtocolSeparator;

/**
 * A boolean flag indicating if the current user is connected to the server.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
@property (assign) BOOL isConnected;

/**
 * The minimum interval between two polling requests when connecting to SmartFoxServer via BlueBox module.
 * The default value is 750 milliseconds. Accepted values are between 0 and 10000 milliseconds (10 seconds).
 * 
 * @usageNote	<i>Which is the optimal value for polling speed?</i>
 * 				A value between 750-1000 ms is very good for chats, turn-based games and similar kind of applications. It adds minimum lag to the client responsiveness and it keeps the server CPU usage low.
 * 				Lower values (200-500 ms) can be used where a faster responsiveness is necessary. For super fast real-time games values between 50 ms and 100 ms can be tried.
 * 				With settings < 200 ms the CPU usage will grow significantly as the http connection and packet wrapping/unwrapping is more expensive than using a persistent connection.
 * 				Using values below 50 ms is not recommended.
 * 
 * @see		_smartConnect
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
@property (assign) NSInteger httpPollSpeed;

@property (readonly) id<INFSmartFoxISFSEvents> delegate;

@property (readonly) NSString *defaultZone;
@property (assign) BOOL amIModerator;
@property (assign) NSInteger myUserId;
@property (assign) NSInteger playerId;
@property (retain) NSString *myUserName;
@property (assign) NSInteger activeRoomId;
@property (assign) BOOL changingRoom;
@property (readonly) mach_timebase_info_data_t mach_timebase_info_data;
@property (readonly) NSMutableDictionary *myBuddyVars;
@property (readonly) NSMutableDictionary *buddyList;

@property (readonly) NSInteger INFSMARTFOXCLIENT_EOM;
@property (readonly) NSString *INFSMARTFOXCLIENT_MSG_XML;
@property (readonly) NSString *INFSMARTFOXCLIENT_MSG_JSON;

/**
 * Moderator message type: "to user".
 * The Moderator message is sent to a single user.
 * 
 * @see	sendModeratorMessage:type:id:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_MODMSG_TO_USER;

/**
 * Moderator message type: "to room".
 * The Moderator message is sent to all the users in a room.
 * 
 * @see	sendModeratorMessage:type:id:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_MODMSG_TO_ROOM;

/**
 * Moderator message type: "to zone".
 * The Moderator message is sent to all the users in a zone.
 * 
 * @see	sendModeratorMessage:type:id:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_MODMSG_TO_ZONE;

/**
 * Server-side extension request/response protocol: XML.
 * 
 * @see	sendXtMessage:cmd:paramObj:type:roomId:
 * @see @link INFSmartFoxISFSEvents-p#onExtensionResponse: onExtensionResponse (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_XML;

/**
 * Server-side extension request/response protocol: String (aka "raw protocol").
 * 
 * @see	sendXtMessage:cmd:paramObj:type:roomId:
 * @see @link INFSmartFoxISFSEvents-p#onExtensionResponse: onExtensionResponse (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_STR;

/**
 * Server-side extension request/response protocol: JSON.
 * 
 * @see	sendXtMessage:cmd:paramObj:type:roomId:
 * @see @link INFSmartFoxISFSEvents-p#onExtensionResponse: onExtensionResponse (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_XTMSG_TYPE_JSON;

/**
 * Connection mode: "disconnected".
 * The client is currently disconnected from SmartFoxServer.
 * 
 * @see	getConnectionMode
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED;

/**
 * Connection mode: "socket".
 * The client is currently connected to SmartFoxServer via socket.
 * 
 * @see	getConnectionMode
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET;

/**
 * Connection mode: "http".
 * The client is currently connected to SmartFoxServer via http.
 * 
 * @see	getConnectionMode
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
@property (readonly) NSString *INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP;

+ (id)iPhoneClient:(BOOL)debug delegate:(id <INFSmartFoxISFSEvents>)delegate;

/**
 * The SmartFoxClient contructor.
 * 
 * @param	debug :	turn on the debug messages (optional).
 * @param	delegate :	specifies the delegate object which will receive events.(optional).
 *
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 */
- (id)initWithParams:(BOOL)debug delegate:(id <INFSmartFoxISFSEvents>)delegate;

- (void)debugMessage:(NSString *)message;

/**
 * Load a client configuration file.
 * The SmartFoxClient instance can be configured through an external xml configuration file loaded at run-time.
 * By default, the <b>loadConfig</b> method loads a file named "config.xml", placed in the same folder of the application swf file.
 * If the <i>autoConnect</i> parameter is set to <b>true</b>, on loading completion the @link INFSmartFoxiPhoneClient#connect:port: connect @endlink method is automatically called by the API, otherwise the @link INFSmartFoxISFSEvents-p#onConfigLoadSuccess: onConfigLoadSuccess (INFSmartFoxISFSEvents) @endlink event is dispatched.
 * In case of loading error, the @link INFSmartFoxISFSEvents-p#onConfigLoadFailure: onConfigLoadFailure (INFSmartFoxISFSEvents) @endlink event id fired.
 * 
 * <b>NOTE</b>: the SmartFoxClient configuration file (client-side) should not be confused with the SmartFoxServer configuration file (server-side).
 * 
 * @usageNote	The external xml configuration file has the following structure; ip, port and zone parameters are mandatory, all other parameters are optional.
 * 				@code
 * 				<SmartFoxClient>
 * 					<ip>127.0.0.1</ip>
 * 					<port>9339</port>
 * 					<zone>simpleChat</zone>
 * 					<debug>true</debug>
 * 					<blueBoxIpAddress>127.0.0.1</blueBoxIpAddress>
 * 					<blueBoxPort>9339</blueBoxPort>
 * 					<smartConnect>true</smartConnect>
 * 					<httpPort>8080</httpPort>
 * 					<httpPollSpeed>750</httpPollSpeed>
 * 					<rawProtocolSeparator>%</rawProtocolSeparator>
 * 				</SmartFoxClient>
 * 				@endcode
 * 
 * @param	configFile :		external xml configuration file name (optional).
 * @param	autoConnect :	a boolean flag indicating if the connection to SmartFoxServer must be attempted upon configuration loading completion (optional).
 * 
 * @sends	SFSEvent#onConfigLoadSuccess
 * @sends	SFSEvent#onConfigLoadFailure
 * 
 * @see		_ipAddress
 * @see		_port
 * @see		_defaultZone
 * @see		_debug
 * @see		_blueBoxIpAddress
 * @see		_blueBoxPort
 * @see		_smartConnect
 * @see		_httpPort
 * @see		httpPollSpeed
 * @see		rawProtocolSeparator
 * @see		@link INFSmartFoxISFSEvents-p#onConfigLoadSuccess: onConfigLoadSuccess (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onConfigLoadFailure: onConfigLoadFailure (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (void)loadConfig:(NSString *)configFile autoConnect:(BOOL)autoConnect;

/**
 * Get the current connection mode.
 * 
 * @return	The current connection mode, expressed by one of the following constants: INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED (disconnected), INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET (socket mode), INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP (http mode).
 * 
 * @see		INFSMARTFOXCLIENT_CONNECTION_MODE_DISCONNECTED
 * @see		INFSMARTFOXCLIENT_CONNECTION_MODE_SOCKET
 * @see		INFSMARTFOXCLIENT_CONNECTION_MODE_HTTP
 * @see		connect:port:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (NSString *)getConnectionMode;

/**
 * Establish a connection to SmartFoxServer.
 * The client usually gets connected to SmartFoxServer through a socket connection. In SmartFoxServer Pro, if a socket connection is not available and the @link INFSmartFoxiPhoneClient#_smartConnect smartConnect @endlink property is set to <b>true</b>, an http connection to the BlueBox module is attempted.
 * When a successful connection is established, the @link INFSmartFoxiPhoneClient#getConnectionMode getConnectionMode @endlink can be used to check the current connection mode.
 * 
 * @param	ipAdr :	the SmartFoxServer ip address.
 * @param	port :	the SmartFoxServer TCP port (optional).
 * 
 * @sends	SFSEvent#onConnection
 * 
 * @see		disconnect
 * @see		getConnectionMode
 * @see		_smartConnect
 * @see		@link INFSmartFoxISFSEvents-p#onConnection: onConnection (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @history	SmartFoxServer Pro v1.6.0 - BlueBox connection attempt in case of socket connection not available.
 * 
 * @version	SmartFoxServer Basic (except BlueBox connection) / Pro
 */
- (void)connect:(NSString *)ipAdr  port:(NSInteger)port;

- (void)releaseSocketConnectionResources;

/**
 * Close the current connection to SmartFoxServer.
 * 
 * @sends	SFSEvent#onConnectionLost
 * 
 * @see		connect:port:
 * @see		@link INFSmartFoxISFSEvents-p#onConnectionLost: onConnectionLost (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)disconnect;

/**
 * Add a user to the buddy list.
 * Since SmartFoxServer Pro 1.6.0, the buddy list feature can be configured to use a <i>basic</i> or <i>advanced</i> security mode (see the SmartFoxServer server-side configuration file).
 * Check the following usage notes for details on the behavior of the <b>addBuddy</b> method in the two cases.
 * 
 * @usageNote	<i>Basic security mode</i>
 * 				When a buddy is added, if the buddy list is already full, the @link INFSmartFoxISFSEvents-p#onBuddyListError: onBuddyListError (INFSmartFoxISFSEvents) @endlink event is fired; otherwise the buddy list is updated and the @link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink event is fired.
 * 				<hr />
 * 				<i>Advanced security mode</i>
 * 				If the <b><addBuddyPermission></b> parameter is set to <b>true</b> in the buddy list configuration section of a zone, before the user is actually added to the buddy list he/she must grant his/her permission.
 * 				The permission request is sent if the user is online only; the user receives the @link INFSmartFoxISFSEvents-p#onBuddyPermissionRequest: onBuddyPermissionRequest (INFSmartFoxISFSEvents) @endlink event. When the permission is granted, the buddy list is updated and the @link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink event is fired.
 * 				If the permission is not granted (or the buddy didn't receive the permission request), the <b>addBuddy</b> method can be called again after a certain amount of time only. This time is set in the server configuration <b><permissionTimeOut></b> parameter.
 * 				Also, if the <b><mutualAddBuddy></b> parameter is set to <b>true</b>, when user A adds user B to the buddy list, he/she is automatically added to user B's buddy list.
 * 				Lastly, if the buddy list is full, the @link INFSmartFoxISFSEvents-p#onBuddyListError: onBuddyListError (INFSmartFoxISFSEvents) @endlink event is fired.
 * 
 * @param	buddyName :	the name of the user to be added to the buddy list.
 * 
 * @sends	SFSEvent#onBuddyList
 * @sends	SFSEvent#onBuddyListError
 * @sends	SFSEvent#onBuddyPermissionRequest
 * 
 * @see		_buddyList
 * @see		removeBuddy:
 * @see		setBuddyBlockStatus:status:
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyListError: onBuddyListError (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyPermissionRequest: onBuddyPermissionRequest (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @history	SmartFoxServer Pro v1.6.0 - Buddy list's <i>advanced security mode</i> implemented.
 * 
 * @version	SmartFoxServer Basic (except <i>advanced mode</i>) / Pro
 */
- (void)addBuddy:(NSString *)buddyName;

/**
 * Automatically join the the default room (if existing) for the current zone.
 * A default room can be specified in the SmartFoxServer server-side configuration by adding the @code autoJoin = "true" @endcode attribute to one of the <b><Room></b> tags in a zone.
 * When a room is marked as <i>autoJoin</i> it becomes the default room where all clients are joined when this method is called.
 * 
 * @sends	SFSEvent#onJoinRoom
 * @sends	SFSEvent#onJoinRoomError
 * 
 * @see		joinRoom:pword:isSpectator:dontLeave:oldRoom:
 * @see		@link INFSmartFoxISFSEvents-p#onJoinRoom: onJoinRoom (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onJoinRoomError: onJoinRoomError (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)autoJoin;

/**
 * Remove all users from the buddy list.
 * 
 * @deprecated	In order to avoid conflits with the buddy list <i>advanced security mode</i> implemented since SmartFoxServer Pro 1.6.0, buddies should be removed one by one, by iterating through the buddy list.
 * 
 * @sends	SFSEvent#onBuddyList
 * 
 * @see		buddyList
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @history	SmartFoxServer Pro v1.6.0 - Method deprecated.
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)clearBuddyList;

/**
 * Dynamically create a new room in the current zone.
 * 
 * <b>NOTE</b>: if the newly created room is a game room, the user is joined automatically upon successful room creation.
 * 
 * @param	roomObj :	an object with the properties described farther on.
 * @param	roomId :		the id of the room from where the request is originated, in case the application allows multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink). 
 * 
 * <hr />
 * The <i>roomObj</i> parameter is an object containing the following properties:
 * @param	name :				(<b>String</b>) the room name.
 * @param	password :			(<b>String</b>) a password to make the room private (optional, default: none).
 * @param	maxUsers :			(<b>int</b>) the maximum number of users that can join the room.
 * @param	maxSpectators :		(<b>int</b>) in game rooms only, the maximum number of spectators that can join the room (optional, default value: 0).
 * @param	isGame :				(<b>Boolean</b>) if <b>true</b>, the room is a game room (optional, default value: <b>false</b>).
 * @param	exitCurrentRoom :	(<b>Boolean</b>) if <b>true</b> and in case of game room, the new room is joined after creation (optional, default value: <b>true</b>).
 * @param	uCount :				(<b>Boolean</b>) if <b>true</b>, the new room will receive the @link INFSmartFoxISFSEvents-p#onUserCountChange: onUserCountChange (INFSmartFoxISFSEvents) @endlink notifications (optional, default <u>recommended</u> value: <b>false</b>).
 * @param	vars :				(<b>Array</b>) an array of Room Variables, as described in the @link INFSmartFoxiPhoneClient#setRoomVariables:roomId:setOwnership: setRoomVariables @endlink method documentation (optional, default: none).
 * @param	extension :			(<b>Object</b>) which extension should be dynamically attached to the room, as described farther on (optional, default: none).
 * 
 * <hr />
 * A Room-level extension can be attached to any room during creation; the <i>extension</i> property in the <i>roomObj</i> parameter is an object with the following properties:
 * @param	name :	(<b>String</b>) the name used to reference the extension (see the SmartFoxServer server-side configuration).
 * @param	script :	(<b>String</b>) the file name of the extension script (for Actionscript and Python); if Java is used, the fully qualified name of the extension must be provided. The file name is relative to the root of the extension folder ("sfsExtensions/" for Actionscript and Python, "javaExtensions/" for Java).
 * 
 * @sends	SFSEvent#onRoomAdded
 * @sends	SFSEvent#onCreateRoomError
 * 
 * @see		@link INFSmartFoxISFSEvents-p#onRoomAdded: onRoomAdded (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onCreateRoomError: onCreateRoomError (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onUserCountChange: onUserCountChange (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)createRoom:(INFSmartFoxRoomCreateParams *)roomObj roomId:(NSInteger)roomId;

/**
 * Get the list of rooms in the current zone.
 * Unlike the @link INFSmartFoxiPhoneClient#getRoomList getRoomList @endlink method, this method returns the list of {@link INFSmartFoxRoom} objects already stored on the client, so no request is sent to the server.
 * 
 * @return	The list of rooms available in the current zone.
 * 
 * @see		getRoomList
 * @see		INFSmartFoxRoom
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSMutableDictionary *)getAllRooms;

- (void)setRoomList:(NSMutableDictionary *)newRoomList;

/**
 * Get a buddy from the buddy list, using the buddy's username as key.
 * Refer to the @link INFSmartFoxiPhoneClient#buddyList buddyList @endlink property for a description of the buddy object's properties.
 * 
 * @param	buddyName :	the username of the buddy.
 * 
 * @return	The buddy object.
 * 
 * @see 	buddyList
 * @see		getBuddyById:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (INFSmartFoxBuddy *)getBuddyByName:(NSString *)buddyName;

/**
 * Get a buddy from the buddy list, using the user id as key.
 * Refer to the @link INFSmartFoxiPhoneClient#buddyList buddyList @endlink property for a description of the buddy object's properties.
 * 
 * @param	id :	the user id of the buddy.
 * 
 * @return	The buddy object.
 * 
 * @see 	buddyList
 * @see		getBuddyByName:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (INFSmartFoxBuddy *)getBuddyById:(NSInteger)id;

/**
 * Request the room id(s) of the room(s) where a buddy is currently located into.
 * 
 * @param	buddy :	a buddy object taken from the @link INFSmartFoxiPhoneClient#buddyList buddyList @endlink array.
 * 
 * @sends	SFSEvent#onBuddyRoom
 * 
 * @see 	buddyList
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyRoom: onBuddyRoom (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)getBuddyRoom:(INFSmartFoxBuddy *)buddy;

/**
 * Get a {@link INFSmartFoxRoom} object, using its id as key.
 * 
 * @param	roomId : the id of the room.
 * 
 * @return	The {@link INFSmartFoxRoom} object.
 * 
 * @see 	getRoomByName:
 * @see		getAllRooms
 * @see		getRoomList
 * @see		INFSmartFoxRoom
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (INFSmartFoxRoom *)getRoom:(NSInteger)roomId;

/**
 * Get a {@link INFSmartFoxRoom} object, using its name as key.
 * 
 * @param	roomName :	the name of the room.
 * 
 * @return	The {@link INFSmartFoxRoom} object.
 * 
 * @see 	getRoom:
 * @see		getAllRooms
 * @see		getRoomList
 * @see		INFSmartFoxRoom
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (INFSmartFoxRoom *)getRoomByName:(NSString *)roomName;

/**
 * Retrieve the updated list of rooms in the current zone.
 * Unlike the @link INFSmartFoxiPhoneClient#getAllRooms getAllRooms @endlink method, this method sends a request to the server, which then sends back the complete list of rooms with all their properties and server-side variables (Room Variables).
 * 
 * If the default login mechanism provided by SmartFoxServer is used, then the updated list of rooms is received right after a successful login, without the need to call this method.
 * Instead, if a custom login handler is implemented, the room list must be manually requested to the server using this method.
 * 
 * @sends	SFSEvent#onRoomListUpdate
 * 
 * @see		getRoom:
 * @see		getRoomByName:
 * @see		getAllRooms
 * @see		@link INFSmartFoxISFSEvents-p#onRoomListUpdate: onRoomListUpdate (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)getRoomList;

/**
 * Get the currently active {@link INFSmartFoxRoom} object.
 * SmartFoxServer allows users to join two or more rooms at the same time (multi-room join). If this feature is used, then this method is useless and the application should track the various room id(s) manually, for example by keeping them in an array.
 * 
 * @return	the {@link INFSmartFoxRoom} object of the currently active room; if the user joined more than one room, the last joined room is returned.
 * 
 * @see		activeRoomId
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (INFSmartFoxRoom *)getActiveRoom;

/**
 * Retrieve a random string key from the server.
 * This key is also referred in the SmartFoxServer documentation as the "secret key".
 * It's a unique key, valid for the current session only. It can be used to create a secure login system.
 * 
 * @sends	SFSEvent#onRandomKey
 * 
 * @see		@link INFSmartFoxISFSEvents-p#onRandomKey: onRandomKey (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Pro
 */
- (void)getRandomKey;

/**
 * Get the default upload path of the embedded webserver.
 * 
 * @return	The http address of the default folder in which files are uploaded.
 * 
 * @see		uploadFile
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.5.0
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSString *)getUploadPath;

/**
 * Get the SmartFoxServer Flash API version.
 * 
 * @return	The current version of the SmartFoxServer client API.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSString *)getVersion;

/**
 * Join a room.
 * 
 * @param	newRoom :		the name (<b>String</b>) or the id (<b>int</b>) of the room to join.
 * @param	pword :			the room's password, if it's a private room (optional).
 * @param	isSpectator :	a boolean flag indicating wheter you join as a spectator or not (optional).
 * @param	dontLeave :		a boolean flag indicating if the current room must be left after successfully joining the new room (optional).
 * @param	oldRoom :		the id of the room to leave (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * <hr />
 * <b>NOTE</b>: the last two optional parameters enable the advanced multi-room join feature of SmartFoxServer, which allows a user to join two or more rooms at the same time. If this feature is not required, the parameters can be omitted.
 * 
 * @sends	SFSEvent#onJoinRoom
 * @sends	SFSEvent#onJoinRoomError
 * 
 * @see		@link INFSmartFoxISFSEvents-p#onJoinRoom: onJoinRoom (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onJoinRoomError: onJoinRoomError (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)joinRoom:(id)newRoom pword:(NSString *)pword isSpectator:(BOOL)isSpectator dontLeave:(BOOL)dontLeave oldRoom:(NSInteger)oldRoom;

/** 
 * Disconnect the user from the given room.
 * This method should be used only when users are allowed to be present in more than one room at the same time (multi-room join feature).
 * 
 * @param	roomId :	the id of the room to leave.
 * 
 * @sends	SFSEvent#onRoomLeft
 * 
 * @see 	joinRoom:pword:isSpectator:dontLeave:oldRoom:
 * @see		@link INFSmartFoxISFSEvents-p#onRoomLeft: onRoomLeft (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)leaveRoom:(NSInteger)roomId;

/**
 * Load the buddy list for the current user.
 * 
 * @sends	SFSEvent#onBuddyList
 * @sends	SFSEvent#onBuddyListError
 * 
 * @see		_buddyList
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyListError: onBuddyListError (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)loadBuddyList;

/**
 * Perform the default login procedure.
 * The standard SmartFoxServer login procedure accepts guest users. If a user logs in with an empty username, the server automatically creates a name for the client using the format <i>guest_n</i>, where <i>n</i> is a progressive number.
 * Also, the provided username and password are checked against the moderators list (see the SmartFoxServer server-side configuration) and if a user matches it, he is set as a Moderator.
 * 
 * <b>NOTE 1</b>: duplicate names in the same zone are not allowed.
 * 
 * <b>NOTE 2</b>: for SmartFoxServer Basic, where a server-side custom login procedure can't be implemented due to the lack of <i>extensions</i> support, a custom client-side procedure can be used, for example to check usernames against a database using a php/asp page.
 * In this case, this should be done BEFORE calling the <b>login</b> method. This way, once the client is validated, the stadard login procedure can be used.
 * 
 * @param	zone :	the name of the zone to log into.
 * @param	name :	the user name.
 * @param	pass :	the user password.
 * 
 * @sends	SFSEvent#onLogin
 * 
 * @see 	logout
 * @see		@link INFSmartFoxISFSEvents-p#onLogin: onLogin (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)login:(NSString *)zone name:(NSString *)name pass:(NSString *)pass;

/**
 * Log the user out of the current zone.
 * After a successful logout the user is still connected to the server, but he/she has to login again into a zone, in order to be able to interact with the server.
 * 
 * @sends	SFSEvent#onLogout
 * 
 * @see 	login:name:pass:
 * @see		@link INFSmartFoxISFSEvents-p#onLogout: onLogout (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.5.5
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)logout;

/**
 * Remove a buddy from the buddy list.
 * Since SmartFoxServer Pro 1.6.0, the buddy list feature can be configured to use a <i>basic</i> or <i>advanced</i> security mode (see the SmartFoxServer server-side configuration file).
 * Check the following usage notes for details on the behavior of the <b>removeBuddy</b> method in the two cases.
 * 
 * @usageNote	<i>Basic security mode</i>
 * 				When a buddy is removed, the buddy list is updated and the @link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink event is fired.
 * 				<hr />
 * 				<i>Advanced security mode</i>
 * 				In addition to the basic behavior, if the <b><mutualRemoveBuddy></b> server-side configuration parameter is set to <b>true</b>, when user A removes user B from the buddy list, he/she is automatically removed from user B's buddy list.
 * 
 * @param	buddyName :	the name of the user to be removed from the buddy list.
 * 
 * @sends	SFSEvent#onBuddyList
 * 
 * @see		_buddyList
 * @see		addBuddy:
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyList: onBuddyList (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @history	SmartFoxServer Pro v1.6.0 - Buddy list's <i>advanced security mode</i> implemented.
 * 
 * @version	SmartFoxServer Basic (except <i>advanced mode</i>) / Pro
 */
- (void)removeBuddy:(NSString *)buddyName;

/**
 * Send a roundtrip request to the server to test the connection' speed.
 * The roundtrip request sends a small packet to the server which immediately responds with another small packet, and causing the @link INFSmartFoxISFSEvents-p#onRoundTripResponse: onRoundTripResponse (INFSmartFoxISFSEvents) @endlink event to be fired.
 * The time taken by the packet to travel forth and back is called "roundtrip time" and can be used to calculate the average network lag of the client.
 * A good way to measure the network lag is to send continuos requests (every 3 or 5 seconds) and then calculate the average roundtrip time on a fixed number of responses (i.e. the last 10 measurements).
 * 
 * @sends	SFSEvent#onRoundTripResponse
 * 
 * @see		@link INFSmartFoxISFSEvents-p#onRoundTripResponse: onRoundTripResponse (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)roundTripBench;

/**
 * Grant current user permission to be added to a buddy list.
 * If the SmartFoxServer Pro 1.6.0 <i>advanced</i> security mode is used (see the SmartFoxServer server-side configuration), when a user wants to add a buddy to his/her buddy list, a permission request is sent to the buddy.
 * Once the @link INFSmartFoxISFSEvents-p#onBuddyPermissionRequest: onBuddyPermissionRequest (INFSmartFoxISFSEvents) @endlink event is received, this method must be used by the buddy to grant or refuse permission. When the permission is granted, the requester's buddy list is updated.
 * 
 * @param	allowBuddy :		<b>true</b> to grant permission, <b>false</b> to refuse to be added to the requester's buddy list.
 * @param	targetBuddy :	the username of the requester.
 * 
 * @see		addBuddy:
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyPermissionRequest: onBuddyPermissionRequest (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (void)sendBuddyPermissionResponse:(BOOL)allowBuddy targetBuddy:(NSString *)targetBuddy;

/**
 * Send a public message.
 * The message is broadcasted to all users in the current room, including the sender.
 * 
 * @param	message :	the text of the public message.
 * @param	roomId :		the id of the target room, in case of multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onPublicMessage
 * 
 * @see		sendPrivateMessage:recipientId:roomId:
 * @see		@link INFSmartFoxISFSEvents-p#onPublicMessage: onPublicMessage (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)sendPublicMessage:(NSString *)message roomId:(NSInteger)roomId;

/**
 * Send a private message to a user.
 * The message is broadcasted to the recipient and the sender.
 * 
 * @param	message :		the text of the private message.
 * @param	recipientId :	the id of the recipient user.
 * @param	roomId :			the id of the room from where the message is sent, in case of multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onPrivateMessage
 * 
 * @see		sendPublicMessage:roomId:
 * @see		@link INFSmartFoxISFSEvents-p#onPrivateMessage: onPrivateMessage (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)sendPrivateMessage:(NSString *)message recipientId:(NSInteger)recipientId roomId:(NSInteger)roomId;

/**
 * Send a Moderator message to the current zone, the current room or a specific user in the current room.
 * In order to send these kind of messages, the user must have Moderator's privileges, which are set by SmartFoxServer when the user logs in (see the @link INFSmartFoxiPhoneClient#login:name:pass: @endlink method).
 * 
 * @param	message :	the text of the message.
 * @param	type :		the type of message. The following constants can be passed: INFSMARTFOX_MODMSG_TO_USER, INFSMARTFOX_MODMSG_TO_ROOM and INFSMARTFOX_MODMSG_TO_ZONE, to send the message to a user, to the current room or to the entire current zone respectively.
 * @param	id :			the id of the recipient room or user (ignored if the message is sent to the zone).
 * 
 * @sends	SFSEvent#onModeratorMessage
 * 
 * @see		login:name:pass:
 * @see		INFSMARTFOXCLIENT_MODMSG_TO_USER
 * @see		INFSMARTFOXCLIENT_MODMSG_TO_ROOM
 * @see		INFSMARTFOXCLIENT_MODMSG_TO_ZONE
 * @see		@link INFSmartFoxISFSEvents-p#onModMessage: onModMessage (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.4.5
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)sendModeratorMessage:(NSString *)message type:(NSString *)type id:(NSInteger)id;

/**
 * Send an Actionscript object to the other users in the current room.
 * This method can be used to send complex/nested data structures to clients, like a game move or a game status change. Supported data types are: Strings, Booleans, Numbers, Arrays, Objects.
 * 
 * @param	obj :	the Actionscript object to be sent.
 * @param	roomId :	the id of the target room, in case of multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onObjectReceived
 * 
 * @see		sendObjectToGroup:userList:roomId:
 * @see		@link INFSmartFoxISFSEvents-p#onObjectReceived: onObjectReceived (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)sendObject:(NSDictionary *)obj roomId:(NSInteger)roomId;

/**
 * Send an Actionscript object to a group of users in the room.
 * See @link INFSmartFoxiPhoneClient#sendObject:roomId: sendObject @endlink for more info.
 * 
 * @param	obj :		the Actionscript object to be sent.
 * @param	userList :	an array containing the id(s) of the recipients.
 * @param	roomId :		the id of the target room, in case of multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onObjectReceived
 * 
 * @see		sendObject:roomId:
 * @see		@link INFSmartFoxISFSEvents-p#onObjectReceived: onObjectReceived (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)sendObjectToGroup:(NSMutableDictionary *)obj userList:(NSArray *)userList roomId:(NSInteger)roomId;

/**
 * Send a request to a server side extension.
 * The request can be serialized using three different protocols: XML, JSON and String-based (aka "raw protocol"). 
 * XML and JSON can both serialize complex objects with any level of nested properties, while the String protocol allows to send linear data delimited by a separator (see the @link INFSmartFoxiPhoneClient#rawProtocolSeparator rawProtocolSeperator @endlink property).
 * 
 * <b>NOTE</b>: the use JSON instead of XML is highly recommended, as it can save a lot of bandwidth. The String-based protocol can be very useful for realtime applications/games where reducing the amount of data is the highest priority.
 * 
 * @param	xtName :		the name of the extension (see also the @link INFSmartFoxiPhoneClient#createRoom:roomId: @endlink method).
 * @param	cmd :		the name of the action/command to execute in the extension.
 * @param	paramObj :	an object containing the data to be passed to the extension (set to empty object if no data is required).
 * @param	type :		the protocol to be used for serialization (optional). The following constants can be passed: INFSMARTFOX_XTMSG_TYPE_XML, INFSMARTFOX_XTMSG_TYPE_STR, INFSMARTFOX_XTMSG_TYPE_JSON.
 * @param	roomId :		the id of the room where the request was originated, in case of multi-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @see		rawProtocolSeparator
 * @see		INFSMARTFOXCLIENT_XTMSG_TYPE_XML
 * @see		INFSMARTFOXCLIENT_XTMSG_TYPE_JSON
 * @see		INFSMARTFOXCLIENT_XTMSG_TYPE_STR
 * @see		@link INFSmartFoxISFSEvents-p#onExtensionResponse: onExtensionResponse (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Pro
 */
- (void)sendXtMessage:(NSString *)xtName cmd:(NSString *)cmd paramObj:(NSDictionary *)paramObj type:(NSString *)type roomId:(NSInteger)roomId;

/**
 * Block or unblock a user in the buddy list.
 * When a buddy is blocked, SmartFoxServer does not deliver private messages from/to that user.
 * 
 * @param	buddyName :	the name of the buddy to be blocked or unblocked.
 * @param	status :		<b>true</b> to block the buddy, <b>false</b> to unblock the buddy.
 * 
 * @see		_buddyList
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */
- (void)setBuddyBlockStatus:(NSString *)buddyName status:(BOOL)status;

/**
 * Set the current user's Buddy Variables.
 * This method allows to set a number of properties of the current user as buddy of other users; in other words these variables will be received by the other users who have the current user as a buddy.
 * 
 * Buddy Variables are the best way to share user's informations with all the other users having him/her in their buddy list.: for example the nickname, the current audio track the user is listening to, etc. The most typical usage is to set a variable containing the current user status, like "available", "occupied", "away", "invisible", etc.).
 * 
 * <b>NOTE</b>: before the release of SmartFoxServer Pro v1.6.0, Buddy Variables could not be stored, and existed during the user session only. SmartFoxServer Pro v1.6.0 introduced the ability to persist (store) all Buddy Variables and the possibility to save "offline Buddy Variables" (see the following usage notes).
 * 
 * @usageNote	Let's assume that three users (A, B and C) use an "istant messenger"-like application, and user A is part of the buddy lists of users B and C.
 * 				If user A sets his own variables (using the @link INFSmartFoxiPhoneClient#setBuddyVariables: setBuddyVariables @endlink method), the @link INFSmartFoxiPhoneClient#_myBuddyVars myBuddyVars @endlink array on his client gets populated and a @link INFSmartFoxISFSEvents-p#onBuddyListUpdate: onBuddyListUpdate (INFSmartFoxISFSEvents) @endlink event is dispatched to users B and C.
 * 				User B and C can then read those variables in their own buddy lists by means of the <b>variables</b> property on the buddy object (which can be retrieved from the @link INFSmartFoxiPhoneClient#_buddyList buddyList @endlink array by means of the @link INFSmartFoxiPhoneClient#getBuddyById: getBuddyById @endlink or @link INFSmartFoxiPhoneClient#getBuddyByName: getBuddyByName @endlink methods).
 * 				<hr />
 * 				If the buddy list's <i>advanced security mode</i> is used (see the SmartFoxServer server-side configuration), Buddy Variables persistence is enabled: in this way regular variables are saved when a user goes offline and they are restored (and dispatched to the other users) when their owner comes back online.
 * 				Also, setting the <b><offLineBuddyVariables></b> parameter to <b>true</b>, offline variables can be used: this kind of Buddy Variables is loaded regardless the buddy is online or not, providing further informations for each entry in the buddy list. A typical usage for offline variables is to define a buddy image or additional informations such as country, email, rank, etc.
 * 				To creare an offline Buddy Variable, the "$" character must be placed before the variable name.
 * 
 * @param	varList :	an associative array, where the key is the name of the variable and the value is the variable's value. Buddy Variables should all be strings. If you need to use other data types you should apply the appropriate type casts.
 * 
 * @sends	SFSEvent#onBuddyListUpdate
 * 
 * @see		_myBuddyVars
 * @see		@link INFSmartFoxISFSEvents-p#onBuddyListUpdate: onBuddyListUpdate (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @history	SmartFoxServer Pro v1.6.0 - Buddy list's <i>advanced security mode</i> implemented (persistent and offline Buddy Variables).
 * 
 * @version	SmartFoxServer Basic (except <i>advanced mode</i>) / Pro
 */
- (void)setBuddyVariables:(NSDictionary *)varList;

/**
 * Set one or more Room Variables.
 * Room Variables are a useful feature to share data across the clients, keeping it in a centralized place on the server. When a user sets/updates/deletes one or more Room Variables, all the other users in the same room are notified. 
 * Allowed data types for Room Variables are Numbers, Strings and Booleans; in order save bandwidth, Arrays and Objects are not supported. Nevertheless, an array of values can be simulated, for example, by using an index in front of the name of each variable (check one of the following examples).
 * If a Room Variable is set to <b>null</b>, it is deleted from the server.
 * 
 * @param	varList :		an array of objects with the properties described farther on.
 * @param	roomId :			the id of the room where the variables should be set, in case of molti-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * @param	setOwnership :	<b>false</b> to prevent the Room Variable change ownership when its value is modified by another user (optional).
 * 
 * <hr />
 * Each Room Variable is an object containing the following properties:
 * @param	name :		(<b>String</b>) the variable name.
 * @param	val :		(<b>*</b>) the variable value.
 * @param	priv :		(<b>Boolean</b>) if <b>true</b>, the variable can be modified by its creator only (optional, default value: <b>false</b>).
 * @param	persistent :	(<b>Boolean</b>) if <b>true</b>, the variable will exist until its creator is connected to the current zone; if <b>false</b>, the variable will exist until its creator is connected to the current room (optional, default value: <b>false</b>).
 * 
 * @sends	SFSEvent#onRoomVariablesUpdate
 * 
 * @see		INFSmartFoxRoom#getVariable:
 * @see		INFSmartFoxRoom#getVariables
 * @see		@link INFSmartFoxISFSEvents-p#onRoomVariablesUpdate: onRoomVariablesUpdate (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)setRoomVariables:(NSArray *)varList roomId:(NSInteger)roomId setOwnership:(BOOL)setOwnership;

/**
 * Set on or more User Variables.
 * User Variables are a useful tool to store user data that has to be shared with other users. When a user sets/updates/deletes one or more User Variables, all the other users in the same room are notified. 
 * Allowed data types for User Variables are Numbers, Strings and Booleans; Arrays and Objects are not supported in order save bandwidth.
 * If a User Variable is set to <b>null</b>, it is deleted from the server. Also, User Variables are destroyed when their owner logs out or gets disconnected.
 * 
 * @param	varObj :		an object in which each property is a variable to set/update.
 * @param	roomId :		the room id where the request was originated, in case of molti-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onUserVariablesUpdate
 * 
 * @see		INFSmartFoxUser#getVariable:
 * @see		INFSmartFoxUser#getVariables
 * @see		@link INFSmartFoxISFSEvents-p#onUserVariablesUpdate: onUserVariablesUpdate (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)setUserVariables:(NSDictionary *)varObj roomId:(NSInteger)roomId;

/**
 * Turn a spectator inside a game room into a player. 
 * All spectators have their <b>player id</b> property set to -1; when a spectator becomes a player, his player id gets a number > 0, representing the player number. The player id values are assigned by the server, based on the order in which the players joined the room.
 * If the user joined more than one room, the id of the room where the switch should occurr must be passed to this method.
 * The switch operation is successful only if at least one player slot is available in the room.
 * 
 * @param	roomId :	the id of the room where the spectator should be switched, in case of molti-room join (optional, default value: @link INFSmartFoxiPhoneClient#_activeRoomId activeRoomId @endlink).
 * 
 * @sends	SFSEvent#onSpectatorSwitched
 * 
 * @see		INFSmartFoxUser#isSpectator
 * @see		@link INFSmartFoxISFSEvents-p#onSpectatorSwitched: onSpectatorSwitched (INFSmartFoxISFSEvents) @endlink
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)switchSpectator:(NSInteger)roomId;

- (void)__logout;
- (void)sendString:(NSString *)strMessage;
- (void)sendJSON:(NSString *)jsonMessage;
- (NSInteger)getBenchStartTime;
- (void)clearRoomList;

@end
