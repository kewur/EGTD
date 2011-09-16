//
//  INFSmartFoxRoomCreateParams.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@class INFSmartFoxRoomVariable;

@interface INFSmartFoxRoomCreateParams : NSObject {
	NSString *_name;
    NSString *_password;
	NSInteger _maxUsers;
	NSInteger _maxSpectators;
	BOOL _isGame;
	BOOL _exitCurrentRoom;
	BOOL _uCount;
	NSMutableArray *_vars;
	NSString *_extensionName;
	NSString *_extensionScript;
}

+ (id)roomCreateParams;
+ (id)roomCreateParamsWithName:(NSString *)name;

- (id)initWithParams:(NSString *)name;

- (void)addVar:(INFSmartFoxRoomVariable *)var;

@property (retain) NSString *name;
@property (retain) NSString *password;
@property NSInteger maxUsers;
@property NSInteger maxSpectators;
@property BOOL isGame;
@property BOOL exitCurrentRoom;
@property BOOL uCount;
@property (readonly) NSArray *vars;
@property (retain) NSString *extensionName;
@property (retain) NSString *extensionScript;

@end
