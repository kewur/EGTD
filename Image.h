//
//  Image.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CommonOpenGL.h"
#import "Texture2D.h"
#import "Director.h"
#import "ResourceManager.h"


// This Image class is used to wrap the Texture2D class.  It provides our own methods to render the texture to the
// screen as well as being able to rotate and scale the image.  Below is an explanation of how we use texture 
// coordinates to only render the part of the texture returned by Texture2D we are interested in.
// 
// When Texture2D takes an image and turns it into a texture, it makes sure that the texture is ^2.  Using the player.png
// image from our current example, it means that the texture created is 64x128px.  Within this texture our player.png 
// image is 48x71px.  This is shown in the diagram below:
// 
//			   imageWidth
//			   48px
//             |------|
// 
//        -    +------+---+   -
// image  !    |iiiiii|   |   !
// Height !    |iiiiii|   |   !
// 71px   !    |iiiiii|   |   ! textureHeight
//        -    +------+   |   ! 128px
//			   |          |   ! 
//			   |          |   !
//			   +----------+   -
// 
//			   |----------|
//			   textureWidth
//			   64px
// 
// Texture coordinates in OpenGL are defined from 0.0 to 1.0 so within the texture above an x texture coordinate of 
// 1.0f would be 64px and a y texture coordinate of 1.0f would be 128px.  We can use this information to calculate
// the texture coordinates we need to use to make sure that just our image 48x71 is used when rendering the texture
// into our quad.  The calculation we use is:
// 
//		maxTexWidth = width / textureWidth;
//		maxTexHeight = height / textureHeight;
// 
// For our example image the result would be
// 
//		maxTexWidth = 48 / 64 = 0.750000
//		maxTexHeight = 71 / 128 = 0.554688
// 
// We then use these values within the methods that draw the image so that only the image within the texture is
// used and none of the blank texture is used.  We can use this same approach to select images from a sprite 
// sheet or texture atlas.
//
@interface Image : NSObject {
	
@private
	Director        *_director;
    ResourceManager *_resourceManager;
   	EGColor			_colorfilter;
    
@protected
	NSString        *imageName;
	Texture2D		*texture;	
	NSUInteger		imageWidth;
	NSUInteger		imageHeight;
	NSUInteger		textureWidth;
	NSUInteger		textureHeight;
	float			maxTexWidth;
	float			maxTexHeight;
	float			texWidthRatio;
	float			texHeightRatio;
	NSUInteger		textureOffsetX;
	NSUInteger		textureOffsetY;
	float			rotation;
	float			scale;
    uint            filter;
	BOOL			flipHorizontally;
	BOOL			flipVertically;
	EGQuad2f			*vertices;
	EGQuad2f			*textureCoordinates;
    EGColor         *colours;
	GLushort		*indices;
	CGPoint         lastTextureOffset;
}

@property(nonatomic, readonly) NSString *imageName;
@property(nonatomic, readonly) Texture2D *texture;
@property(nonatomic) NSUInteger imageWidth;
@property(nonatomic) NSUInteger imageHeight;
@property(nonatomic, readonly) NSUInteger textureWidth;
@property(nonatomic, readonly) NSUInteger textureHeight;
@property(nonatomic, readonly) float texWidthRatio;
@property(nonatomic, readonly) float texHeightRatio;
@property(nonatomic) NSUInteger textureOffsetX;
@property(nonatomic) NSUInteger textureOffsetY;
@property(nonatomic) float rotation;
@property(nonatomic) float scale;
@property(nonatomic) BOOL flipVertically;
@property(nonatomic) BOOL flipHorizontally;
@property(nonatomic) EGQuad2f *vertices;
@property(nonatomic) EGQuad2f *textureCoordinates;

// Returns an Image instance which has been created using an image called |aImage|.  The returned
// image has the default scale and filter.
- (id)initWithImage:(NSString*)aImage;

// Returns an Image instance which has been created using an image called |aImage|.  The returned
// image has the default scale and the filter which was supplied.
- (id)initWithImage:(NSString*)aImage filter:(GLenum)aFilter;

// Returns an Image instance which has been created using an image called |aImage|.  The returned
// image has the scale provided.
- (id)initWithImage:(NSString*)aImage scale:(float)aScale;

// Returns an Image instance which has been created using an image called |aImage|.  The returned
// image has the scale and filter provided
- (id)initWithImage:(NSString*)aImage scale:(float)aScale filter:(GLenum)aFilter;

// Method which returns a new Image instance.  The returned image is configured to render only part of
// the original image.  The part of the image to be rendered is based on |aPoint| and then |aImageWidth|
// and |aImageHeight|.  The image will also be scaled using |aScale|.
- (Image*)getSubImageAtPoint:(CGPoint)aPoint subImageWidth:(GLuint)aImageWidth subImageHeight:(GLuint)aImageHeight scale:(float)aScale;

// Method which returns a new Image instance that is an exact copy of this Image instance but with the
// specified scale.
- (Image*)copyImageAtScale:(float)aScale;

// Renders the Image at |aPoint|.  If |aCenter| is yes then then |aPoint| is taken to be the center of
// the image.
- (void)renderAtPoint:(CGPoint)aPoint centerOfImage:(BOOL)aCenter;

// Renders a sub portion of this image at |aPoint|.  The sub image to be rendered is defined using |aOffsetPoint|,
// |aSubImageWidth| and |aSubImageHeight|.  If |aCenter| is yes then |aPoint| is taken to be the center of the image.
- (void)renderSubImageAtPoint:(CGPoint)aPoint offset:(CGPoint)aOffsetPoint subImageWidth:(GLfloat)aSubImageWidth subImageHeight:(GLfloat)aSubImageHeight centerOfImage:(BOOL)aCenter;

// Method which populates the vertices and textureCoordinates arrays for this image based on the images
// current configuration.
- (void)renderToVerticesAtPoint:(CGPoint)aPoint centerOfImage:(BOOL)aCenter;

// Method to populate the images vertices array.  This method can take a point, width and height which will
// be used when the vertices are calculted.  This basically defines the Quad which will be used when
// rendering the image.
- (void)calculateVerticesAtPoint:(CGPoint)aPoint subImageWidth:(GLuint)aSubImageWidth subImageHeight:(GLuint)aSubImageHeight centerOfImage:(BOOL)aCenter;

// Method to populte the textureCoordinates array.  This method takes a point, width and height which is used 
// to calculate the area of the images texture that wil be rendered within the images quad.
- (void)calculateTexCoordsAtOffset:(CGPoint)aOffsetPoint subImageWidth:(int)aSubImageWidth subImageHeight:(int)aSubImageHeight;

// Method used to set the colour filter for this image.
- (void)setColourFilterRed:(GLfloat)aRed green:(GLfloat)aGreen blue:(GLfloat)aBlue alpha:(GLfloat)aAlpha;

// Method used to set the alpha component of the colour filter for this image.
- (void)setAlpha:(GLfloat)aAlpha;

@end

