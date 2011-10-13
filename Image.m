//
//  Image.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Image.h"

#pragma mark -
#pragma mark Private interface

@interface Image (Private)

// Method which is used to initialize an image regardless of which selector was used 
- (void)initImplementation;

// Method which actually renders the image using OpenGL based on the vertices and texture
// coordinates which have been calculated
- (void)renderAt:(CGPoint)point texCoords:(EGQuad2f*)coordinates quadVertices:(EGQuad2f*)vertices;
@end

#pragma mark -
#pragma mark Public implementation

@implementation Image

@synthesize imageName;
@synthesize texture;
@synthesize	imageWidth;
@synthesize imageHeight;
@synthesize textureWidth;
@synthesize textureHeight;
@synthesize texWidthRatio;
@synthesize texHeightRatio;
@synthesize textureOffsetX;
@synthesize textureOffsetY;
@synthesize rotation;
@synthesize scale;
@synthesize flipVertically;
@synthesize flipHorizontally;
@synthesize textureCoordinates;
@synthesize vertices;


// Added 07/02/10 as fix memory leaks
- (void)dealloc {
	
	if(texture)
		[texture release];
	if(textureCoordinates)
		free(textureCoordinates);
	if(vertices)
		free(vertices);
	if(indices)
		free(indices);
	[super dealloc];
}

- (id)initWithImage:(NSString*)aImage {
	self = [super init];
	if (self != nil) {
        filter = GL_NEAREST;
		scale = 1.0f;
		imageName = aImage;
		[self initImplementation];
	}
	return self;
}


- (id)initWithImage:(NSString*)aImage filter:(GLenum)aFilter {
	self = [super init];
	if (self != nil) {
		filter = aFilter;
		scale = 1.0f;
		imageName = aImage;
		[self initImplementation];
	}
	return self;
}


- (id)initWithImage:(NSString*)aImage scale:(float)aScale {
	self = [super init];
	if (self != nil) {
		filter = GL_NEAREST;
		scale = aScale;
		imageName = aImage;
		[self initImplementation];
	}
	return self;
}	


- (id)initWithImage:(NSString*)aImage scale:(float)aScale filter:(GLenum)aFilter {
	self = [super init];
	if (self != nil) {
		filter = aFilter;
		scale = aScale;
		imageName = aImage;
		[self initImplementation];
	}
	return self;
}


- (void)initImplementation {
	
	_director = [Director sharedDirector];
    _resourceManager = [ResourceManager sharedResourceManager];
    
    // Try to get the texture from the resource manager.  If it does not exist it will be added to
    // the cache automatically ready for next time.
    texture = [[_resourceManager getTextureWithName:imageName] retain];
    
	imageWidth = texture.contentSize.width;
	imageHeight = texture.contentSize.height;
	textureWidth = texture.pixelsWide;
	textureHeight = texture.pixelsHigh;
	maxTexWidth = imageWidth / textureWidth;
	maxTexHeight = imageHeight / textureHeight;
	texWidthRatio = 1.0f / textureWidth;
	texHeightRatio = 1.0f / textureHeight;
	textureOffsetX = 0;
	textureOffsetY = 0;
	rotation = 0.0f;
	_colorfilter = Color4fInit;
	flipVertically = NO;
	flipHorizontally = NO;
	lastTextureOffset = CGPointMake(-1, -1);
	
	// Init texture and vertex arrays
	int totalQuads = 1;
	textureCoordinates = calloc( totalQuads, sizeof( EGQuad2f ) );
	vertices = calloc( totalQuads, sizeof( EGQuad2f ) );
	indices = calloc( totalQuads * 6, sizeof( GLushort ) );
	
	for( NSUInteger i=0;i<totalQuads;i++) {
		indices[i*6+0] = i*4+0;
		indices[i*6+1] = i*4+1;
		indices[i*6+2] = i*4+2;
		indices[i*6+5] = i*4+1;
		indices[i*6+4] = i*4+2;
		indices[i*6+3] = i*4+3;
	}
}


- (NSString *)description {
	return [NSString stringWithFormat:@"texture:%d width:%d height:%d texWidth:%d texHeight:%d maxTexWidth:%f maxTexHeight:%f angle:%f scale:%f", [texture name], imageWidth, imageHeight, textureWidth, textureHeight, maxTexWidth, maxTexHeight, rotation, scale];
}


- (Image*)getSubImageAtPoint:(CGPoint)aPoint subImageWidth:(GLuint)aImageWidth subImageHeight:(GLuint)aImageHeight scale:(float)aScale {
	
	//Create a new Image instance using the texture which has been assigned to the current instance
	Image *subImage = [[Image alloc] initWithImage:imageName scale:aScale];
    
	// Define the offset of the subimage we want using the point provided
	[subImage setTextureOffsetX:aPoint.x];
	[subImage setTextureOffsetY:aPoint.y];
	
	// Set the width and the height of the subimage
	[subImage setImageWidth:aImageWidth];
	[subImage setImageHeight:aImageHeight];
	
	// Set the rotation and colour of the current image to the same as the current image 
	[subImage setRotation:rotation];
	[subImage setColourFilterRed:_colorfilter.red green:_colorfilter.green blue:_colorfilter.blue alpha:_colorfilter.alpha];
	
	// Set the rotatoin of the subImage to match the current images rotation
	[subImage setRotation:rotation];
	
	// 08/05/09 - The new image now reflects the flip params correcrly
	// Set the flip params
	[subImage setFlipVertically:flipVertically];
	[subImage setFlipHorizontally:flipHorizontally];
    
    // We mark the subimage to be returned as autorelease as its the resposbility of the caller to
    // retain the returned subimage.
	return [subImage autorelease];
}


- (Image*)copyImageAtScale:(float)aScale {
	
	//Create a new Image instance using the texture which has been assigned to the current instance
	Image *newImage = [[Image alloc] initWithImage:imageName scale:aScale];
    
	// Set up the remaining properties so the copy is the same as the source
	[newImage setTextureOffsetX:[self textureOffsetX]];
	[newImage setTextureOffsetY:[self textureOffsetY]];
	[newImage setRotation:[self rotation]];
	[newImage setFlipVertically:flipVertically];
	[newImage setFlipHorizontally:flipHorizontally];
    
	// Return the new image and autorelease it.  The caller is responsbile for retaining it
	return [newImage autorelease];
	
}


- (void)calculateTexCoordsAtOffset:(CGPoint)aOffsetPoint subImageWidth:(int)aSubImageWidth 
                    subImageHeight:(int)aSubImageHeight {
    
	// Calculate the texture coordinates using the offset point from which to start the image and then 
    // using the width and height passed in.  We only calculate the texture coordinates once for an image 
    // to help performance.
    
	if(aOffsetPoint.x != lastTextureOffset.x || aOffsetPoint.y != lastTextureOffset.y) {
		lastTextureOffset = aOffsetPoint;
		
		// Work out the texture coordinates 
		EGQuad2f tempTexCoords;
        
		tempTexCoords.tl_x = texWidthRatio * aOffsetPoint.x;
		tempTexCoords.tl_y = texHeightRatio * aOffsetPoint.y;
		tempTexCoords.tr_x = texWidthRatio * aSubImageWidth + (texWidthRatio * aOffsetPoint.x);
		tempTexCoords.tr_y = texHeightRatio * aOffsetPoint.y;
		tempTexCoords.bl_x = texWidthRatio * aOffsetPoint.x;
		tempTexCoords.bl_y = texHeightRatio * aSubImageHeight + (texHeightRatio * aOffsetPoint.y);
		tempTexCoords.br_x = texWidthRatio * aSubImageWidth + (texWidthRatio * aOffsetPoint.x);
		tempTexCoords.br_y = texHeightRatio * aSubImageHeight + (texHeightRatio * aOffsetPoint.y);
		
        // Load the texture coordinates into |texCoords| as necessary.  Swapping which values are
        // loaded into |texCoords| allows us to flip the texture.
		if(!flipHorizontally && !flipVertically) {
			textureCoordinates[0].tl_x = tempTexCoords.tl_x;
			textureCoordinates[0].tl_y = tempTexCoords.tl_y;
			textureCoordinates[0].tr_x = tempTexCoords.tr_x;
			textureCoordinates[0].tr_y = tempTexCoords.tr_y;
			textureCoordinates[0].bl_x = tempTexCoords.bl_x;
			textureCoordinates[0].bl_y = tempTexCoords.bl_y;
			textureCoordinates[0].br_x = tempTexCoords.br_x;
			textureCoordinates[0].br_y = tempTexCoords.br_y;
			return;
		}
		
		if(flipVertically && flipHorizontally) {
			textureCoordinates[0].br_x = tempTexCoords.tl_x;
			textureCoordinates[0].br_y = tempTexCoords.tl_y;
			textureCoordinates[0].bl_x = tempTexCoords.tr_x;
			textureCoordinates[0].bl_y = tempTexCoords.tr_y;
			textureCoordinates[0].tr_x = tempTexCoords.bl_x;
			textureCoordinates[0].tr_y = tempTexCoords.bl_y;
			textureCoordinates[0].tl_x = tempTexCoords.br_x;
			textureCoordinates[0].tl_y = tempTexCoords.br_y;
			return;
		}
		
		if(flipHorizontally) {
			textureCoordinates[0].br_x = tempTexCoords.tr_x;
			textureCoordinates[0].br_y = tempTexCoords.tr_y;
			textureCoordinates[0].tr_x = tempTexCoords.br_x;
			textureCoordinates[0].tr_y = tempTexCoords.br_y;
			textureCoordinates[0].bl_x = tempTexCoords.tl_x;
			textureCoordinates[0].bl_y = tempTexCoords.tl_y;
			textureCoordinates[0].tl_x = tempTexCoords.bl_x;
			textureCoordinates[0].tl_y = tempTexCoords.bl_y;
			return;
		}
		
		if(flipVertically) {
			textureCoordinates[0].tr_x = tempTexCoords.tl_x;
			textureCoordinates[0].tr_y = tempTexCoords.tl_y;
			textureCoordinates[0].tl_x = tempTexCoords.tr_x;
			textureCoordinates[0].tl_y = tempTexCoords.tr_y;
			textureCoordinates[0].br_x = tempTexCoords.bl_x;
			textureCoordinates[0].br_y = tempTexCoords.bl_y;
			textureCoordinates[0].bl_x = tempTexCoords.br_x;
			textureCoordinates[0].bl_y = tempTexCoords.br_y;
			return;
		}
		
		if(flipVertically && flipHorizontally) {
			textureCoordinates[0].bl_x = tempTexCoords.tl_x;
			textureCoordinates[0].bl_y = tempTexCoords.tl_y;
			textureCoordinates[0].br_x = tempTexCoords.tr_x;
			textureCoordinates[0].br_y = tempTexCoords.tr_y;
			textureCoordinates[0].tl_x = tempTexCoords.bl_x;
			textureCoordinates[0].tl_y = tempTexCoords.bl_y;
			textureCoordinates[0].tr_x = tempTexCoords.br_x;
			textureCoordinates[0].tr_y = tempTexCoords.br_y;
			return;
		}
	}
}


- (void)calculateVerticesAtPoint:(CGPoint)aPoint subImageWidth:(GLuint)aSubImageWidth subImageHeight:(GLuint)aSubImageHeight centerOfImage:(BOOL)aCenter {
	
	// Calculate the width and the height of the quad using the current image scale and the width and height
	// of the image we are going to render
	double quadWidth = aSubImageWidth * scale;
	double quadHeight = aSubImageHeight * scale;
	
	// Define the vertices for each corner of the quad which is going to contain our image.
	// We calculate the size of the quad to match the size of the subimage which has been defined.
	// If center is true, then make sure the point provided is in the center of the image else it will be
	// the bottom left hand corner of the image
	if(aCenter) {
		vertices[0].bl_x = aPoint.x + -quadWidth / 2;
		vertices[0].bl_y = aPoint.y + -quadHeight / 2;
		
		vertices[0].br_x = aPoint.x + quadWidth / 2;
		vertices[0].br_y = aPoint.y + -quadHeight / 2;
        
		vertices[0].tl_x = aPoint.x + -quadWidth / 2;
		vertices[0].tl_y = aPoint.y + quadHeight / 2;
        
		vertices[0].tr_x = aPoint.x + quadWidth / 2;
		vertices[0].tr_y = aPoint.y + quadHeight / 2;
	} else {
		vertices[0].bl_x = vertices[0].br_x = vertices[0].tl_x = vertices[0].tr_x = aPoint.x;
		vertices[0].bl_y = aPoint.y;
		vertices[0].bl_y = vertices[0].br_y = vertices[0].tl_y = vertices[0].tr_y = aPoint.y;
		
		vertices[0].br_x += quadWidth;
        
		vertices[0].tl_y += quadHeight;
        
		vertices[0].tr_x += quadWidth;
		vertices[0].tr_y += quadHeight;
	}				
}


- (void)renderToVerticesAtPoint:(CGPoint)aPoint centerOfImage:(BOOL)aCenter {
	CGPoint offsetPoint = CGPointMake(textureOffsetX, textureOffsetY);
	
	// Populate the vertices and textureCoordinates arrays for this image.
	[self calculateVerticesAtPoint:aPoint subImageWidth:imageWidth subImageHeight:imageHeight centerOfImage:aCenter];
	[self calculateTexCoordsAtOffset:offsetPoint subImageWidth:imageWidth subImageHeight:imageHeight];
}


- (void)renderAtPoint:(CGPoint)aPoint centerOfImage:(BOOL)aCenter {
	
	// Use the textureOffset defined for X and Y along with the texture width and height to render the texture
	CGPoint offsetPoint = CGPointMake(textureOffsetX, textureOffsetY);
	
	// Calculate the vertex and texcoord values for this image
	[self calculateVerticesAtPoint:aPoint subImageWidth:imageWidth subImageHeight:imageHeight centerOfImage:aCenter];
	[self calculateTexCoordsAtOffset:offsetPoint subImageWidth:imageWidth subImageHeight:imageHeight];
	
	// Now that we have defined the texture coordinates and the quad vertices we can render to the screen 
	// using them
	[self renderAt:aPoint texCoords:textureCoordinates quadVertices:vertices];
}


- (void)renderSubImageAtPoint:(CGPoint)aPoint offset:(CGPoint)aOffsetPoint subImageWidth:(GLfloat)aSubImageWidth subImageHeight:(GLfloat)subImageHeight centerOfImage:(BOOL)aCenter {
	
	// Calculate the vertex and textureCoordinate values for this image
	[self calculateVerticesAtPoint:aPoint subImageWidth:aSubImageWidth subImageHeight:subImageHeight centerOfImage:aCenter];
	[self calculateTexCoordsAtOffset:aOffsetPoint subImageWidth:aSubImageWidth subImageHeight:subImageHeight];
	
	// Now that we have defined the texture coordinates and the quad vertices we can render to the screen 
	// using them
	[self renderAt:aPoint texCoords:textureCoordinates quadVertices:vertices];
}


- (void)renderAt:(CGPoint)point texCoords:(EGQuad2f*)tc quadVertices:(EGQuad2f*)qv {
    
	// Save the current matrix to the stack
	glPushMatrix();
	
	// Rotate around the Z axis by the angle defined for this image
    glTranslatef(point.x, point.y, 0);
	glRotatef(-rotation, 0.0f, 0.0f, 1.0f);
	glTranslatef(-point.x, -point.y, 0);
	
	// Set the glColor to apply alpha to the image.  This takes into account the gloabl alpha which is managed
	// by the sharedDirector.  This allows us to fade all objects based on the global alpha
    
    //NSLog(@"R: %f G: %f B: %f , A: %f",_colorfilter.red, _colorfilter.green, _colorfilter.blue, _colorfilter.alpha);
	glColor4f(_colorfilter.red, _colorfilter.green, _colorfilter.blue, _colorfilter.alpha * [_director globalAlpha]);
	
	// Set client states so that the Texture Coordinate Array will be used during rendering
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	// Enable Texture_2D
	glEnable(GL_TEXTURE_2D);
	
	// Bind to the texture that is associated with this image.  This should only be done if the
	// texture is not currently bound
    // NSLog(@"%d",[texture name]);
	if([texture name] != [_director currentlyBoundTexture]) {
        NSLog(@"%d",[texture name]);
		[_director setCurrentlyBoundTexture:[texture name]];
		glBindTexture(GL_TEXTURE_2D, [texture name]);
	}
	
	// Set up the VertexPointer to point to the vertices we have defined
	glVertexPointer(2, GL_FLOAT, 0, qv);
	
	// Set up the TexCoordPointer to point to the texture coordinates we want to use
	glTexCoordPointer(2, GL_FLOAT, 0, tc);
	
	// Enable blending as we want the transparent parts of the image to be transparent
	glEnable(GL_BLEND);
	
	// Setup how the images are to be blended when rendered.  The setup below is the most common
	// config and handles transparency in images
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	
	// Draw the vertices to the screen
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	// Now we are done drawing disable blending
	glDisable(GL_BLEND);
	
	// Disable as necessary
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	// Restore the saved matrix from the stack
	glPopMatrix();
}


- (void)setColourFilterRed:(GLfloat)aRed green:(GLfloat)aGreen blue:(GLfloat)aBlue alpha:(GLfloat)alpha {
	_colorfilter.red = aRed;
	_colorfilter.green = aGreen;
	_colorfilter.blue = aBlue;
	_colorfilter.alpha = alpha;
}


- (void)setAlpha:(GLfloat)aAlpha {
	_colorfilter.alpha = aAlpha;
}

@end
