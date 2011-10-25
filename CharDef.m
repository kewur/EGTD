//
//  CharDef.m
//  Tutorial1
//
//  Created by Michael Daley on 08/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CharDef.h"


@implementation CharDef

@synthesize image;
@synthesize charID;
@synthesize x;
@synthesize y;
@synthesize width;
@synthesize height;
@synthesize xOffset;
@synthesize yOffset;
@synthesize xAdvance;
@synthesize scale;

- (id)initCharDefWithFontImage:(Image*)fontImage scale:(float)fontScale{
	self = [super init];
	if (self != nil) {
		// Reference the image file which contains the spritemap for the characters
		image = fontImage;
		// Set the scale for this character
		scale = fontScale;
	}
	return self;
}


- (NSString *)description {
	// Log what we have created
	return [NSString stringWithFormat:@"CharDef = id:%d x:%d y:%d width:%d height:%d xoffset:%d yoffset:%d xadvance:%d", 
			charID, 
			x, 
			y, 
			width, 
			height, 
			xOffset, 
			yOffset, 
			xAdvance];
}


- (void)dealloc {
	[super dealloc];
}

@end
