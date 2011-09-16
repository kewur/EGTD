//
//  INFSmartFoxIMessageHandler.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import "INFSmartFoxISFSEvents.h"

/**
 * Handlers interface.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 * @exclude
 */
@protocol INFSmartFoxIMessageHandler <NSObject>

@required

- (void)handleMessage:(id)msgObj type:(NSString *)type delegate:(id <INFSmartFoxISFSEvents>)delegate;

@end

