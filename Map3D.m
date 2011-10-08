//
//  Map3D.m
//  EG-TD
//
//  Created by Gurcan Yavuz on 10/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Map3D.h"


#pragma mark -
#pragma mark Private interface

@interface Map3D (Private)
//Init map vertices
-(void)initMap;

@end

@implementation Map3D

@synthesize mapWidth;
@synthesize mapHeight;

- (id)initMap3D {
	
	self = [super init];
	if (self != nil) {
		
		// Shared game state
		sharedDirector = [Director sharedDirector];
        
        [self initMap];

	}
	return self;
}


- (void)render{
    
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
    glPushMatrix();
    
 
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
  
    glPopMatrix();
}


@end


@implementation Map3D (Private)

-(void)initMap{

    // Generate the floors vertices
    GLfloat z = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        zFloorVertices[index].x = -1.0;
        zFloorVertices[index].y = -20.0;
        zFloorVertices[index].z = z;
        
        zFloorVertices[index+1].x = -1.0;
        zFloorVertices[index+1].y = 20.0;
        zFloorVertices[index+1].z = z;
        
        z += 2.0f;
    }
    
    GLfloat x = -20.0f;
    for (uint index=0; index < 81; index += 2) {
        xFloorVertices[index].x = -1;
        xFloorVertices[index].y = x;
        xFloorVertices[index].z = -20.0f;
        
        xFloorVertices[index+1].x = -1;
        xFloorVertices[index+1].y = x;
        xFloorVertices[index+1].z = 20;
        
        x += 2.0f;
    }


}

@end