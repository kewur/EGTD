//
//  INFSmartFoxSysHandler.m
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxSysHandler.h"
#import "INFSmartFoxSFSEvent.h"
#import "INFSmartFoxiPhoneClient.h"
#import "INFSmartFoxRoom.h"
#import "INFSmartFoxUser.h"
#import "INFSmartFoxEntities.h"
#import "INFSmartFoxObjectSerializer.h"
#import "INFSmartFoxRoomCreateParams.h"
#import "INFSmartFoxBuddy.h"
#import "TouchXML.h"

@implementation INFSmartFoxSysHandler

/**
 * Takes an SFS variables XML node and store it in an array
 * Usage: for parsing room and user variables
 * 
 * @xmlData	 	xmlData		the XML variables node
 */	
- (void)populateVariables:(NSMutableDictionary *)variables xmlData:(NSArray *)xmlData changedVars:(NSMutableSet *)changedVars
{		
	NSError *error;
	
	for (CXMLElement *v in xmlData) {	
		NSArray *vNameA = [v nodesForXPath:@"./@n" error:&error];
		NSArray *vTypeA = [v nodesForXPath:@"./@t" error:&error];
		
		NSString *vName = [[vNameA objectAtIndex:0] stringValue];
		NSString *vType = [[vTypeA objectAtIndex:0] stringValue];
		NSString *vValue = [v stringValue];
					
		// Add the vName to the list of changed vars
		// The changed List is an array that can contains all the
		// var names changed with numeric indexes but also contains
		// the var names as keys for faster search
		if (changedVars != nil)	{
			[changedVars addObject:vName];
		}
		
		if ([vType isEqualToString:@"b"]) {
			[variables setObject:[NSNumber numberWithBool:[vValue isEqualToString:@"1"] ? YES : NO] forKey:vName];
		}
		else if ([vType isEqualToString:@"n"]) {
			if ([vValue rangeOfString:@"."].location != NSNotFound) {
				[variables setObject:[NSNumber numberWithFloat:[vValue floatValue]] forKey:vName];
			}
			else {
				[variables setObject:[NSNumber numberWithInt:[vValue intValue]] forKey:vName];
			}
		}			
		else if ([vType isEqualToString:@"s"]) {
			[variables setObject:vValue forKey:vName];
		}
		else if ([vType isEqualToString:@"x"]) {
			[variables setValue:nil forKey:vName];
		}
	}	
}

+ (id)sysHandler:(INFSmartFoxiPhoneClient *)sfs
{
	INFSmartFoxSysHandler *obj = [INFSmartFoxSysHandler alloc];
	return [[obj initWithParams:sfs] autorelease];
}

- (id)initWithParams:(INFSmartFoxiPhoneClient *)sfs
{
	[sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:initWithParams sfs:%@", sfs]];
	
	self = [super init];
	if (self) {
		_sfs = sfs;
		_handlersTable = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
						  @"handleApiOK:", @"apiOK",
						  @"handleApiKO:", @"apiKO",
						  @"handleLoginOk:", @"logOK",
						  @"handleLoginKo:", @"logKO",
						  @"handleLogout:", @"logout",
						  @"handleRoomList:", @"rmList",
						  @"handleUserCountChange:", @"uCount",
						  @"handleJoinOk:", @"joinOK",
						  @"handleJoinKo:", @"joinKO",
						  @"handleUserEnterRoom:" ,@"uER",
						  @"handleUserLeaveRoom:", @"userGone",
						  @"handlePublicMessage:", @"pubMsg",
						  @"handlePrivateMessage:", @"prvMsg",
						  @"handleAdminMessage:", @"dmnMsg",
						  @"handleModMessage:", @"modMsg",
						  @"handleASObject:", @"dataObj",
						  @"handleRoomVarsUpdate:", @"rVarsUpdate",
						  @"handleRoomAdded:", @"roomAdd",
						  @"handleRoomDeleted:", @"roomDel",
						  @"handleRandomKey:", @"rndK",
						  @"handleRoundTripBench:", @"roundTripRes",
						  @"handleUserVarsUpdate:", @"uVarsUpdate",
						  @"handleCreateRoomError:", @"createRmKO",
						  @"handleBuddyList:", @"bList",
						  @"handleBuddyListUpdate:", @"bUpd",
						  @"handleBuddyAdded:", @"bAdd",
						  @"handleBuddyRoom:", @"roomB",
						  @"handleLeaveRoom:", @"leaveRoom:",
						  @"handleSpectatorSwitched:", @"swSpec",
						  @"handleAddBuddyPermission:", @"bPrm",
						  @"handleRemoveBuddy:", @"remB",
						  nil] retain];
	}
	
	return self;
}

- (void)handleMessage:(id)msgObj type:(NSString *)type delegate:(id <INFSmartFoxISFSEvents>)delegate
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleMessage msgObj:%@", msgObj]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:msgObj options:0 error:&error];
	NSArray *nodes = [doc nodesForXPath:@"./msg/body/@action" error:&error];
	
	if ([nodes count] > 0) {
		CXMLElement *action = [nodes objectAtIndex:0];
		
		if ([_handlersTable objectForKey:[action stringValue]]) {
			[self performSelector:NSSelectorFromString([_handlersTable objectForKey:[action stringValue]]) withObject:msgObj];
		}
		else {
			[_sfs debugMessage:[NSString stringWithFormat:@"No handlers found for action:%@", [action stringValue]]];
		}
	}
	
	[doc release];
}

// Handle correct API
- (void)handleApiOK:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleApiOK"]];
	
	_sfs.isConnected = YES;
	
	if ([_sfs.delegate respondsToSelector:@selector(onConnection:)]) {
		[_sfs.delegate onConnection:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																   [NSNumber numberWithBool:TRUE], @"success",
																   nil]]];
	}
}

// Handle obsolete API
- (void)handleApiKO:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleApiKO"]];
		
	if ([_sfs.delegate respondsToSelector:@selector(onConnection:)]) {
		[_sfs.delegate onConnection:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																   [NSNumber numberWithBool:FALSE], @"success",
																   @"API are obsolete, please upgrade", @"error",
																   nil]]];
	}
}

// Handle successfull login
- (void)handleLoginOk:(id)o
{		
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleLoginOk"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSArray *loginA = [doc nodesForXPath:@"./msg/body/login" error:&error];
	
	if ([loginA count] > 0) {
		CXMLElement *loginNode = [loginA objectAtIndex:0];
		
		NSArray *userIdA = [loginNode nodesForXPath:@"./@id" error:&error];
		NSArray *modA = [loginNode nodesForXPath:@"./@mod" error:&error];
		NSArray *nameA = [loginNode nodesForXPath:@"./@n" error:&error];
		
		NSInteger uid = [[[userIdA objectAtIndex:0] stringValue] integerValue];
		NSInteger mod = [[[modA objectAtIndex:0] stringValue] integerValue];
		NSString *name = [[nameA objectAtIndex:0] stringValue];
		
		_sfs.amIModerator = (mod == 1) ? YES : NO;
		_sfs.myUserId = uid;
		_sfs.myUserName = name;
		_sfs.playerId = -1;
		
		if ([_sfs.delegate respondsToSelector:@selector(onLogin:)]) {
			[_sfs.delegate onLogin:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																  [NSNumber numberWithBool:YES], @"success",
																  name, @"name",
																  @"", @"error",
																  nil]]];
		}
		
		// Request room list
		[_sfs getRoomList];
	}
	
	[doc release];		
}

// Handle failed login attempt
- (void)handleLoginKo:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleLoginKo"]];
				
	if ([_sfs.delegate respondsToSelector:@selector(onLogin:)]) {
		NSError *error;
		CXMLDocument *doc;
		
		doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
		NSArray *loginA = [doc nodesForXPath:@"./msg/body/login/@e" error:&error];
		
		[_sfs.delegate onLogin:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
															  [NSNumber numberWithBool:FALSE], @"success",
															  [[loginA objectAtIndex:0] stringValue], @"error",
															  nil]]];
		
		[doc release];
	}
}

// Handle successful logout
- (void)handleLogout:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleLogout"]];
	
	[_sfs __logout];
	
	if ([_sfs.delegate respondsToSelector:@selector(onLogout:)]) {
		[_sfs.delegate onLogout:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];
	}
}

// Populate the room list for this zone and fire the event
- (void)handleRoomList:(id)o
{		
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRoomList"]];
	
	NSMutableDictionary *roomListTemp;
	
	roomListTemp = [NSMutableDictionary dictionary];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSArray *nodes = [doc nodesForXPath:@"./msg/body/rmList/rm" error:&error];
	
	for (CXMLElement *roomNode in nodes) {
		NSArray *roomIdA = [roomNode nodesForXPath:@"./@id" error:&error];
		NSArray *roomNameA = [roomNode nodesForXPath:@"./n" error:&error];
		NSArray *roomMaxuA = [roomNode nodesForXPath:@"./@maxu" error:&error];
		NSArray *roomMaxsA = [roomNode nodesForXPath:@"./@maxs" error:&error];
		NSArray *roomTempA = [roomNode nodesForXPath:@"./@temp" error:&error];
		NSArray *roomGameA = [roomNode nodesForXPath:@"./@game" error:&error];
		NSArray *roomPrivA = [roomNode nodesForXPath:@"./@priv" error:&error];
		NSArray *roomLmbA = [roomNode nodesForXPath:@"./@lmb" error:&error];
		NSArray *roomUcntA = [roomNode nodesForXPath:@"./@ucnt" error:&error];
		NSArray *roomScntA = [roomNode nodesForXPath:@"./@scnt" error:&error];
		
		NSInteger roomId = [[[roomIdA objectAtIndex:0] stringValue] integerValue];
		NSString *roomName = [[roomNameA objectAtIndex:0] stringValue];
		NSInteger roomMaxu = [[[roomMaxuA objectAtIndex:0] stringValue] integerValue];
		NSInteger roomMaxs = [[[roomMaxsA objectAtIndex:0] stringValue] integerValue];
		BOOL roomTemp = [[[roomTempA objectAtIndex:0] stringValue] boolValue];
		BOOL roomGame = [[[roomGameA objectAtIndex:0] stringValue] boolValue];
		BOOL roomPriv = [[[roomPrivA objectAtIndex:0] stringValue] boolValue];
		
		BOOL roomLmb = NO;
		if ([roomLmbA count] > 0) {	
			roomLmb = [[[roomLmbA objectAtIndex:0] stringValue] boolValue];
		}
		
		NSInteger roomUcnt = [[[roomUcntA objectAtIndex:0] stringValue] integerValue];
		
		NSInteger roomScnt = 0;
		if ([roomScntA count] > 0) {
			roomScnt = [[[roomScntA objectAtIndex:0] stringValue] integerValue];
		}
		
		INFSmartFoxRoom *room;
		
		room = [INFSmartFoxRoom room:roomId name:roomName maxUsers:roomMaxu maxSpectators:roomMaxs isTemp:roomTemp isGame:roomGame isPrivate:roomPriv isLimbo:roomLmb userCount:roomUcnt specCount:roomScnt];
		
		// Handle Room Variables		
		NSArray *roomVarsA = [roomNode nodesForXPath:@"./vars/var" error:&error];
		if ([roomVarsA count] > 0) {
			[self populateVariables:[room getVariables] xmlData:roomVarsA changedVars:nil];
		}
		
		/*
		 * Merge with the current list data, to avoid destroying previous data
		 */
		INFSmartFoxRoom *oldRoom = [[_sfs getAllRooms] objectForKey:[NSNumber numberWithInt:roomId]];
		
		if (oldRoom != NULL) {
			[room setVariables:[oldRoom getVariables]];
			[room setUserList:[oldRoom getUserList]];
		}
		
		// Add room
		[roomListTemp setObject:room forKey:[NSNumber numberWithInt:roomId]];
	}
	
	[_sfs setRoomList:roomListTemp];
	
	if ([_sfs.delegate respondsToSelector:@selector(onRoomListUpdate:)]) {		
		[_sfs.delegate onRoomListUpdate:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	   [_sfs getAllRooms], @"roomList",
																	   nil]]];			
	}
	
		
	[doc release];
}

// Handle the user count change in a room
- (void)handleUserCountChange:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleUserCountChange"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger uCount = [[[[doc nodesForXPath:@"./msg/body/@u" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSArray *sCountA = [doc nodesForXPath:@"./msg/body/@s" error:&error];
	
	NSInteger sCount = 0;
	if ([sCountA count] > 0) {
		sCount = [[[sCountA objectAtIndex:0] stringValue] integerValue];
	}
	
	[doc release];
	
	INFSmartFoxRoom *room = [_sfs getRoom:roomId];
	
	if (room != nil) {
		[room setUserCount:uCount];
		[room setSpectatorCount:sCount];
		
		if ([_sfs.delegate respondsToSelector:@selector(onUserCountChange:)]) {
			[_sfs.delegate onUserCountChange:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			room, @"room",
																			nil]]];
		}
	}
}

// Successfull room Join
- (void)handleJoinOk:(id)o
{		
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleJoinOk"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	CXMLElement *bodyNode = [[doc nodesForXPath:@"./msg/body" error:&error] objectAtIndex:0];
	NSInteger roomId = [[[[bodyNode nodesForXPath:@"./@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger playerId = [[[[bodyNode nodesForXPath:@"./pid/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	
	// Set current active room
	_sfs.activeRoomId = roomId;
	
	INFSmartFoxRoom *currRoom;
	
	// get current Room and populates usrList
	currRoom = [_sfs getRoom:roomId];
	
	// Clear the old data, we need to start from a clean list
	[currRoom clearUserList];
	
	// Set the player ID
	// -1 = no game room
	_sfs.playerId = playerId;
	
	// Also set the myPlayerId in the room
	// for multi-room applications
	[currRoom setMyPlayerIndex:playerId];
	
	// Handle Room Variables
	NSArray *roomVarsA = [bodyNode nodesForXPath:@"./vars/var" error:&error];
	if ([roomVarsA count] > 0) {
		[currRoom clearVariables];
		[self populateVariables:[currRoom getVariables] xmlData:roomVarsA changedVars:nil];
	}
	
	// Populate Room userList
	for (CXMLElement *userNode in [bodyNode nodesForXPath:@"./uLs/u" error:&error]) {
		// grab the user properties
		NSArray *nameA = [userNode nodesForXPath:@"./n" error:&error];
		NSArray *idA = [userNode nodesForXPath:@"./@i" error:&error];
		NSArray *isModA = [userNode nodesForXPath:@"./@m" error:&error];
		NSArray *isSpecA = [userNode nodesForXPath:@"./@s" error:&error];
		NSArray *pidA = [userNode nodesForXPath:@"./@p" error:&error];
		
		NSString *name = [[nameA objectAtIndex:0] stringValue];
		NSInteger uid = [[[idA objectAtIndex:0] stringValue] integerValue];
		BOOL isMod = [[[isModA objectAtIndex:0] stringValue] boolValue];
		
		BOOL isSpec = NO;
		if ([isSpecA count] > 0) {	
			isSpec = [[[isSpecA objectAtIndex:0] stringValue] boolValue];
		}
		
		NSInteger pid = -1;
		if ([pidA count] > 0) {	
			pid = [[[pidA objectAtIndex:0] stringValue] integerValue];
		}
		
		INFSmartFoxUser *user;
		
		// Create and populate User
		user = [INFSmartFoxUser user:uid name:name];
		[user setModerator:isMod];
		[user setIsSpectator:isSpec];
		[user setPlayerId:pid];
		
		// Handle user variables		
		NSArray *userVarsA = [userNode nodesForXPath:@"./vars/var" error:&error];
		if ([userVarsA count] > 0) {
			[self populateVariables:[user getVariables] xmlData:userVarsA changedVars:nil];
		}
		
		// Add user
		[currRoom addUser:user id:uid];
	}
	
	// operation completed, release lock
	_sfs.changingRoom = NO;
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onJoinRoom:)]) {
		[_sfs.delegate onJoinRoom:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																 currRoom, @"room",
																 nil]]];			
	}
		
	[doc release];
}

// Failed room Join
- (void)handleJoinKo:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleJoinKo"]];
	
	_sfs.changingRoom = NO;
	
	if ([_sfs.delegate respondsToSelector:@selector(onJoinRoomError:)]) {
		NSError *error;
		CXMLDocument *doc;
		
		doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
		NSArray *joinA = [doc nodesForXPath:@"./msg/body/error/@msg" error:&error];
		
		[_sfs.delegate onJoinRoomError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [[joinA objectAtIndex:0] stringValue], @"error",
																	  nil]]];
		
		[doc release];
	}
}

// New user enters the room
- (void)handleUserEnterRoom:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleUserEnterRoom"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	
	// Get params
	NSInteger usrId = [[[[doc nodesForXPath:@"./msg/body/u/@i" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *usrName = [[[doc nodesForXPath:@"./msg/body/u/n" error:&error] objectAtIndex:0] stringValue];
	BOOL isMod = [[[[doc nodesForXPath:@"./msg/body/u/@m" error:&error] objectAtIndex:0] stringValue] boolValue];

	BOOL isSpec = NO;
	NSArray *isSpecA = [doc nodesForXPath:@"./msg/body/u/@s" error:&error];
	if ([isSpecA count] > 0) {
		isSpec = [[[isSpecA objectAtIndex:0] stringValue] boolValue];
	}
	
	NSInteger pid = -1;
	NSArray *pidA = [doc nodesForXPath:@"./msg/body/u/@p" error:&error];
	if ([pidA count] > 0) {
		pid = [[[pidA objectAtIndex:0] stringValue] intValue];
	}
	
	INFSmartFoxRoom *currRoom = [_sfs getRoom:roomId];
	
	// Create new user object
	INFSmartFoxUser *newUser = [INFSmartFoxUser user:usrId name:usrName];
	
	[newUser setModerator:isMod];
	[newUser setIsSpectator:isSpec];
	[newUser setPlayerId:pid];
	
	// Add user to room
	[currRoom addUser:newUser id:usrId];
	
	// Populate user vars
	NSArray *userVarsA = [doc nodesForXPath:@"./msg/body/u/vars/var" error:&error];
	if ([userVarsA count] > 0) {
		[self populateVariables:[newUser getVariables] xmlData:userVarsA changedVars:nil];
	}	
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onUserEnterRoom:)]) {		
		[_sfs.delegate onUserEnterRoom:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [NSNumber numberWithInt:roomId], @"roomId",
																	  newUser, @"user",
																	  nil]]];			
	}
}

// User leaves a room
- (void)handleUserLeaveRoom:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleUserLeaveRoom"]];

	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];	
	
	// Get room
	INFSmartFoxRoom *theRoom = [_sfs getRoom:roomId];
	
	// Get user name
	NSString *uName = [[[theRoom getUser:[NSNumber numberWithInt:userId]] getName] copy];
	
	// Remove user
	[theRoom removeUser:userId];
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onUserLeaveRoom:)]) {		
		[_sfs.delegate onUserLeaveRoom:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [NSNumber numberWithInt:roomId], @"roomId",
																	  [NSNumber numberWithInt:userId], @"userId",
																	  uName, @"userName",
																	  nil]]];			
	}
	
	[uName release];
}

- (void)handlePublicMessage:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handlePublicMessage"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *message = [[[doc nodesForXPath:@"./msg/body/txt" error:&error] objectAtIndex:0] stringValue];
		
	INFSmartFoxUser *sender = [[_sfs getRoom:roomId] getUser:[NSNumber numberWithInt:userId]];
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onPublicMessage:)]) {		
		[_sfs.delegate onPublicMessage:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [INFSmartFoxEntities decodeEntities:message], @"message",
																	  sender, @"sender",
																	  [NSNumber numberWithInt:roomId], @"roomId",
																	  nil]]];			
	}	
}

- (void)handlePrivateMessage:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handlePrivateMessage"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *message = [[[doc nodesForXPath:@"./msg/body/txt" error:&error] objectAtIndex:0] stringValue];
	
	INFSmartFoxUser *sender = [[_sfs getRoom:roomId] getUser:[NSNumber numberWithInt:userId]];
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onPrivateMessage:)]) {		
		[_sfs.delegate onPrivateMessage:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	   [INFSmartFoxEntities decodeEntities:message], @"message",
																	   [NSNumber numberWithInt:roomId], @"roomId",
																	   [NSNumber numberWithInt:userId], @"userId",
																	   sender, @"sender",
																	   nil]]];			
	}	
}

- (void)handleAdminMessage:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleAdminMessage"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSString *message = [[[doc nodesForXPath:@"./msg/body/txt" error:&error] objectAtIndex:0] stringValue];
		
	[doc release];
			
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onAdminMessage:)]) {		
		[_sfs.delegate onAdminMessage:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  [INFSmartFoxEntities decodeEntities:message], @"message",
																	  nil]]];			
	}	
}

- (void)handleModMessage:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleModMessage"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *message = [[[doc nodesForXPath:@"./msg/body/txt" error:&error] objectAtIndex:0] stringValue];
	
	id sender = [NSNull null];
	INFSmartFoxRoom *room = [_sfs getRoom:roomId];

	if (room) {
		sender = [room getUser:[NSNumber numberWithInt:userId]];
	}
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onModMessage:)]) {		
		[_sfs.delegate onModMessage:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																   [INFSmartFoxEntities decodeEntities:message], @"message",
																   sender, @"sender",
																   nil]]];			
	}	
}

- (void)handleASObject:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleASObject"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *xmlStr = [[[doc nodesForXPath:@"./msg/body/dataObj" error:&error] objectAtIndex:0] stringValue];
	
	INFSmartFoxUser *sender = [[_sfs getRoom:roomId] getUser:[NSNumber numberWithInt:userId]];	
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onObjectReceived:)]) {		
		[_sfs.delegate onObjectReceived:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	   [INFSmartFoxObjectSerializer deserialize:xmlStr], @"obj",
																	   sender, @"sender",
																	   nil]]];			
	}	
}

- (void)handleRoomVarsUpdate:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRoomVarsUpdate"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	
	INFSmartFoxRoom *currRoom = [_sfs getRoom:roomId];
			
	NSMutableSet *changedVars = [NSMutableSet set];
	
	// Handle Room Variables
	NSArray *roomVarsA = [doc nodesForXPath:@"./msg/body/vars/var" error:&error];
	if ([roomVarsA count] > 0) {
		[self populateVariables:[currRoom getVariables] xmlData:roomVarsA changedVars:changedVars];
	}	
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRoomVariablesUpdate:)]) {		
		[_sfs.delegate onRoomVariablesUpdate:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			currRoom, @"room",
																			changedVars, @"changedVars",
																			nil]]];			
	}	
}

- (void)handleUserVarsUpdate:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleUserVarsUpdate"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger userId = [[[[doc nodesForXPath:@"./msg/body/user/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	
	INFSmartFoxUser *currUser = [[_sfs getRoom:roomId] getUser:[NSNumber numberWithInt:userId]];
		
	NSMutableSet *changedVars = [NSMutableSet set];
	
	NSArray *userVarsA = [doc nodesForXPath:@"./msg/body/vars/var" error:&error];
	if ([userVarsA count] > 0) {
		[self populateVariables:[currUser getVariables] xmlData:userVarsA changedVars:changedVars];
	}
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onUserVariablesUpdate:)]) {		
		[_sfs.delegate onUserVariablesUpdate:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			currUser, @"user",
																			changedVars, @"changedVars",
																			nil]]];			
	}	
}

- (void)handleRoomAdded:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRoomAdded"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger rId = [[[[doc nodesForXPath:@"./msg/body/rm/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSString *rName = [[[doc nodesForXPath:@"./msg/body/rm/name" error:&error] objectAtIndex:0] stringValue];
	NSInteger rMax = [[[[doc nodesForXPath:@"./msg/body/rm/@max" error:&error] objectAtIndex:0] stringValue] integerValue];
	NSInteger rSpec = [[[[doc nodesForXPath:@"./msg/body/rm/@spec" error:&error] objectAtIndex:0] stringValue] integerValue];
	BOOL isTemp = [[[[doc nodesForXPath:@"./msg/body/rm/@temp" error:&error] objectAtIndex:0] stringValue] boolValue];
	BOOL isGame = [[[[doc nodesForXPath:@"./msg/body/rm/@game" error:&error] objectAtIndex:0] stringValue] boolValue];
	BOOL isPriv = [[[[doc nodesForXPath:@"./msg/body/rm/@priv" error:&error] objectAtIndex:0] stringValue] boolValue];
	BOOL isLimbo = [[[[doc nodesForXPath:@"./msg/body/rm/@limbo" error:&error] objectAtIndex:0] stringValue] boolValue];
	
	INFSmartFoxRoom *newRoom;
	
	// Create room obj
	newRoom = [INFSmartFoxRoom room:rId name:rName maxUsers:rMax maxSpectators:rSpec isTemp:isTemp isGame:isGame isPrivate:isPriv isLimbo:isLimbo userCount:0 specCount:0];
	
	[[_sfs getAllRooms] setObject:newRoom forKey:[NSNumber numberWithInt:rId]];	
	
	// Handle Room Variables
	NSArray *roomVarsA = [doc nodesForXPath:@"./msg/body/rm/vars/var" error:&error];
	if ([roomVarsA count] > 0) {
		[self populateVariables:[newRoom getVariables] xmlData:roomVarsA changedVars:nil];
	}
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRoomAdded:)]) {		
		[_sfs.delegate onRoomAdded:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																  newRoom, @"room",
																  nil]]];			
	}	
}

- (void)handleRoomDeleted:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRoomDeleted"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/rm/@id" error:&error] objectAtIndex:0] stringValue] integerValue];
			
	[doc release];
	
	// Pass the last reference to the upper level
	// If there's no other references to this room in the upper level
	// This is the last reference we're keeping
	
	NSMutableDictionary *roomList = [_sfs getAllRooms];

	INFSmartFoxRoom *room = [_sfs getRoom:roomId];
	[[room retain] autorelease];
	
	// Remove reference from main room list
	[roomList removeObjectForKey:[NSNumber numberWithInt:roomId]];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRoomDeleted:)]) {		
		[_sfs.delegate onRoomDeleted:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	room, @"room",
																	nil]]];			
	}	
}

- (void)handleRandomKey:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRandomKey"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSString *key = [[[doc nodesForXPath:@"./msg/body/k" error:&error] objectAtIndex:0] stringValue];
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRandomKey:)]) {		
		[_sfs.delegate onRandomKey:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																  key, @"key",
																  nil]]];			
	}	
}

- (void)handleRoundTripBench:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRoundTripBench"]];
	
	uint64_t now = mach_absolute_time();
	NSInteger res = now - [_sfs getBenchStartTime];
	double microSeconds = (((double) res) * ( (double) _sfs.mach_timebase_info_data.numer) / ((double) _sfs.mach_timebase_info_data.denom)) / 1000;
	double milliSeconds = microSeconds / 1000;
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRoundTripResponse:)]) {		
		[_sfs.delegate onRoundTripResponse:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																		  [NSNumber numberWithInt:(NSInteger)milliSeconds], @"elapsed",
																		  nil]]];			
	}
}

- (void)handleCreateRoomError:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleCreateRoomError"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	NSString *errMsg = [[[doc nodesForXPath:@"./msg/body/room/@e" error:&error] objectAtIndex:0] stringValue];
	
	[doc release];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onCreateRoomError:)]) {		
		[_sfs.delegate onCreateRoomError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																		errMsg, @"error",
																		nil]]];			
	}	
}

- (void)handleBuddyList:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleBuddyList"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
		
	// Get my buddy variables
	NSArray *mvA = [doc nodesForXPath:@"./msg/body/mv/v" error:&error];
	for (CXMLElement *mvNode in mvA) {
		[_sfs.myBuddyVars setObject:[mvNode stringValue]
		 forKey:[[[mvNode nodesForXPath:@"./@n" error:&error] objectAtIndex:0] stringValue]];
	}
	
	NSArray *bListA = [doc nodesForXPath:@"./msg/body/bList" error:&error];
	if ([bListA count] > 0) {
		NSArray *bListA = [doc nodesForXPath:@"./msg/body/bList/b" error:&error];
		for (CXMLElement *bListNode in bListA) {
			BOOL isOnline = [[[[bListNode nodesForXPath:@"./@s" error:&error] objectAtIndex:0] stringValue] boolValue];
			NSInteger buddyId = [[[[bListNode nodesForXPath:@"./@i" error:&error] objectAtIndex:0] stringValue] intValue];
			BOOL isBlocked = [[[[bListNode nodesForXPath:@"./@x" error:&error] objectAtIndex:0] stringValue] boolValue];
			NSString *name = [[[bListNode nodesForXPath:@"./n" error:&error] objectAtIndex:0] stringValue];
			
			INFSmartFoxBuddy *buddy = [INFSmartFoxBuddy buddy:buddyId name:name isOnline:isOnline isBlocked:isBlocked];
			
			// Runs through buddy variables
			NSArray *bVarsA = [bListNode nodesForXPath:@"./vs/v" error:&error];
			for (CXMLElement *bVarNode in bVarsA) {
				[buddy.variables setObject:[bVarNode stringValue]
								 forKey:[[[bVarNode nodesForXPath:@"./@n" error:&error] objectAtIndex:0] stringValue]];
			}
			
			[_sfs.buddyList setObject:buddy forKey:name];
		}
		
		// Fire event!
		if ([_sfs.delegate respondsToSelector:@selector(onBuddyList:)]) {		
			[_sfs.delegate onBuddyList:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  _sfs.buddyList, @"list",
																	  nil]]];			
		}	
	}
	else {
		// Buddy List load error!
		if ([_sfs.delegate respondsToSelector:@selector(onBuddyListError:)]) {		
			NSString *errorStr = [[[doc nodesForXPath:@"./body/err" error:&error] objectAtIndex:0] stringValue];
			
			[_sfs.delegate onBuddyListError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			errorStr, @"error",
																			nil]]];			
		}	
	}
	
	[doc release];
}


- (void)handleBuddyListUpdate:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleBuddyListUpdate"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSArray *bListA = [doc nodesForXPath:@"./msg/body/b" error:&error];
	if ([bListA count] > 0) {
		CXMLElement *bListNode = [bListA objectAtIndex:0];
		
		BOOL isOnline = [[[[bListNode nodesForXPath:@"./@s" error:&error] objectAtIndex:0] stringValue] boolValue];
		NSInteger buddyId = [[[[bListNode nodesForXPath:@"./@i" error:&error] objectAtIndex:0] stringValue] intValue];
		NSString *name = [[[bListNode nodesForXPath:@"./n" error:&error] objectAtIndex:0] stringValue];
		
		INFSmartFoxBuddy *buddy = [INFSmartFoxBuddy buddy:buddyId name:name isOnline:isOnline isBlocked:NO];
		INFSmartFoxBuddy *tempB = [_sfs.buddyList objectForKey:name];
				
		// swap objects
		[tempB retain];
		[_sfs.buddyList setObject:buddy forKey:name];
		buddy.isBlocked = tempB.isBlocked;
		buddy.variables = tempB.variables;
		[tempB release];
		
		// add/modify variables
		NSArray *bVarsA = [bListNode nodesForXPath:@"./vs/v" error:&error];
		for (CXMLElement *bVarNode in bVarsA) {
			[buddy.variables setObject:[bVarNode stringValue]
			                 forKey:[[[bVarNode nodesForXPath:@"./@n" error:&error] objectAtIndex:0] stringValue]];
		}
		
		// Fire event!
		if (tempB != nil && [_sfs.delegate respondsToSelector:@selector(onBuddyListUpdate:)]) {		
			[_sfs.delegate onBuddyListUpdate:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			buddy, @"buddy",
																			nil]]];			
		}	
	}
	else {
		// Buddy List load error!
		if ([_sfs.delegate respondsToSelector:@selector(onBuddyListError:)]) {		
			NSString *errorStr = [[[doc nodesForXPath:@"./body/err" error:&error] objectAtIndex:0] stringValue];
			
			[_sfs.delegate onBuddyListError:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																		   errorStr, @"error",
																		   nil]]];			
		}	
	}
	
	[doc release];
}

- (void)handleAddBuddyPermission:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleAddBuddyPermission"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSString *message = @"";
	
	NSArray *messageA = [doc nodesForXPath:@"./msg/body/txt" error:&error];
	if ([messageA count] > 0) {
		message = [[messageA objectAtIndex:0] stringValue];
	}
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onBuddyPermissionRequest:)]) {		
		[_sfs.delegate onBuddyPermissionRequest:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			   [[[doc nodesForXPath:@"./msg/body/n" error:&error] objectAtIndex:0] stringValue], @"sender",
																			   message, @"message",
																			   nil]]];			
	}	
	
	[doc release];
}


- (void)handleBuddyAdded:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleBuddyAdded"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
		
	BOOL isOnline = [[[[doc nodesForXPath:@"./msg/body/b/@s" error:&error] objectAtIndex:0] stringValue] boolValue];
	NSInteger buddyId = [[[[doc nodesForXPath:@"./msg/body/b/@i" error:&error] objectAtIndex:0] stringValue] intValue];
	NSString *name = [[[doc nodesForXPath:@"./msg/body/b/n" error:&error] objectAtIndex:0] stringValue];
	BOOL isBlocked = NO;
	
	NSArray *isBlockedA = [doc nodesForXPath:@"./msg/body/b/@x" error:&error];
	if ([isBlockedA count] > 0) {
		isBlocked = [[[isBlockedA objectAtIndex:0] stringValue] boolValue];
	}
			
	INFSmartFoxBuddy *buddy = [INFSmartFoxBuddy buddy:buddyId name:name isOnline:isOnline isBlocked:isBlocked];
			
	// Runs through buddy variables
	NSArray *bVarsA = [doc nodesForXPath:@"./msg/body/b/vs/v" error:&error];
	for (CXMLElement *bVarNode in bVarsA) {
		[buddy.variables setObject:[bVarNode stringValue]
						 forKey:[[[bVarNode nodesForXPath:@"./@n" error:&error] objectAtIndex:0] stringValue]];
	}
	
	[_sfs.buddyList setObject:buddy forKey:name];
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onBuddyList:)]) {		
		[_sfs.delegate onBuddyList:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																  _sfs.buddyList, @"list",
																  nil]]];			
	}	
	
	[doc release];
}


- (void)handleRemoveBuddy:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleRemoveBuddy"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSString *name = [[[doc nodesForXPath:@"./msg/body/n" error:&error] objectAtIndex:0] stringValue];
	
	if ([_sfs.buddyList objectForKey:name] != nil) {
		[_sfs.buddyList removeObjectForKey:name];
		
		// Fire event!
		if ([_sfs.delegate respondsToSelector:@selector(onBuddyList:)]) {		
			[_sfs.delegate onBuddyList:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																	  _sfs.buddyList, @"list",
																	  nil]]];			
		}	
	}
	
	[doc release];
}

- (void)handleBuddyRoom:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleBuddyRoom"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSString *roomIds = [[[doc nodesForXPath:@"./msg/body/br/@r" error:&error] objectAtIndex:0] stringValue];
	NSMutableArray *ids = [NSMutableArray arrayWithArray:[roomIds componentsSeparatedByString:@","]];
	
	for (int i = 0; i < [ids count]; i++) {
		[ids replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:[[ids objectAtIndex:i] intValue]]];
	}
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onBuddyRoom:)]) {		
		[_sfs.delegate onBuddyRoom:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																  ids, @"idlist",
																  nil]]];			
	}	
	
	[doc release];
}

- (void)handleLeaveRoom:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleLeaveRoom"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSInteger roomLeft = [[[[doc nodesForXPath:@"./msg/body/rm/@id" error:&error] objectAtIndex:0] stringValue] intValue];
	
	// Fire event!
	if ([_sfs.delegate respondsToSelector:@selector(onRoomLeft:)]) {		
		[_sfs.delegate onRoomLeft:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																 [NSNumber numberWithInt:roomLeft], @"roomId",
																 nil]]];			
	}	
	
	[doc release];
}

- (void)handleSpectatorSwitched:(id)o
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:handleSpectatorSwitched"]];
	
	NSError *error;
	CXMLDocument *doc;
	
	doc = [[CXMLDocument alloc] initWithXMLString:o options:0 error:&error];
	
	NSInteger roomId = [[[[doc nodesForXPath:@"./msg/body/@r" error:&error] objectAtIndex:0] stringValue] intValue];
	NSInteger playerId = [[[[doc nodesForXPath:@"./msg/body/pid/@id" error:&error] objectAtIndex:0] stringValue] intValue];
	
	// Sync user count, if switch successful
	INFSmartFoxRoom *theRoom = [_sfs getRoom:roomId];
	
	if (playerId > 0) {
		[theRoom setUserCount:[theRoom getUserCount] + 1];
		[theRoom setSpectatorCount:[theRoom getSpectatorCount] + 1];
	}
	
	/*
	 * Update another user, who was turned into a player
	 */
	NSArray *piduA = [doc nodesForXPath:@"./msg/body/pid/@u" error:&error];
	if ([piduA count] > 0) {
		NSInteger userId = [[[piduA objectAtIndex:0] stringValue] intValue];
		INFSmartFoxUser *user = [theRoom getUser:[NSNumber numberWithInt:userId]];
		
		if (user != nil) {
			[user setIsSpectator:NO];
			[user setPlayerId:playerId];
		}
	}
	else {
		/*
		 * Update myself
		 */
		_sfs.playerId = playerId;
		
		// Fire event!
		if ([_sfs.delegate respondsToSelector:@selector(onSpectatorSwitched:)]) {		
			[_sfs.delegate onSpectatorSwitched:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [NSNumber numberWithBool:_sfs.playerId > 0], @"success",
																			  [NSNumber numberWithInt:_sfs.playerId], @"newId",
																			  theRoom, @"room",
																			  nil]]];			
		}	
	}
		
	[doc release];
}

- (void)dispatchDisconnection
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:dispatchDisconnection"]];
	
	if ([_sfs.delegate respondsToSelector:@selector(onConnectionLost:)]) {
		[_sfs.delegate onConnectionLost:[INFSmartFoxSFSEvent sfsEvent:[NSDictionary dictionary]]];
	}
}

- (void)dealloc
{
	[_sfs debugMessage:[NSString stringWithFormat:@"INFSmartFoxSysHandler:dealloc"]];
	
	[_handlersTable release];
	
    [super dealloc];
}

@end