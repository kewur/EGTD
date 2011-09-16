//
//  INFSmartFoxISFSEvents.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

@class INFSmartFoxSFSEvent;

@protocol INFSmartFoxISFSEvents <NSObject>

@optional

/**
 * Dispatched when a message from the Administrator is received.
 * Admin messages are special messages that can be sent by an Administrator to a user or group of users.
 * All client applications should handle this event, or users won't be be able to receive important admin notifications!
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the Administrator's message.
 * 
 * @see		onModMessage:
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)onAdminMessage:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the buddy list for the current user is received or a buddy is added/removed.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	list :	(<b>Array</b>) the buddy list. Refer to the @link INFSmartFoxiPhoneClient#_buddyList buddyList (INFSmartFoxiPhoneClient) @endlink property for a description of the buddy object's properties.
 * 
 * @see		onBuddyListError:
 * @see		onBuddyListUpdate:
 * @see		onBuddyRoom:
 * @see		INFSmartFoxiPhoneClient#_buddyList
 * @see		INFSmartFoxiPhoneClient#loadBuddyList
 * @see		INFSmartFoxiPhoneClient#addBuddy:
 * @see		INFSmartFoxiPhoneClient#removeBuddy:
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)onBuddyList:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when an error occurs while loading the buddy list.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	error :	(<b>String</b>) the error message.
 * 
 * @see		onBuddyList:
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (void)onBuddyListError:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the status or variables of a buddy in the buddy list change.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	buddy :	(<b>Object</b>) an object representing the buddy whose status or Buddy Variables have changed. Refer to the @link INFSmartFoxiPhoneClient#_buddyList buddyList (INFSmartFoxiPhoneClient) @endlink property for a description of the buddy object's properties.
 * 
 * @see		onBuddyList:
 * @see		INFSmartFoxiPhoneClient#_buddyList
 * @see		INFSmartFoxiPhoneClient#setBuddyBlockStatus:status:
 * @see		INFSmartFoxiPhoneClient#setBuddyVariables:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onBuddyListUpdate:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the current user receives a request to be added to the buddy list of another user.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	sender :		(<b>String</b>) the name of the user requesting to add the current user to his/her buddy list.
 * @param	message :	(<b>String</b>) a message accompaining the permission request. This message can't be sent from the client-side, but it's part of the advanced server-side buddy list features.
 * 
 * @see		INFSmartFoxiPhoneClient#addBuddy:
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */	
- (void)onBuddyPermissionRequest:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched in response to a @link INFSmartFoxiPhoneClient#getBuddyRoom: getBuddyRoom (INFSmartFoxiPhoneClient) @endlink request.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	idList :	(<b>Array</b>) the list of id of the rooms in which the buddy is currently logged; if users can't be present in more than one room at the same time, the list will contain one room id only, at 0 index.
 * 
 * @see		INFSmartFoxiPhoneClient#getBuddyRoom:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onBuddyRoom:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when an error occurs while loading the external SmartFoxClient configuration file.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the error message.
 * 
 * @see		onConfigLoadSuccess:
 * @see		INFSmartFoxiPhoneClient#loadConfig:autoConnect:
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */	
- (void)onConfigLoadFailure:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the external SmartFoxClient configuration file has been loaded successfully.
 * This event is dispatched only if the <i>autoConnect</i> parameter of the @link INFSmartFoxiPhoneClient#loadConfig:autoConnect: loadConfig (INFSmartFoxiPhoneClient) @endlink method is set to <b>true</b>; otherwise the connection is made and the @link INFSmartFoxISFSEvents-p#onConnection: onConnection @endlink event fired.
 * 
 * No parameters are provided.
 * 
 * @see		onConfigLoadFailure:
 * @see		INFSmartFoxiPhoneClient#loadConfig:autoConnect:
 * 
 * @since	SmartFoxServer Pro v1.6.0
 * 
 * @version	SmartFoxServer Pro
 */	
- (void)onConfigLoadSuccess:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched in response to the @link INFSmartFoxiPhoneClient#connect:port: connect (INFSmartFoxiPhoneClient) @endlink request.
 * The connection to SmartFoxServer may have succeeded or failed: the <i>success</i> parameter must be checked.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	success :	(<b>Boolean</b>) the connection result: <b>true</b> if the connection succeeded, <b>false</b> if the connection failed.
 * @param	error :		(<b>String</b>) the error message in case of connection failure.
 * 
 * @see		INFSmartFoxiPhoneClient#connect:port:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onConnection:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the connection with SmartFoxServer is closed (either from the client or from the server).
 * 
 * No parameters are provided.
 * 
 * @see		INFSmartFoxiPhoneClient#disconnect
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onConnectionLost:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when an error occurs during the creation of a room.
 * Usually this happens when a client tries to create a room but its name is already taken.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	error :	(<b>String</b>) the error message.
 * 
 * @see		INFSmartFoxiPhoneClient#createRoom:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onCreateRoomError:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a debug message is traced by the SmartFoxServer API.
 * In order to receive this event you have to previously set the @link INFSmartFoxiPhoneClient#_debug debug (INFSmartFoxiPhoneClient) @endlink flag to <b>true</b>.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the debug message.
 * 
 * @see		INFSmartFoxiPhoneClient#_debug
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onDebugMessage:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a command/response from a server-side extension is received.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	dataObj :	(<b>Object</b>) an object containing all the data sent by the server-side extension; by convention, a String property called <b>_cmd</b> should always be present, to distinguish between different responses coming from the same extension.
 * @param	type :		(<b>String</b>) one of the following response protocol types: @link INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_XML INFSMARTFOXCLIENT_XTMSG_TYPE_XML (INFSmartFoxiPhoneClient) @endlink, @link INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_STR INFSMARTFOXCLIENT_XTMSG_TYPE_STR (INFSmartFoxiPhoneClient) @endlink, @link INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_JSON INFSMARTFOXCLIENT_XTMSG_TYPE_JSON (INFSmartFoxiPhoneClient) @endlink. By default @link INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_XML INFSMARTFOXCLIENT_XTMSG_TYPE_XML (INFSmartFoxiPhoneClient) @endlink is used.
 * 
 * @see		INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_XML
 * @see		INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_STR
 * @see		INFSmartFoxiPhoneClient#INFSMARTFOXCLIENT_XTMSG_TYPE_JSON
 * @see		INFSmartFoxiPhoneClient#sendXtMessage:cmd:paramObj:type:roomId:
 * 
 * @version	SmartFoxServer Pro
 */	
- (void)onExtensionResponse:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a room is joined successfully.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	room :	(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the joined room.
 * 
 * @see		onJoinRoomError:
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#joinRoom:pword:isSpectator:dontLeave:oldRoom:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onJoinRoom:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when an error occurs while joining a room.
 * This error could happen, for example, if the user is trying to join a room which is currently full.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	error :	(<b>String</b>) the error message.
 * 
 * @see		onJoinRoom:
 * @see		INFSmartFoxiPhoneClient#joinRoom:pword:isSpectator:dontLeave:oldRoom:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onJoinRoomError:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the login to a SmartFoxServer zone has been attempted.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	success :	(<b>Boolean</b>) the login result: <b>true</b> if the login to the provided zone succeeded; <b>false</b> if login failed.
 * @param	name :		(<b>String</b>) the user's actual username.
 * @param	error :		(<b>String</b>) the error message in case of login failure.
 * 
 * <b>NOTE</b>: the server sends the username back to the client because not all usernames are valid: for example, those containing bad words may have been filtered during the login process.
 * 
 * @see		onLogout:
 * @see		INFSmartFoxiPhoneClient#login:name:pass:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onLogin:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the user logs out successfully.
 * After a successful logout the user is still connected to the server, but he/she has to login again into a zone, in order to be able to interact with the server.
 * 
 * No parameters are provided.
 * 
 * @see		onLogin:
 * @see		INFSmartFoxiPhoneClient#logout
 * 
 * @since	SmartFoxServer Pro v1.5.5
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onLogout:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a message from a Moderator is received.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the Moderator's message.
 * @param	sender :		(<b>User</b>) the {@link INFSmartFoxUser} object representing the Moderator.
 * 
 * @see		onAdminMessage:
 * @see		INFSmartFoxUser
 * @see		INFSmartFoxiPhoneClient#sendModeratorMessage:type:id:
 * 
 * @since	SmartFoxServer Pro v1.4.5
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onModMessage:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when an Actionscript object is received.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	obj :	(<b>Object</b>) the Actionscript object received.
 * @param	sender :	(<b>User</b>) the {@link INFSmartFoxUser} object representing the user that sent the Actionscript object.
 * 
 * @see		INFSmartFoxUser
 * @see		INFSmartFoxiPhoneClient#sendObject:roomId:
 * @see		INFSmartFoxiPhoneClient#sendObjectToGroup:userList:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onObjectReceived:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a private chat message is received.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the private message received.
 * @param	sender :		(<b>User</b>) the {@link INFSmartFoxUser} object representing the user that sent the message; this property is undefined if the sender isn't in the same room of the recipient.
 * @param	roomId :		(<b>int</b>) the id of the room where the sender is.
 * @param	userId :		(<b>int</b>) the user id of the sender (useful in case of private messages across different rooms, when the <b>sender</b> object is not available).
 * 
 * @see		onPublicMessage:
 * @see		INFSmartFoxUser
 * @see		INFSmartFoxiPhoneClient#sendPrivateMessage:recipientId:roomId:
 * 
 * @history	SmartFoxServer Pro v1.5.0 - <i>roomId</i> and <i>userId</i> parameters added.
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onPrivateMessage:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a public chat message is received.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	message :	(<b>String</b>) the public message received.
 * @param	sender :		(<b>User</b>) the {@link INFSmartFoxUser} object representing the user that sent the message.
 * @param	roomId :		(<b>int</b>) the id of the room where the sender is.
 * 
 * @see		onPrivateMessage:
 * @see		INFSmartFoxUser
 * @see		INFSmartFoxiPhoneClient#sendPublicMessage:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onPublicMessage:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched in response to a @link INFSmartFoxiPhoneClient#getRandomKey getRandomKey (INFSmartFoxiPhoneClient) @endlink request.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	key :	(<b>String</b>) a unique random key generated by the server.
 * 
 * @see		INFSmartFoxiPhoneClient#getRandomKey
 * 
 * @version	SmartFoxServer Pro
 */	
- (void)onRandomKey:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a new room is created in the zone where the user is currently logged in.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	room :	(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the room that was created.
 * 
 * @see		onRoomDeleted:
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#createRoom:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoomAdded:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a room is removed from the zone where the user is currently logged in.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	room :	(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the room that was removed.
 * 
 * @see		onRoomAdded:
 * @see		INFSmartFoxRoom
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoomDeleted:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a room is left in multi-room mode, in response of a @link INFSmartFoxiPhoneClient#leaveRoom: leaveRoom (INFSmartFoxiPhoneClient) @endlink request.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	roomId :	(<b>int</b>) the id of the room that was left.
 * 
 * @see		INFSmartFoxiPhoneClient#leaveRoom:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoomLeft:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the list of rooms available in the current zone is received.
 * If the default login mechanism provided by SmartFoxServer is used, then this event is dispatched right after a successful login.
 * This is because the SmartFoxServer API, internally, call the @link INFSmartFoxiPhoneClient#getRoomList getRoomList (INFSmartFoxiPhoneClient) @endlink method after a successful login is performed.
 * If a custom login handler is implemented, the room list must be manually requested to the server by calling the mentioned method.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	roomList :	(<b>Array</b>) a list of {@link INFSmartFoxRoom} objects for the zone logged in by the user.
 * 
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#getRoomList
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoomListUpdate:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when Room Variables are updated.
 * A user receives this notification only from the room(s) where he/she is currently logged in. Also, only the variables that changed are transmitted.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	room :			(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the room where the update took place.
 * @param	changedVars :	(<b>Array</b>) an associative array with the names of the changed variables as keys. The array can also be iterated through numeric indexes (0 to <b>changedVars.length</b>) to get the names of the variables that changed.
 * <hr />
 * <b>NOTE</b>: the <b>changedVars</b> array contains the names of the changed variables only, not the actual values. To retrieve them the @link INFSmartFoxRoom#getVariable: getVariable @endlink / @link INFSmartFoxRoom#getVariables getVariables @endlink methods can be used.
 * 
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#setRoomVariables:roomId:setOwnership:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoomVariablesUpdate:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a response to the @link INFSmartFoxiPhoneClient#roundTripBench roundTripBench (INFSmartFoxiPhoneClient) @endlink request is received.
 * The "roundtrip time" represents the number of milliseconds that it takes to a message to go from the client to the server and back to the client.
 * A good way to measure the network lag is to send continuos requests (every 3 or 5 seconds) and then calculate the average roundtrip time on a fixed number of responses (i.e. the last 10 measurements).
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	elapsed :	(<b>int</b>) the roundtrip time.
 * 
 * @see		INFSmartFoxiPhoneClient#roundTripBench
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onRoundTripResponse:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched in response to the @link INFSmartFoxiPhoneClient#switchSpectator: switchSpectator (INFSmartFoxiPhoneClient) @endlink request.
 * The request to turn a spectator into a player may fail if another user did the same before your request, and there was only one player slot available.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	success :	(<b>Boolean</b>) the switch result: <b>true</b> if the spectator was turned into a player, otherwise <b>false</b>.
 * @param	newId :		(<b>int</b>) the player id assigned by the server to the user.
 * @param	room :		(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the room where the switch occurred.
 * 
 * @see		INFSmartFoxUser#getPlayerId
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#switchSpectator:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onSpectatorSwitched:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when the number of users and/or spectators changes in a room within the current zone.
 * This event allows to keep track in realtime of the status of all the zone rooms in terms of users and spectators.
 * In case many rooms are used and the zone handles a medium to high traffic, this notification can be turned off to reduce bandwidth consumption, since a message is broadcasted to all users in the zone each time a user enters or exits a room.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	room :	(<b>Room</b>) the {@link INFSmartFoxRoom} object representing the room where the change occurred.
 * 
 * @see		onUserEnterRoom:
 * @see		onUserLeaveRoom:
 * @see		INFSmartFoxRoom
 * @see		INFSmartFoxiPhoneClient#createRoom:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onUserCountChange:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when another user joins the current room.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	roomId :	(<b>int</b>) the id of the room joined by a user (useful in case multi-room presence is allowed).
 * @param	user :	(<b>User</b>) the {@link INFSmartFoxUser} object representing the user that joined the room.
 * 
 * @see		onUserLeaveRoom:
 * @see		onUserCountChange:
 * @see		INFSmartFoxUser
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onUserEnterRoom:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a user leaves the current room.
 * This event is also dispatched when a user gets disconnected from the server.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	roomId :		(<b>int</b>) the id of the room left by a user (useful in case multi-room presence is allowed).
 * @param	userId :		(<b>int</b>) the id of the user that left the room (or got disconnected).
 * @param	userName :	(<b>String</b>) the name of the user.
 * 
 * @see		onUserEnterRoom:
 * @see		onUserCountChange:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onUserLeaveRoom:(INFSmartFoxSFSEvent *)evt;

/**
 * Dispatched when a user in the current room updates his/her User Variables.
 * 
 * The @link INFSmartFoxSFSEvent#_params params @endlink object contains the following parameters.
 * @param	user :			(<b>User</b>) the {@link INFSmartFoxUser} object representing the user who updated his/her variables.
 * @param	changedVars :	(<b>Array</b>) an associative array with the names of the changed variables as keys. The array can also be iterated through numeric indexes (0 to <b>changedVars.length</b>) to get the names of the variables that changed.
 * <hr />
 * <b>NOTE</b>: the <b>changedVars</b> array contains the names of the changed variables only, not the actual values. To retrieve them the @link INFSmartFoxUser#getVariable: getVariable @endlink / @link INFSmartFoxUser#getVariables getVariables @endlink methods can be used.
 * 
 * @see		INFSmartFoxUser
 * @see		INFSmartFoxiPhoneClient#setUserVariables:roomId:
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (void)onUserVariablesUpdate:(INFSmartFoxSFSEvent *)evt;

- (void)onIOError:(INFSmartFoxSFSEvent *)evt;

@end
