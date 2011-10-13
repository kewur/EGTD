//
//  CommonOpenGL.h
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/ES1/gl.h>

#pragma mark -
#pragma mark Debug

//#define DEBUG 0

#pragma mark -
#pragma mark Macros

// Macro which returns a random value between -1 and 1
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

// MAcro which returns a random number between 0 and 1
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

// Macro which converts degrees into radians
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)


//Map Change accelerometer
#define kMapAcceloremeter 0.001

#pragma mark -
#pragma mark Enumerations

enum {
	kControlType_NewGame,
	kControlType_Settings,
	kControlType_HighScores,
	kControlType_QuitGame,
	kControlType_PauseGame,
	kControl_Idle,
	kControl_Scaling,
	kControl_Selected,
	kGameState_Running,
	kGameState_Paused,
	kGameState_Loading,
	kSceneState_Idle,
	//kSceneState_TransitionIn,
	//kSceneState_TransitionOut,
	kSceneState_Running,
	kSceneState_Paused
};


#pragma mark -
#pragma mark Structures

// Strcuture used to hold 3D color information
typedef struct {
    float red;
    float green;
    float blue;
    float alpha;
} EGColor;

// Structure used to hold 3D vertex information
typedef struct {
    GLfloat x;
    GLfloat y;
    GLfloat z;
} EGVertex3D;

typedef struct _Vector2f {
	GLfloat x;
	GLfloat y;
} EGVector2f;

typedef struct _Quad2f {
	GLfloat bl_x, bl_y;
	GLfloat br_x, br_y;
	GLfloat tl_x, tl_y;
	GLfloat tr_x, tr_y;
} EGQuad2f;

#pragma mark -
#pragma mark Color functions

// Returns an EGColor structure from the values passed in
static inline EGColor EGColorMake(GLfloat r, GLfloat g, GLfloat b, GLfloat a)
{
    EGColor newColor;
    newColor.red = r;
    newColor.green = g;
    newColor.blue = b;
    newColor.alpha = a;
    return newColor;
}

#pragma mark -
#pragma mark GLUT functions
#pragma mark -
#pragma mark Inline Functions

static const EGColor Color4fInit = {1.0f, 1.0f, 1.0f, 1.0f};

static const EGVertex3D Vector3fZero = {0.0f, 0.0f, 0.0f};

static inline EGVertex3D Vector3fMake(GLfloat x, GLfloat y, GLfloat z)
{
	return (EGVertex3D) {x, y, z};
}

static inline EGColor Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
	return (EGColor) {red, green, blue, alpha};
}

static inline EGVertex3D Vector3fMultiply(EGVertex3D v, GLfloat s)
{
	return (EGVertex3D) {v.x * s, v.y * s, v.z * s};
}

static inline EGVertex3D Vector3fAdd(EGVertex3D v1, EGVertex3D v2)
{
	return (EGVertex3D) {v1.x + v2.x , v1.y + v2.y, v1.z + v2.z};
}

static inline EGVertex3D Vector3fSub(EGVertex3D v1, EGVertex3D v2)
{
	return (EGVertex3D) {v1.x - v2.x, v1.y - v2.y, v1.z - v2.z};
}

static inline GLfloat Vector3fDot(EGVertex3D v1, EGVertex3D v2)
{
	return (GLfloat) v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

static inline GLfloat Vector3fLength(EGVertex3D v)
{
	return (GLfloat) sqrtf(Vector3fDot(v, v));
}

static inline EGVertex3D Vector3fNormalize(EGVertex3D v)
{
	return Vector3fMultiply(v, 1.0f/Vector3fLength(v));
}


static inline void __gluMakeIdentityf(GLfloat m[16])
{
    m[0+4*0] = 1; m[0+4*1] = 0; m[0+4*2] = 0; m[0+4*3] = 0;
    m[1+4*0] = 0; m[1+4*1] = 1; m[1+4*2] = 0; m[1+4*3] = 0;
    m[2+4*0] = 0; m[2+4*1] = 0; m[2+4*2] = 1; m[2+4*3] = 0;
    m[3+4*0] = 0; m[3+4*1] = 0; m[3+4*2] = 0; m[3+4*3] = 1;
}

static inline void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
    GLfloat m[4][4];
    GLfloat sine, cotangent, deltaZ;
    GLfloat radians = fovy / 2 * 3.14 / 180;
    
    deltaZ = zFar - zNear;
    sine = sin(radians);
    if ((deltaZ == 0) || (sine == 0) || (aspect == 0))
    {
        return;
    }
    cotangent = cos(radians) / sine;
    
    __gluMakeIdentityf(&m[0][0]);
    m[0][0] = cotangent / aspect;
    m[1][1] = cotangent;
    m[2][2] = -(zFar + zNear) / deltaZ;
    m[2][3] = -1;
    m[3][2] = -2 * zNear * zFar / deltaZ;
    m[3][3] = 0;
    glMultMatrixf(&m[0][0]);
}

// This is a modified version of the function of the same name from 
// the Mesa3D project ( http://mesa3d.org/ ), which is  licensed
// under the MIT license, which allows use, modification, and 
// redistribution
static inline void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
							 GLfloat centerx, GLfloat centery, GLfloat centerz,
							 GLfloat upx, GLfloat upy, GLfloat upz)
{
	GLfloat m[16];
	GLfloat x[3], y[3], z[3];
	GLfloat mag;
	
	/* Make rotation matrix */
	
	/* Z vector */
	z[0] = eyex - centerx;
	z[1] = eyey - centery;
	z[2] = eyez - centerz;
	mag = sqrtf(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
	if (mag) {			/* mpichler, 19950515 */
		z[0] /= mag;
		z[1] /= mag;
		z[2] /= mag;
	}
	
	/* Y vector */
	y[0] = upx;
	y[1] = upy;
	y[2] = upz;
	
	/* X vector = Y cross Z */
	x[0] = y[1] * z[2] - y[2] * z[1];
	x[1] = -y[0] * z[2] + y[2] * z[0];
	x[2] = y[0] * z[1] - y[1] * z[0];
	
	/* Recompute Y = Z cross X */
	y[0] = z[1] * x[2] - z[2] * x[1];
	y[1] = -z[0] * x[2] + z[2] * x[0];
	y[2] = z[0] * x[1] - z[1] * x[0];
	
	/* mpichler, 19950515 */
	/* cross product gives area of parallelogram, which is < 1.0 for
	 * non-perpendicular unit-length vectors; so normalize x, y here
	 */
	
	mag = sqrtf(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
	if (mag) {
		x[0] /= mag;
		x[1] /= mag;
		x[2] /= mag;
	}
	
	mag = sqrtf(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
	if (mag) {
		y[0] /= mag;
		y[1] /= mag;
		y[2] /= mag;
	}
	
#define M(row,col)  m[col*4+row]
	M(0, 0) = x[0];
	M(0, 1) = x[1];
	M(0, 2) = x[2];
	M(0, 3) = 0.0;
	M(1, 0) = y[0];
	M(1, 1) = y[1];
	M(1, 2) = y[2];
	M(1, 3) = 0.0;
	M(2, 0) = z[0];
	M(2, 1) = z[1];
	M(2, 2) = z[2];
	M(2, 3) = 0.0;
	M(3, 0) = 0.0;
	M(3, 1) = 0.0;
	M(3, 2) = 0.0;
	M(3, 3) = 1.0;
#undef M
	glMultMatrixf(m);
	
	/* Translate Eye to Origin */
	glTranslatef(-eyex, -eyey, -eyez);
	
}




//FOR BUILT MENU ORTHOGONAL PROJECTIONS
static inline void switchToOrtho ()
{
   CGRect bounds=  [[UIScreen mainScreen] bounds];
    
    glDisable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrthof(0, bounds.size.width, 0, bounds.size.height, -5, 1);       
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

//RETURN THE MAIN GAME SCREEN
static inline void switchBackToFrustum() 
{
    glEnable(GL_DEPTH_TEST);
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    glMatrixMode(GL_MODELVIEW);
}

