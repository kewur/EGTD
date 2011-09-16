//
//  INFSmartFoxEntities.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Entities class.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 * @exclude
 */
@interface INFSmartFoxEntities : NSObject {
}

+ (void)initialize;
+ (NSString *)encodeEntities:(NSString *)st;
+ (NSString *)decodeEntities:(NSString *)st;

@end
