//
//  Shader.fsh
//  EG-TD
//
//  Created by metin okur on 16.09.2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
