//
//  INFSmartFoxObjectSerializer.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * ObjectSerializer class.
 * 
 * \author Infosfer Game and Visualization Technologies Ltd. http://www.infosfer.com
 * \author Cem Uzunlar cem.uzunlar@infosfer.com
 * 
 * @version	1.0.0
 * 
 * @exclude
 */
@interface INFSmartFoxObjectSerializer : NSObject {
}

+ (void)setDebug:(BOOL)b;
+ (NSString *)serialize:(NSDictionary *)o;
+ (NSDictionary *)deserialize:(NSString *)xmlString;

@end
