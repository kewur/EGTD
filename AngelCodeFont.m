//
//  AngelCodeFont.m
//  Tutorial1
//
//  Created by Michael Daley on 08/03/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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

#import "AngelCodeFont.h"

@interface AngelCodeFont ()
- (void)parseFont:(NSString*)controlFile;
- (void)parseCommon:(NSString*)line;
- (void)parseCharacterDefinition:(NSString*)line charDef:(CharDef*)CharDef;
- (void)initVertexArrays:(int)totalQuads;
@end

@implementation AngelCodeFont

@synthesize scale;

- (id)initWithFontImageNamed:(NSString*)fontImage controlFile:(NSString*)controlFile scale:(float)fontScale filter:(GLenum)filter {
	self = [self init];
	if (self != nil) {
		// Reference the font image which has been supplied and which contains the character bitmaps
        // Get the shared game state instance
		_director = [Director sharedDirector];
        
		image = [[Image alloc] initWithImage:fontImage scale:fontScale filter:filter];
        
		// Set the scale to be used for the font
		scale = fontScale;
		colourFilter[0] = 1.0f;
		colourFilter[1] = 1.0f;
		colourFilter[2] = 1.0f;
		colourFilter[3] = 1.0f;
		// Parse the control file and populate charsArray which the character definitions
		[self parseFont:controlFile];
	}
	return self;
}


- (void)parseFont:(NSString*)controlFile {
	
	// Read the contents of the file into a string
	NSString *contents = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:controlFile ofType:@"fnt"] encoding:NSASCIIStringEncoding error:nil];
	
	// Move all lines in the string, which are denoted by \n, into an array
	NSArray *lines = [[NSArray alloc] initWithArray:[contents componentsSeparatedByString:@"\n"]];
	
	// Create an enumerator which we can use to move through the lines read from the control file
	NSEnumerator *nse = [lines objectEnumerator];
	
	// Create a holder for each line we are going to work with
	NSString *line;
	
	// A holder for the number of characters read in from the font file
	int totalQuads = 0;
	
	// Loop through all the lines in the lines array processing each one
	while(line = [nse nextObject]) {
		// Check to see if the start of the line is something we are interested in
		if([line hasPrefix:@"common"]) {
			[self parseCommon:line];  //// NEW CODE ADDED 05/02/10 to parse the common params
		} else if([line hasPrefix:@"char"]) {
			// Parse the current line and create a new CharDef
			CharDef *characterDefinition = [[[CharDef alloc] initCharDefWithFontImage:image scale:scale] retain];
			[self parseCharacterDefinition:line charDef:characterDefinition];
			
			// Add the CharDef returned to the charArray
			charsArray[[characterDefinition charID]] = characterDefinition;
			[characterDefinition release];
			
			// Increment the total number of characters
			totalQuads++;
		}		
	}
	// Finished with lines so release it
	[lines release];
	
	// Now we have passed the font control file we know how many characters we have so we can set
	// up the vertext arracys
	NSLog(@"AngelCodeFont: Initializing vertex arrays for font '%@' with capacity of '%d'", controlFile, totalQuads);
	[self initVertexArrays:totalQuads];
}


- (void)initVertexArrays:(int)totalQuads {
	
	// Init the texture, vertices and indices arrays ready for taking data.  The size we allocate
	// to these arrays is based on the number of characters (quads) read from the font control file
	texCoords = malloc( sizeof(texCoords[0]) * totalQuads);
	vertices = malloc( sizeof(vertices[0]) * totalQuads);
	indices = malloc( sizeof(indices[0]) * totalQuads * 6);
	
	bzero( texCoords, sizeof(texCoords[0]) * totalQuads);
	bzero( vertices, sizeof(vertices[0]) * totalQuads);
	bzero( indices, sizeof(indices[0]) * totalQuads * 6);
	
	for( NSUInteger i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;			
	}	
}


//// NEW CODE ADDED 05/02/10 to parse the common params
- (void)parseCommon:(NSString*)line {
    
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
	
	// We are going to place each value we read from the line into this string
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Common Line Height
	propertyValue = [nse nextObject];
    commonHeight = [propertyValue intValue];
    //Ignore the next entry
    [nse nextObject];
    // scaleW is the width of the texture atlas for this font.
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] <= 1024, @"ERROR - BitmapFont: Texture atlas cannot be larger than 1024x1024");
    // scaleH is the height of the texture atlas for this font.
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] <= 1024, @"ERROR - BitmapFont: Texture atlas cannot be larger than 1024x1024");
    // pages are the number of different texture atlas files being used for this font
	propertyValue = [nse nextObject];
    NSAssert([propertyValue intValue] == 1, @"ERROR - BitmapFont: Only supports fonts with a single texture atlas.");
}


- (void)parseCharacterDefinition:(NSString*)line charDef:(CharDef*)characterDefinition {
	
	// Break the values for this line up using =
	NSArray *values = [line componentsSeparatedByString:@"="];
	
	// Get the enumerator for the array of components which has been created
	NSEnumerator *nse = [values objectEnumerator];
	
	// We are going to place each value we read from the line into this string
	NSString *propertyValue;
	
	// We need to move past the first entry in the array before we start assigning values
	[nse nextObject];
	
	// Character ID
	propertyValue = [nse nextObject];
	[characterDefinition setCharID:[propertyValue intValue]];
	// Character x
	propertyValue = [nse nextObject];
	[characterDefinition setX:[propertyValue intValue]];
	// Character y
	propertyValue = [nse nextObject];
	[characterDefinition setY:[propertyValue intValue]];
	// Character width
	propertyValue = [nse nextObject];
	[characterDefinition setWidth:[propertyValue intValue]];
	// Character height
	propertyValue = [nse nextObject];
	[characterDefinition setHeight:[propertyValue intValue]];
	// Character xoffset
	propertyValue = [nse nextObject];
	[characterDefinition setXOffset:[propertyValue intValue]];
	// Character yoffset
	propertyValue = [nse nextObject];
	[characterDefinition setYOffset:[propertyValue intValue]];
	// Character xadvance
	propertyValue = [nse nextObject];
	[characterDefinition setXAdvance:[propertyValue intValue]];
}


- (void)drawStringAt:(CGPoint)point text:(NSString*)text {
	
	// Reset the number of quads which are going to be drawn
	int currentQuad = 0;
	glPushMatrix();

    // Enable those states necessary to draw with textures and allow blending
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_VERTEX_ARRAY);
    
	// Setup how the text is to be blended
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	// Bind to the texture which was generated for the spritesheet image used for this font.  We only
	// need to bind once before the drawing as all characters are on the same texture.
    
	// Bind to the texture which was generated for the spritesheet image used for this font.  We only
	// need to bind once before the drawing as all characters are on the same texture.
	if([[image texture] name] != [_director currentlyBoundTexture]) {
		[_director setCurrentlyBoundTexture:[[image texture] name]];
		glBindTexture(GL_TEXTURE_2D, [[image texture] name]);
	}	
	
	// Loop through all the characters in the text
	for(int i=0; i<[text length]; i++) {
		
		// Grab the unicode value of the current character
		int charID = [text characterAtIndex:i];
		
		// Only render the current character if it is going to be visible otherwise move the variables such as currentQuad and point.x
		// as normal but don't render the character which should save some cycles
		if(point.x > 0 - ([charsArray[charID] width] * scale) || point.x < [[UIScreen mainScreen] bounds].size.width || point.y > 0 - ([charsArray[charID] height] * scale) || point.y < [[UIScreen mainScreen] bounds].size.height) {
			
			// Using the current x and y, calculate the correct position of the character using the x and y offsets for each character.
			// This will cause the characters to all sit on the line correctly with tails below the line etc.
			
			/////// NEW CODE ADDED 05/02/10 to correct positioning of characters
			int y = point.y + (commonHeight * charsArray[charID].scale) - (charsArray[charID].height + charsArray[charID].yOffset) * charsArray[charID].scale;
			int x = point.x + charsArray[charID].xOffset;
			CGPoint newPoint = CGPointMake(x, y);

			/////// OLD CODE 		
			//CGPoint newPoint = CGPointMake(point.x + ([charsArray[charID] xOffset] * [charsArray[charID] scale]), 
			//point.y - ([charsArray[charID] yOffset] + [charsArray[charID] height])* [charsArray[charID] scale]);
			
			// Create a point into the bitmap font spritesheet using the coords read from the control file for this character
			CGPoint pointOffset = CGPointMake([charsArray[charID] x], [charsArray[charID] y]);
			
			// Calculate the texture coordinates and quad vertices for the current character
			[[charsArray[charID] image] calculateTexCoordsAtOffset:pointOffset subImageWidth:[charsArray[charID] width] subImageHeight:[charsArray[charID] height]];
			[[charsArray[charID] image] calculateVerticesAtPoint:newPoint subImageWidth:[charsArray[charID] width] subImageHeight:[charsArray[charID] height] centerOfImage:NO];
			
			// Place the calculated texture coordinates and quad vertices into the arrays we will use when drawing out string
            texCoords[currentQuad] = *[[charsArray[charID] image] textureCoordinates];
			//texCoords[currentQuad] = *[[charsArray[charID] image] texCoords];
			vertices[currentQuad] = *[[charsArray[charID] image] vertices];

			// Increment quad count
			currentQuad++;
		}

		// Move the x location along by the amount defined for this character in the control file so the charaters are spaced
		// correctly
		point.x += [charsArray[charID] xAdvance] * scale;
	}
   	// Now that we have calculated all the quads and textures for the string we are drawing we can draw them all
    glTranslatef(point.x, point.y, 0);
	glRotatef(-90, 0.0f, 0.0f, 1.0f);
	glTranslatef(-point.x, -point.y, 0);
    
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
   	glColor4f(colourFilter[0], colourFilter[1], colourFilter[2], colourFilter[3]);
    
    glDrawElements(GL_TRIANGLES, currentQuad*6, GL_UNSIGNED_SHORT, indices);

	glDisable(GL_TEXTURE_2D);
	glDisable(GL_BLEND);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
  
    glPopMatrix();
}


- (int)getWidthForString:(NSString*)string {
	// Set up stringWidth
	int stringWidth = 0;
	
	// Loop through the characters in the text and sum the xAdvance for each one
	// xAdvance holds how far to move long X for each character so that the correct
	// space is left after each character
	for(int index=0; index<[string length]; index++) {
		int charID = [string characterAtIndex:index];
		
		// Add the xAdvance value of the current character to stringWidth scaling as necessary
		stringWidth += [charsArray[charID] xAdvance] * scale;
	}	
	// Return the total width calculated
	return stringWidth;
}


- (int)getHeightForString:(NSString*)string {
	// Set up stringHeight	
	int stringHeight = 0;
	
	// Loop through the characters in the text and sum the height.  The sum will take into
	// account the offset of the character as some characters sit below the line etc
	for(int i=0; i<[string length]; i++) {
		int charID = [string characterAtIndex:i];
		
		// Don't bother checking if the character is a space as they have no height
		if(charID == ' ')
			continue;
		
		// Check to see if the height of the current character is greater than the current max height
		// If so then replace the current stringHeight with the height of the current character
		stringHeight = MAX(([charsArray[charID] height] * scale) + ([charsArray[charID] yOffset] * scale), stringHeight);
	}	
	// Return the total height calculated
	return stringHeight;	
}


- (void)setColourFilterRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
	// Set the colour filter of the spritesheet image used for this font
	colourFilter[0] = red;
	colourFilter[1] = green;
	colourFilter[2] = blue;
	colourFilter[3] = alpha;
}


- (void)setScale:(float)newScale {
	scale = newScale;
	[image setScale:newScale];
}


- (void)dealloc {
	free(texCoords);
	free(vertices);
	free(indices);
	[image release];
	[super dealloc];
}

@end
