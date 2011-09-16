//
//  INFSmartFoxRoomVariable.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INFSmartFoxRoomVariable : NSObject {
	NSString *_name;
	id _value;
	BOOL _priv;
	BOOL _persistent;
}

+ (id)roomVariableWithInteger:(NSString *)name value:(NSInteger)value;
+ (id)roomVariableWithFloat:(NSString *)name value:(float)value;
+ (id)roomVariableWithString:(NSString *)name value:(NSString *)value;
+ (id)roomVariableWithBool:(NSString *)name value:(BOOL)value;

- (id)initWithParams:(NSString *)name value:(id)value;

@property (retain) NSString *name;
@property (retain) id value;
@property BOOL priv;
@property BOOL persistent;

@end
