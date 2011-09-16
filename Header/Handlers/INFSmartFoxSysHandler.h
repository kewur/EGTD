//
//  INFSmartFoxSysHandler.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

#import "INFSmartFoxIMessageHandler.h"
#import "INFSmartFoxSFSEvent.h"

@class INFSmartFoxiPhoneClient;

/**
 * SysHandler class: handles "sys" type messages.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.2.0
 * 
 * @exclude
 */
@interface INFSmartFoxSysHandler : NSObject <INFSmartFoxIMessageHandler> {

@private
	INFSmartFoxiPhoneClient *_sfs;
	NSMutableDictionary *_handlersTable;
}

+ (id)sysHandler:(INFSmartFoxiPhoneClient *)sfs;
	
- (id)initWithParams:(INFSmartFoxiPhoneClient *)sfs;

- (void)handleMessage:(id)msgObj type:(NSString *)type delegate:(id <INFSmartFoxISFSEvents>)delegate;
- (void)dispatchDisconnection;

@end
