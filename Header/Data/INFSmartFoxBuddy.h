//
//  INFSmartFoxBuddy.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INFSmartFoxBuddy : NSObject {
@public
	NSInteger _id;
	NSString *_name;
	BOOL _isOnline;
	BOOL _isBlocked;
	NSMutableDictionary *_variables;
}

@property NSInteger buddyId;
@property (retain) NSString *name;
@property BOOL isOnline;
@property BOOL isBlocked;
@property (retain) NSMutableDictionary *variables;

+ (id)buddy:(NSInteger)id name:(NSString *)name isOnline:(BOOL)isOnline isBlocked:(BOOL)isBlocked;

- (id)initWithParams:(NSInteger)id name:(NSString *)name isOnline:(BOOL)isOnline isBlocked:(BOOL)isBlocked;

@end
