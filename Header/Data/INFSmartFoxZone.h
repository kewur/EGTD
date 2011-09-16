//
//  INFSmartFoxZone.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@class INFSmartFoxRoom;

/**
 * The Zone class stores the properties of the current server zone.
 * This class is used internally by the {@link INFSmartFoxiPhoneClient} class.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 * @exclude
 */
@interface INFSmartFoxZone : NSObject {
@private
	NSMutableDictionary *_roomList;
	NSString *_name;
}

+ (id)zone:(NSString *)name;

- (id)initWithParams:(NSString *)name;
	
- (INFSmartFoxRoom *)getRoom:(NSInteger)id;
- (INFSmartFoxRoom *)getRoomByName:(NSString *)name;

@end
