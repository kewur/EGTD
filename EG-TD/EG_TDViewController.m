//
//  EG_TDViewController.m
//  EG-TD
//
//  Created by metin okur on 16.09.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EG_TDViewController.h"
#import "EAGLView.h"
//TEST


@interface EG_TDViewController ()
@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;

//General initialization of openGL make ready to render in 3D
- (void)initOpenGLES1;

// Init the game objects and ivars
- (void)initGame;

// Update the scene
- (void)updateWithDelta:(float)aDelta;

// Render the scene
- (void)drawFrame;

// Manages the game loop and as called by the displaylink
- (void)gameLoop;
@end

@implementation EG_TDViewController

@synthesize animating, context, displayLink;

- (void)awakeFromNib
{
   // EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //To work on iPhone 3G we must make it opengl ES version 1 
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
  /*  if (!aContext) {
        aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    }
   
  */
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
 //   if ([context API] == kEAGLRenderingAPIOpenGLES2)
 //       [self loadShaders];
    
    animating = FALSE;
    animationFrameInterval = 1;
    self.displayLink = nil;
    
    // Init game
    [self initGame];
}

- (void)dealloc
{
    //Not going to use "program"
    /*   if (program) {
        glDeleteProgram(program);
        program = 0;
    }
    */   
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    // Init OpenGL ES 1
    // It can change later
    [self initOpenGLES1];
    
    [self startAnimation];
 
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];
	
    //Not going to use "program"
    /*   if (program) {
     glDeleteProgram(program);
     program = 0;
     }
     */   

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1) {
        animationFrameInterval = frameInterval;
        
        if (animating) {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
    if (!animating) {
        //drawFrame change to gameLoop because we are going to drawFrame only draw
        CADisplayLink *aDisplayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(gameLoop)];
        [aDisplayLink setFrameInterval:animationFrameInterval];
        [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        self.displayLink = aDisplayLink;
      
        animating = TRUE;
    }
}

- (void)initGame
{
    // Generate the floors vertices
    GLfloat z = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        zFloorVertices[index].x = -20.0;
        zFloorVertices[index].y = -1;
        zFloorVertices[index].z = z;
        
        zFloorVertices[index+1].x = 20.0;
        zFloorVertices[index+1].y = -1;
        zFloorVertices[index+1].z = z;
        
        z += 2.0f;
    }
    
    GLfloat x = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        xFloorVertices[index].x = x;
        xFloorVertices[index].y = -1;
        xFloorVertices[index].z = -20.0f;
        
        xFloorVertices[index+1].x = x;
        xFloorVertices[index+1].y = -1;
        xFloorVertices[index+1].z = 20;
        
        x += 2.0f;
    }
  
}


- (void)stopAnimation
{
    if (animating) {
        [self.displayLink invalidate];
        self.displayLink = nil;
        animating = FALSE;
    }
}

#pragma mark -
#pragma mark Game Loop

#define MAXIMUM_FRAME_RATE 90.0f
#define MINIMUM_FRAME_RATE 30.0f
#define UPDATE_INTERVAL (1.0 / MAXIMUM_FRAME_RATE)
#define MAX_CYCLES_PER_FRAME (MAXIMUM_FRAME_RATE / MINIMUM_FRAME_RATE)

- (void)gameLoop 
{
	static double lastFrameTime = 0.0f;
	static double cyclesLeftOver = 0.0f;
	double currentTime;
	double updateIterations;
	
	// Apple advises to use CACurrentMediaTime() as CFAbsoluteTimeGetCurrent() is synced with the mobile
	// network time and so could change causing hiccups.
	currentTime = CACurrentMediaTime();
	updateIterations = ((currentTime - lastFrameTime) + cyclesLeftOver);
	
	if(updateIterations > (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL))
		updateIterations = (MAX_CYCLES_PER_FRAME * UPDATE_INTERVAL);
	
	while (updateIterations >= UPDATE_INTERVAL) 
    {
		updateIterations -= UPDATE_INTERVAL;
		
		// Update the game logic passing in the fixed update interval as the delta
		[self updateWithDelta:UPDATE_INTERVAL];		
	}
	
	cyclesLeftOver = updateIterations;
	lastFrameTime = currentTime;
    
    // Render the frame
    [self drawFrame];
}

#pragma mark -
#pragma mark Update

- (void)updateWithDelta:(float)aDelta
{
    angle += 0.5f;
}


- (void)drawFrame
{
    
    [(EAGLView *)self.view setFramebuffer];
    
    // Replace the implementation of this method to do your own custom drawing.
    static const GLfloat squareVertices[] = {
        -0.33f, -0.33f, 0.0f,
        0.33f, -0.33f, 0.0f,
        -0.33f,  0.33f, 0.0f,
        0.33f,  0.33f, 0.0f
    };
    
    static const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // Position the camera back from the origin and slightly raised i.e. {0, 3, -6}
    static GLfloat z = 0;
    gluLookAt(-5, 0, -10, 0, 0, 0, 0, 1, 0);
    z += 0.075f;
    
    // Rotate the scene
    glRotatef(90, 0, 0, 1);
    
    // Set the color to be used when drawing the lines
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    
    // Disable the color array as we want the grid to be all white
    glDisableClientState(GL_COLOR_ARRAY);
    
    // Enable the Vertex Array so that the vervices held in the vertex
    // arrays that have been set up can be used to render the grid lines.
    glEnableClientState(GL_VERTEX_ARRAY);
    
    // Point to the array defining the horizontal line vertices and render them
    glVertexPointer(3, GL_FLOAT, 0, zFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    
    // Point to the array defining the vertical line vertices and render those as well
    glVertexPointer(3, GL_FLOAT, 0, xFloorVertices);
    glDrawArrays(GL_LINES, 0, 42);
    
    // Point to the array defining the vertices to draw the square
    glVertexPointer(3, GL_FLOAT, 0, squareVertices);
    
    // Point to the array defining the colors at each vertex in the squareVertices
    // array. This will give us a rainbow like fill to the square
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    
    // Enable the GL_COLOR_ARRAY so that OGL knows to use the colors from the squareColors array
    glEnableClientState(GL_COLOR_ARRAY);
    
    
    [(EAGLView *)self.view presentFramebuffer];
}


- (void)initOpenGLES1
{
    // Set the clear color
    glClearColor(0, 0, 0, 1.0f);
    
    // Projection Matrix config
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    CGSize layerSize = self.view.layer.frame.size;
    gluPerspective(45.0f, (GLfloat)layerSize.width / (GLfloat)layerSize.height, 0.1f, 750.0f);
    
    // Modelview Matrix config
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    
    // This next line is not really needed as it is the default for OpenGL ES
    glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_BLEND);
    
    // Enable depth testing
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    
}
@end
