//
//  AngelCodeFont.h
//  Tutorial1
//
//  Created by Michael Daley on 08/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
//
/*
 Whilst looking for how to render Bitmap Fonts I found this page http://www.angelcode.com/products/bmfont/
 
 They have an application which can take a true type font and turn it into a spritesheet and control file.
 With these files you can then render a string to the screen using the font generated.  I develop of a Mac of
 course so was disappointed that this app was for Windows.  Fear not, luckily a tool has been developed by
 Kev Glass over at http://slick.cokeandcode.com/index.php for use with his open source Java 2D game library.
 The app is called Hiero. 
 
 This generates the necessary image file and control file in the format defined on the AngelCode Font website.
 Hiero has also been updated recently to handle Unicode fonts as well accoriding to the forums and this new 
 versions webstart can be found here http://www.n4te.com/hiero/hiero.jnlp 
 
 Being Java this version will work on any platform :o)
 
 This implementation has been tested against the output from Hiero V2
 */


#import <Foundation/Foundation.h>
#import "Image.h"
#import "CharDef.h"

@interface AngelCodeFont : NSObject {
    
    // Game state
	Director *_director;
	// The image which contains the bitmap font
	Image		*image;
	// The characters building up the font
	CharDef		*charsArray[256];
	// The height of a line
	GLuint		lineHeight;
	// Colour Filter = Red, Green, Blue, Alpha
	float		colourFilter[4];
	// The scale to be used when rendering the font
	float		scale;
	int commonHeight;
	// Vertex arrays
	EGQuad2f *texCoords;
	EGQuad2f *vertices;
	GLushort *indices;
}

@property(nonatomic, assign)float scale;

- (id)initWithFontImageNamed:(NSString*)fontImage controlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter;
- (void)drawStringAt:(CGPoint)point text:(NSString*)text;
- (int)getWidthForString:(NSString*)string;
- (int)getHeightForString:(NSString*)string;
- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
- (void)setScale:(float)newScale;

@end