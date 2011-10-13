//
//  EG_TDViewController.m
//  EG-TD
//
//  Created by metin okur on 16.09.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EG_TDViewController.h"
#import "CommonOpenGL.h"
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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    //These initilasiers must be below under the init for memory problems
    _director = [Director sharedDirector];
    
    // Initialize the game states and add them to the Director class
    AbstractScene *scene = [[GameScene alloc] init];
    [_director addSceneWithKey:@"game" scene:scene];
    [scene release];
    
    // Set the initial game state
    [_director setCurrentSceneToSceneWithKey:@"game"];
    [[_director currentScene] setSceneState:kSceneState_Idle];
    
    return self;
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
    
    [_director dealloc];
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
    //We put map into Map3D
  
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
   [[_director currentScene] updateWithDelta:aDelta];
}


- (void)drawFrame
{
    
    [(EAGLView *)self.view setFramebuffer];
  
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [[_director currentScene] render];

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

#pragma mark -
#pragma mark Touches

// Pass on all touch events to the game controller including a reference to this view so we can get data
// about this view if necessary
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	[[_director currentScene] updateWithTouchLocationBegan:touches withEvent:event view:(EAGLView *)self.view ];
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
	[[_director currentScene] updateWithTouchLocationMoved:touches withEvent:event view:(EAGLView *)self.view];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	[[_director currentScene] updateWithTouchLocationEnded:touches withEvent:event view:(EAGLView *)self.view];
}


@end
