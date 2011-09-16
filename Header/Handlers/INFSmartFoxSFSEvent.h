//
//  INFSmartFoxSFSEvent.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INFSmartFoxSFSEvent : NSObject {
@public
	/**
	 * An object containing all the parameters related to the dispatched event.
	 * See the class constants for details on the specific parameters contained in this object.
	 * 
	 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
	 * \author Cem Uzunlar cem.uzunlar@infosfer.com
	 */	
	NSDictionary *_params;
}

@property (readonly) NSDictionary *params;

+ (id)sfsEvent:(NSDictionary *)params;

- (id)initWithParams:(NSDictionary *)params;

@end
