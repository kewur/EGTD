//
//  glu.h
//  RayPicking Sample
//
//  Created by Nova-Box on 5/24/10.
//
//  This document contains programming examples.
//  
//  Nova-box grants you a nonexclusive copyright license to use all programming code examples 
//  from which you can generate similar function tailored to your own specific needs.
//  
//  All sample code is provided by Nova-box for illustrative purposes only. 
//  These examples have not been thoroughly tested under all conditions. 
//  Nova-box, therefore, cannot guarantee or imply reliability, serviceability, or function of these programs.
//  
//  All programs contained herein are provided to you "AS IS" without any warranties of any kind. 
//  The implied warranties of non-infringement, merchantability and fitness for a particular purpose are expressly disclaimed.

#ifndef _GLU_H_
#define _GLU_H_

#include <OpenGLES/ES1/gl.h>

GLint gluUnProject(GLfloat winx, GLfloat winy, GLfloat winz,
				   const GLfloat model[16], const GLfloat proj[16],
				   const GLint viewport[4],
				   GLfloat * objx, GLfloat * objy, GLfloat * objz);
void transform_point(GLfloat out[4], const GLfloat m[16], const GLfloat in[4]);
void matmul(GLfloat * product, const GLfloat * a, const GLfloat * b);
int invert_matrix(const GLfloat * m, GLfloat * out);
#endif