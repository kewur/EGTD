//
//  INFSmartFoxExtHandler.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INFSmartFoxIMessageHandler.h"

@class INFSmartFoxiPhoneClient;

@interface INFSmartFoxExtHandler : NSObject <INFSmartFoxIMessageHandler> {
	
@private
	INFSmartFoxiPhoneClient *_sfs;
}

+ (id)extHandler:(INFSmartFoxiPhoneClient *)sfs;

- (id)initWithParams:(INFSmartFoxiPhoneClient *)sfs;

/**
 * Handle messages
 */
- (void)handleMessage:(id)msgObj type:(NSString *)type delegate:(id <INFSmartFoxISFSEvents>)delegate;

@end
