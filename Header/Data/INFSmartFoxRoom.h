//
//  INFSmartFoxRoom.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@class INFSmartFoxUser;
/**
 * The Room class stores the properties of each server room.
 * This class is used internally by the {@link INFSmartFoxiPhoneClient} class; also, Room objects are returned by various methods and events of the SmartFoxServer API.
 * 
 * <b>NOTE</b>: in the provided examples, <b>room</b> always indicates a Room instance.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 */
@interface INFSmartFoxRoom : NSObject {
@private	
	NSInteger _id;
	NSString *_name;
	NSInteger _maxUsers;
	NSInteger _maxSpectators;
	BOOL _temp;
	BOOL _game;
	BOOL _priv;
	BOOL _limbo;
	NSInteger _userCount;
	NSInteger _specCount;
		
	NSInteger _myPlayerIndex;
		
	NSMutableDictionary *_userList;
	NSMutableDictionary *_variables;
}
		
/**
 * Room contructor.
 * 
 * @param	id :				the room id.
 * @param	name :			the room name.
 * @param	maxUsers :		the maximum number of users that can join the room simultaneously.
 * @param	maxSpectators :	the maximum number of spectators in the room (for game rooms only).
 * @param	isTemp :			<b>true</b> if the room is temporary.
 * @param	isGame :			<b>true</b> if the room is a "game room".
 * @param	isPrivate :		<b>true</b> if the room is private (password protected).
 * @param	isLimbo :		<b>true</b> if the room is a "limbo room".
 * @param	userCount
 * @param	specCount
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
+ (id)room:(NSInteger)id name:(NSString *)name maxUsers:(NSInteger)maxUsers maxSpectators:(NSInteger)maxSpectators isTemp:(BOOL)isTemp isGame:(BOOL)isGame isPrivate:(BOOL)isPrivate isLimbo:(BOOL)isLimbo userCount:(NSInteger)userCount specCount:(NSInteger)specCount;

- (id)initWithParams:(NSInteger)id name:(NSString *)name maxUsers:(NSInteger)maxUsers maxSpectators:(NSInteger)maxSpectators isTemp:(BOOL)isTemp isGame:(BOOL)isGame isPrivate:(BOOL)isPrivate isLimbo:(BOOL)isLimbo userCount:(NSInteger)userCount specCount:(NSInteger)specCount;

/**
 * Add a user to the room.
 * 
 * @param	u :	the {@link INFSmartFoxUser} object.
 * @param	id :	the user id.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)addUser:(INFSmartFoxUser *)u id:(NSInteger)id;

/**
 * Remove a user from the room.
 * 
 * @param	id :	the user id.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)removeUser:(NSInteger)id;

/**
 * Get the list of users currently inside the room.
 * As the returned list is an associative array with user id(s) as keys, in order to iterate it a <i>for-in</i> loop or a <i>for-each</i> loop should be used.
 * 
 * @return	A list of {@link INFSmartFoxUser} objects.
 * 
 * @see		getUser:
 * @see		INFSmartFoxUser
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSMutableDictionary *)getUserList;


/**
 * Retrieve a user currently in the room.
 * 
 * @param 	userId :	the user name (<b>String</b>) or the id (<b>int</b>) of the user to retrieve.
 * 
 * @return	A {@link INFSmartFoxUser} object.
 * 
 * @see		getUserList
 * @see		INFSmartFoxUser
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */ 
- (INFSmartFoxUser *)getUser:(id)userId;


/**
 * Reset users list.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)clearUserList;

/**
 * Retrieve a Room Variable.
 * 
 * @param	varName :	the name of the variable to retrieve.
 * 
 * @return	The Room Variable's value.
 * 
 * @see		getVariables
 * @see		INFSmartFoxiPhoneClient#setRoomVariables:roomId:setOwnership:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (id)getVariable:(NSString *)varName;

/**
 * Retrieve the list of all Room Variables.
 * 
 * @return	An associative array containing Room Variables' values, where the key is the variable name.
 * 
 * @see		getVariable:
 * @see		INFSmartFoxiPhoneClient#setRoomVariables:roomId:setOwnership:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSMutableDictionary *)getVariables;

/**
 * Set the Room Variables.
 * 
 * @param	vars :	an array of Room Variables.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setVariables:(NSDictionary *)vars;

- (void)setUserList:(NSDictionary *)uList;

/**
 * Reset Room Variables.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)clearVariables;

/**
 * Get the name of the room.
 * 
 * @return	The name of the room.
 * 
 * @see		getId
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSString *)getName;

/**
 * Get the id of the room.
 * 
 * @return	The id of the room.
 * 
 * @see		getName
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getId;

/**
 * A boolean flag indicating if the room is dynamic/temporary.
 * This is always true for rooms created at runtime on client-side.
 * 
 * @return	<b>true</b> if the room is a dynamic/temporary room.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (BOOL)isTemp;

/**
 * A boolean flag indicating if the room is a "game room".
 * 
 * @return	<b>true</b> if the room is a "game room".
 * 
 * @see		isLimbo
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (BOOL)isGame;

/**
 * A boolean flag indicating if the room is private (password protected).
 * 
 * @return	<b>true</b> if the room is private.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (BOOL)isPrivate;

/**
 * Retrieve the number of users currently inside the room.
 * 
 * @return	The number of users in the room.
 * 
 * @see		getSpectatorCount
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getUserCount;

/**
 * Retrieve the number of spectators currently inside the room.
 * 
 * @return	The number of spectators in the room.
 * 
 * @see		getUserCount
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getSpectatorCount;

/**
 * Retrieve the maximum number of users that can join the room.
 * 
 * @return	The maximum number of users that can join the room.
 * 
 * @see		getMaxSpectators
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getMaxUsers;

/**
 * Retrieve the maximum number of spectators that can join the room.
 * Spectators can exist in game rooms only.
 * 
 * @return	The maximum number of spectators that can join the room.
 * 
 * @see		getMaxUsers
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getMaxSpectators;


/**
 * Set the myPlayerId property.
 * Each room where the current client is connected contains a myPlayerId (if the room is a gameRoom).
 * myPlayerId == -1 ... user is a spectator
 * myPlayerId  > 0  ...	user is a player
 * 
 * @param	id :	the myPlayerId value.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setMyPlayerIndex:(NSInteger)id;

/**
 * Retrieve the player id for the current user in the room.
 * This id is 1-based (player 1, player 2, etc.), but if the user is a spectator its value is -1.
 * 
 * @return	The player id for the current user.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSInteger)getMyPlayerIndex;

/**
 * Set the @link INFSmartFoxRoom#isLimbo @endlink property.
 * 
 * @param	b :	<b>true</b> if the room is a "limbo room".
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setIsLimbo:(BOOL)b;

/**
 * A boolean flag indicating if the room is in "limbo mode".
 * 
 * @return	<b>true</b> if the room is in "limbo mode".
 * 
 * @see		isGame
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (BOOL)isLimbo;

/**
 * Se the number of users in the room.
 * 
 * @param	n :	the number of users.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setUserCount:(NSInteger)n;

/**
 * Se the number of spectators in the room.
 * 
 * @param	n :	the number of spectators.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setSpectatorCount:(NSInteger)n;

@end