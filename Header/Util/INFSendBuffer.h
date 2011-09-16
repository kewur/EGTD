//
//  INFSendBuffer.h
//  OkeyiPhoneClient
//
//  Created by Cem Uzunlar | cem.uzunlar@infosfer.com.
//  Copyright 2009 Infosfer Game and Visualization Technologies Ltd. | http://www.infosfer.com All rights reserved.
//

#import <Foundation/Foundation.h>

@interface INFSendBuffer : NSMutableData {
@private
	NSMutableData *embeddedData;
	NSInteger sendPos;
}

@property (readonly) NSInteger sendPos;

+ (id)dataWithNSData:(NSData *)newdata;

- (id)initWithData:(NSData *)newdata;
- (void)consumeData:(NSInteger)length;

- (const void *)bytes;
- (NSUInteger)length;

- (void *)mutableBytes;
- (void)setLength:(NSUInteger)length;

@end
