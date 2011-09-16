//
//  NSObjectAddition.h
//  INFSmartFoxiPhoneLibrary
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#if (TARGET_OS_IPHONE)

#import <Foundation/Foundation.h>

@interface NSObject (MyAdditions)

- (NSString *)className;
+ (NSString *)className;

@end

#endif
