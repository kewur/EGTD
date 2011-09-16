//
//  INFSmartFoxUser.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * The User class stores the properties of each user.
 * This class is used internally by the {@link INFSmartFoxiPhoneClient} class; also, User objects are returned by various methods and events of the SmartFoxServer API.
 * 
 * <b>NOTE</b>: in the provided examples, <b>user</b> always indicates a User instance.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 */
@interface INFSmartFoxUser : NSObject {
@private
	NSInteger _id;
	NSString *_name;
	NSMutableDictionary *_variables;
	BOOL _isSpec;
	BOOL _isMod;
	NSInteger _pId;	
}

/**
 * User contructor.
 * 
 * @param	id :		the user id.
 * @param	name :	the user name.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */		
+ (id)user:(NSInteger)id name:(NSString *)name;

- (id)initWithParams:(NSInteger)id name:(NSString *)name;

/**
 * Get the id of the user.
 * 
 * @return	The user id.
 * 
 * @see		getName
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (int)getId;

/**
 * Get the name of the user.
 * 
 * @return	The user name.
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
 * Retrieve a User Variable.
 * 
 * @param	varName :	the name of the variable to retrieve.
 * 
 * @return	The User Variable's value.
 * 
 * @see		getVariables
 * @see		INFSmartFoxiPhoneClient#setUserVariables:roomId:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (id)getVariable:(NSString *)varName;

/**
 * Retrieve the list of all User Variables.
 * 
 * @return	An associative array containing User Variables' values, where the key is the variable name.
 * 
 * @see		getVariable:
 * @see		INFSmartFoxiPhoneClient#setUserVariables:roomId:
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */
- (NSMutableDictionary *)getVariables;

/**
 * Set the User Variabless.
 * 
 * @param	o :	an object containing variables' key-value pairs.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setVariables:(NSDictionary *)o;

/**
 * Reset User Variabless.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */	
- (void)clearVariables;

/**
 * Set the {@link INFSmartFoxUser#isSpectator} property.
 * 
 * @param	b :	<b>true</b> if the user is a spectator.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setIsSpectator:(BOOL)b;

/**
 * A boolean flag indicating if the user is a spectator in the current room.
 * 
 * @return	<b>true</b> if the user is a spectator.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (BOOL)isSpectator;

/**
 * Set the {@link INFSmartFoxUser#isModerator} property.
 * 
 * @param	b :	<b>true</b> if the user is a Moderator.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */	
- (void)setModerator:(BOOL)b;

/**
 * A boolean flag indicating if the user is a Moderator in the current zone.
 * 
 * @return	<b>true</b> if the user is a Moderator.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (BOOL)isModerator;

/**
 * Retrieve the player id of the user.
 * The user must be a player inside a game room for this method to work properly.
 * This id is 1-based (player 1, player 2, etc.), but if the user is a spectator its value is -1.
 * 
 * @return	The current player id.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	SmartFoxServer Basic / Pro
 */	
- (NSInteger)getPlayerId;

/**
 * Set the playerId property.
 * 
 * @param	pid :	the playerId value.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @exclude
 */
- (void)setPlayerId:(NSInteger)pid;

@end
