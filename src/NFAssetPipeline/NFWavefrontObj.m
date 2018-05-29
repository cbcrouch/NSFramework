//
//  NFWavefrontObj.m
//  NSFramework
//
//  Copyright (c) 2017 Casey Crouch. All rights reserved.
//

#import "NFWavefrontObj.h"
#import "NFAssetData+Wavefront.h"

#import "NFAssetUtils.h"


static NSString * const g_matPrefix = @"mtllib ";
//
// TODO: there also appears to be an "s " prefix in some obj files (smoothing group)
//       can also have "mg " (merging group)
//
static NSString * const g_objPrefix = @"o ";
static NSString * const g_groupPrefix = @"g ";
static NSString * const g_useMatPrefix = @"usemtl ";

static NSString * const g_vertPrefix = @"v ";
static NSString * const g_texPrefix = @"vt ";
static NSString * const g_normPrefix = @"vn ";

//
// TODO: should also parse @"t " as texture coordinate and @"n " as normal, not sure if this
//       is a part of the official spec be appears to be in use
//

// g_paramPrefix
static NSString * const g_facePrefix = @"f ";

//
// TODO: not sure if these are part of the official spec but they appear to be in use and
//       therefore should be supported since they won't interfere with anything else
//
// @"vs "    // number of vertices
// @"vts "   // number of vertex texture coordinates
// @"vns "   // number of vertex normals
// @"ts "    // number of texture coordinates
// @"ns "    // number of normals

//
// TODO: only need to encode a single type
//
static const char *g_vertexType = @encode(GLKVector3);
static const char *g_texType = @encode(GLKVector3);
static const char *g_normType = @encode(GLKVector3);

// g_paramType

GLKVector3 (^wfParseVector3)(NSString *, NSString *) = ^ GLKVector3 (NSString *line, NSString *prefix) {
    NSString *truncLine = [line substringFromIndex:prefix.length];
    NSArray *words = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    GLKVector3 vec3;
    for (int i=0; i<3; ++i) {
        vec3.v[i] = [words[i] floatValue];
    }
    return vec3;
};

//
//
//

@implementation WFObject

- (NSMutableArray *)groups {
    if (_groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    }
    return _groups;
}

/*
//
// TODO: pass in Wavefront obj center point
//
- (void) calculateTextureCoordinates {
    //
    // NOTE: not sure if applying a UV unwrapping algorithm to the model will be worthwhile, though
    //       it will flatten the model so it can easily be transformed into texture coordinate space,
    //       it most likely won't cleanly map the texture to the model (i.e. UV unwrapping is largely
    //       performed to allow artist to draw on a "flat" model surface)
    //

    NSUInteger vertexCount = self.vertices.count;
    for (WFGroup* group in self.groups) {
        NSAssert([[group faceStrArray] count] % 3 == 0, @"ERROR: face string array can only process triangles");
        NSMutableArray* faceStrings = group.faceStrArray;
        NSUInteger faceCount = faceStrings.count;

        BOOL hasNormals = NO;
        NSArray *groupParts = [faceStrings[0] componentsSeparatedByString:@"/"];
        for (NSInteger i=0; i<groupParts.count; ++i) {
            NSInteger intValue = [groupParts[i] integerValue];
            switch (i) {
                case kGroupIndexNorm: normalizeObjIndex(intValue, (self.normals).count);
                    hasNormals = YES;
                    break;
                default: break;
            }
        }

        for (int i=0; i<faceCount; ++i) {
            int index = -1;
            if (hasNormals) {
                index = [faceStrings[i] componentsSeparatedByString:@"/"][0].intValue;
            }
            else {
                index = [faceStrings[i] intValue];
            }
            index = (int)normalizeObjIndex(index, vertexCount);


            GLKVector3 vertex;
            NSValue *value = (self.vertices)[index];
            [value getValue:&vertex];

            // simple UV mapping algorithm (basically treat model as if it is spherical)
            // - calc center point of geometry
            // - for each vertex calc vector from center point to vertex
            // - normalize vector
            // - u = 0.5 + arctan2(vec.z, vec.x)/2pi
            // - v = 0.5 - arcsin(vec.y)/pi


            //GLKVector3 vec = GLKVector3Subtract(vertex, center);
            //vec = GLKVector3Normalize(vec);

            vertex = GLKVector3Normalize(vertex);


            //
            // TODO: use a cubemap for assets that don't have a texture or attempt to modify the geometry itself
            //       to allow for conincident vertices along the spherical edge used to generate texture coordinates
            //

            // (don't forget to enable GL_TEXTURE_CUBE_MAP_SEAMLESS if using a cubemap)


            // spherical coordinates as mapped to perspective coordiantes (x to the right, y up, +z towards the camera)
            // x = r * sin(phi) * sin(theta);
            // y = r * cos(phi);
            // z = r * sin(phi) * cos(theta);
            // phi   => [0, M_PI]    inclination (vertical angle)
            // theta => [0, 2*M_PI]  azimuth (horizontal angle)

            // theta = acos( y / sqrt(x^2 + y^2 + z^2) )
            // phi = atan( x/z )

            //float theta = acosf(vertex.y / sqrtf(powf(vertex.x, 2.0f) + powf(vertex.y, 2.0f) + powf(vertex.z, 2.0f)));
            //float phi = 0.5 + atan2f(vertex.x, vertex.z);

            GLKVector3 texCoord;
            texCoord.s = 0.5f + atan2f(vertex.z, vertex.x) / (2 * M_PI);
            texCoord.t = 0.5f - asin(vertex.y) / M_PI;
            texCoord.p = 0.0f;

            //
            // NOTE: this is the texture coordinate equation used in the UV sphere generation
            //
            //texCoord.s = phi / M_PI;
            //texCoord.t = theta / (2*M_PI);


            if (texCoord.s < 0.0f) {
                NSLog(@"s coord wrapped: %f", texCoord.s);
                texCoord.s = 0.0f;
            }
            else if (texCoord.s > 1.0f) {
                NSLog(@"s coord wrapped: %f", texCoord.s);
                texCoord.s = 1.0f;
            }

            if (texCoord.t < 0.0f) {
                NSLog(@"t coord wrapped: %f", texCoord.t);
                texCoord.t = 0.0f;
            }
            else if (texCoord.t > 1.0f) {
                NSLog(@"t coord wrapped: %f", texCoord.t);
                texCoord.t = 1.0f;
            }

            [self.textureCoords addObject:[NSValue value:&texCoord withObjCType:g_texType]];


            // face string formats:
            // v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3
            // v1/vt1 v2/vt2 v3/vt3 v4/vt4
            // v1//vn1 v2//vn2 v3//vn3
            if (hasNormals) {
                //
                // TODO: have not yet tested updating face strings that already contain normals
                //
                int normCoordIndex = [faceStrings[i] componentsSeparatedByString:@"/"][2].intValue;
                NSString* str = [NSString stringWithFormat:@"%d/%d/%d", index+1, normCoordIndex, (int)((self.textureCoords).count)];
                [group.faceStrArray setObject:str atIndexedSubscript:i];
            }
            else {
                NSString* str = [NSString stringWithFormat:@"%d/%d", index+1, (int)((self.textureCoords).count)];
                [group.faceStrArray setObject:str atIndexedSubscript:i];
            }
        }
    }
}


//
// TODO: should take a param that will determine whether to use area weighted normals or angle weighted normals
//
// enum
// - useFaceNormals
// - unbiasedVertexNormals
// - surfaceAreaWeightedVertexNormals
// - faceAngleWeightedVertexNormals
// - areaAndAngleWeightedVertexNormals


//
// TODO: integrate calculateTextureCoorindates and calculateNormals back into the codebase
//

- (void) calculateNormals {
    //
    // NOTE: Wavefront obj normals are per-vertex
    //
    NSUInteger vertexCount = self.vertices.count;
    NFVertex_t vertexArray[vertexCount];
    for (int i=0; i<vertexCount; ++i) {
        GLKVector3 vert;
        [self.vertices[i] getValue:&vert];
        vertexArray[i].pos[0] = vert.x;
        vertexArray[i].pos[1] = vert.y;
        vertexArray[i].pos[2] = vert.z;
        vertexArray[i].pos[3] = 1.0f;
    }

    float (^normalizeFloatZero)(float) = ^ float (float floatValue) {
        if (floatValue < FLT_EPSILON && floatValue > -FLT_EPSILON) {
            if (signbit(floatValue)) {
                floatValue *= -1.0f;
            }
        }
        return floatValue;
    };

    for (WFGroup* group in self.groups) {
        NSAssert([[group faceStrArray] count] % 3 == 0, @"ERROR: face string array can only process triangles");

        NSMutableArray* faceStrings = group.faceStrArray;
        NSUInteger faceCount = faceStrings.count;

        //
        // NOTE: test one face to see if it contains a texture coordinate, doing this rather than checking if
        //       self.textureCoords count > 0 since it is possible that one group will have texture coordinates
        //       and another will not
        //
        BOOL hasTextureCoordinates = NO;
        NSArray *groupParts = [faceStrings[0] componentsSeparatedByString:@"/"];
        for (NSInteger i=0; i<groupParts.count; ++i) {
            NSInteger intValue = [groupParts[i] integerValue];
            switch (i) {
                case kGroupIndexTex: normalizeObjIndex(intValue, (self.textureCoords).count);
                    hasTextureCoordinates = YES;
                    break;
                default: break;
            }
        }

        int faceIndex = 0;

        // calculate face normals
        NFFace_t faceArray[faceCount / 3];
        for (int i=0; i<faceCount; i+=3) {
            int index1 = -1;
            int index2 = -1;
            int index3 = -1;
            if (hasTextureCoordinates) {
                index1 = [faceStrings[i] componentsSeparatedByString:@"/"][0].intValue;
                index2 = [faceStrings[i + 1] componentsSeparatedByString:@"/"][0].intValue;
                index3 = [faceStrings[i + 2] componentsSeparatedByString:@"/"][0].intValue;
            }
            else {
                index1 = [faceStrings[i] intValue];
                index2 = [faceStrings[i + 1] intValue];
                index3 = [faceStrings[i + 2] intValue];
            }
            index1 = (int)normalizeObjIndex(index1, vertexCount);
            index2 = (int)normalizeObjIndex(index2, vertexCount);
            index3 = (int)normalizeObjIndex(index3, vertexCount);

            GLushort indices[3];
            indices[0] = (GLushort)index1;
            indices[1] = (GLushort)index2;
            indices[2] = (GLushort)index3;

            faceArray[faceIndex] = [NFAssetUtils calculateFaceWithPoints:vertexArray withIndices:indices];

            faceArray[faceIndex].normal[0] = normalizeFloatZero(faceArray[faceIndex].normal[0]);
            faceArray[faceIndex].normal[1] = normalizeFloatZero(faceArray[faceIndex].normal[1]);
            faceArray[faceIndex].normal[2] = normalizeFloatZero(faceArray[faceIndex].normal[2]);

            ++faceIndex;
        }

        // convert C face normals array into an NSArray so it can be used with NFAssetUtils vertex normal calculation
        static const char *faceType = @encode(NFFace_t);
        NSMutableArray* tempFaceNormals = [[NSMutableArray alloc] initWithCapacity:faceIndex];
        for (int i=0; i<faceIndex; ++i) {
            NSValue *value = [NSValue value:&(faceArray[i]) withObjCType:faceType];
            [tempFaceNormals addObject:value];
        }
        NSArray* faceNormals = [[NSArray alloc] initWithArray:tempFaceNormals];

        // calculate vertex normals and update Wavefront obj face
        for (int i=0; i<faceCount; ++i) {
            int index = -1;
            if (hasTextureCoordinates) {
                index = [faceStrings[i] componentsSeparatedByString:@"/"][0].intValue;
            }
            else {
                index = [faceStrings[i] intValue];
            }
            index = (int)normalizeObjIndex(index, vertexCount);

            // NOTE: currently only area weighted normals is implemented
            GLKVector4 vertexNormal = [NFAssetUtils calculateAreaWeightedNormalOfIndex:index withFaces:faceNormals];
            NSValue* value = [NSValue value:&vertexNormal withObjCType:g_vertexType];
            [self.normals addObject:value];

            // face string formats:
            // v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3
            // v1/vt1 v2/vt2 v3/vt3 v4/vt4
            // v1//vn1 v2//vn2 v3//vn3
            if (hasTextureCoordinates) {
                int texCoordIndex = [faceStrings[i] componentsSeparatedByString:@"/"][1].intValue;
                NSString* str = [NSString stringWithFormat:@"%d/%d/%d", index+1, texCoordIndex, (int)((self.normals).count)];
                [group.faceStrArray setObject:str atIndexedSubscript:i];
            }
            else {
                NSString* str = [NSString stringWithFormat:@"%d//%d", index+1, (int)((self.normals).count)];
                [group.faceStrArray setObject:str atIndexedSubscript:i];
            }
        }
    }
}
*/
@end

@implementation WFGroup

- (NSMutableArray *)vertices {
    if (_vertices == nil) {
        _vertices = [[NSMutableArray alloc] init];
    }
    return _vertices;
}

- (NSMutableArray *)textureCoords {
    if (_textureCoords == nil) {
        _textureCoords = [[NSMutableArray alloc] init];
    }
    return _textureCoords;
}

- (NSMutableArray *)normals {
    if (_normals == nil) {
        _normals = [[NSMutableArray alloc] init];
    }
    return _normals;
}

- (NSMutableArray *)faceStrArray {
    if (_faceStrArray == nil) {
        _faceStrArray = [[NSMutableArray alloc] init];
    }
    return _faceStrArray;
}

@end

//
//
//

@interface NFWavefrontObj()

+ (NSArray *) componentsFromWavefrontObjLine:(NSString *)line withPrefix:(NSString *)prefix;

+ (void) parseVertexArray:(NSArray *)vertexArray processedArray:(NSMutableArray *)vertices;
+ (void) parseTextureCoordArray:(NSArray *)texCoordArray processedArray:(NSMutableArray *)textureCoords;
+ (void) parseNormalVectorArray:(NSArray *)normVectorArray processedArray:(NSMutableArray *)normals;

@property (nonatomic, strong) NSString *objPath;
@property (nonatomic, strong) NSString *fileSource;
@property (nonatomic, strong) NSString *mtlSource;

@property (nonatomic, strong) WFObject *activeObject;
@property (nonatomic, strong) WFGroup *activeGroup;

- (void) parseMaterialFile:(NSString *)file;

//
// TODO: to forward declare or not forward declare ??
//
//- (void) parseFile;

@end

@implementation NFWavefrontObj

+ (NSArray *) componentsFromWavefrontObjLine:(NSString *)line withPrefix:(NSString *)prefix {
    // NOTE: there can be an indeterminant amount of white space after the prefix, need
    //       to remove leading and trailing whitespace as well as the prefix
    NSString *truncLine = [line substringFromIndex:prefix.length];

    // remove leading whitespace
    NSRange range = [truncLine rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    truncLine = [truncLine stringByReplacingCharactersInRange:range withString:@""];

    // remove trailing whitespace
    range = [truncLine rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
    truncLine = [truncLine stringByReplacingCharactersInRange:range withString:@""];

    NSArray* components = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    // NOTE: components separated by white space will include a "" string if there was more than one whitespace
    //       separating the text elements, these need to be filtered out, both of these should work
    NSArray* filtered = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
    //NSArray* filtered = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];

    return filtered;
}

+ (void) parseVertexArray:(NSArray *)vertexArray processedArray:(NSMutableArray *)vertices {
    // parse vertex
    GLKVector3 vertex;
    vertex.x = [vertexArray[0] floatValue];
    vertex.y = [vertexArray[1] floatValue];
    vertex.z = [vertexArray[2] floatValue];

    // add vertex to parent class NSAssetData
    NSValue *value = [NSValue value:&vertex withObjCType:g_vertexType];
    [vertices addObject:value];
}

+ (void) parseTextureCoordArray:(NSArray *)texCoordArray processedArray:(NSMutableArray *)textureCoords {
    // parse texture coord
    GLKVector3 texCoord;
    texCoord.s = [texCoordArray[0] floatValue];
    texCoord.t = [texCoordArray[1] floatValue];

    // if texture coordiante supports depth use it
    if (texCoordArray.count > 2) {
        texCoord.p = [texCoordArray[2] floatValue];
    }
    else {
        texCoord.p = 0.0f;
    }

    // add texture coord to parent NSAssetData
    NSValue *value = [NSValue value:&texCoord withObjCType:g_texType];
    [textureCoords addObject:value];
}

+ (void) parseNormalVectorArray:(NSArray *)normVectorArray processedArray:(NSMutableArray *)normals {
    // parse normal vector
    GLKVector3 normal;
    normal.x = [normVectorArray[0] floatValue];
    normal.y = [normVectorArray[1] floatValue];
    normal.z = [normVectorArray[2] floatValue];

    // add normal to parent NSAssetData
    NSValue *value = [NSValue value:&normal withObjCType:g_normType];
    [normals addObject:value];
}

- (NSMutableArray *)materialsArray {
    if (_materialsArray == nil) {
        _materialsArray = [[NSMutableArray alloc] init];
    }
    return _materialsArray;
}

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    _activeObject = nil;
    _activeGroup = nil;

    _object = [[WFObject alloc] init];
    return self;
}


- (void) loadFileWithPath:(NSString *)filePath { // currently used load method
    NSError *nsErr = nil;
    NSStringEncoding encoding;

    // record copy of obj path
    self.objPath = filePath.stringByDeletingLastPathComponent;

    // to remove file extension if needed
    //NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];

    // NOTE: it would appear that the NSString that is being pointed to is an autorelease object
    self.fileSource = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&nsErr];
    NSAssert(self.fileSource != nil, @"Failed to find path, error: %@", nsErr);

    [self parseFile];
}

//
// TODO: implement with bundle param
//
- (void) loadFile:(NSString *)fileName { // inBundle:(NSBundle)bundle
    NSString *filePathName = [[NSBundle mainBundle] pathForResource:fileName ofType:@"obj"];
    NSAssert(filePathName != nil, @"Failed to find path to %@.obj", fileName);

    //[self loadFileWithPath:filePathName];

    //
    // TODO: implement everything below to illustrate what stringWithContentsOfFile is doing for us
    //

    NSFileHandle *fileHandle;
    fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePathName];
    NSAssert(fileHandle != nil, @"Failed to open %@.obj", fileName);

    NSData *fileData = [fileHandle readDataToEndOfFile];
    NSAssert(fileData != nil, @"Failed to read NSFileHandle");

    // NOTE: this works with NON-NULL terminated data
    self.fileSource = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSAssert(self.fileSource != nil, @"Failed to convert NSData to an NSString");

    //
    // TODO: attempt to handle various string encodings
    //
/*
    // attempt to use all the string encodings
    const *NSStringEncoding = [NSString availableStringEncodings];

    NSData * urlData = [NSData dataWithContentsOfURL:aURL];
    NSString * theString = [[NSString alloc] initWithData:urlData encoding:NSASCIIStringEncoding];
    if (!theString) {
        theString = [[NSString alloc] initWithData:urlData encoding:NSUTF8StringEncoding];
    }
    if (!theString) {
        theString = [[NSString alloc] initWithData:urlData encoding:NSUTF16StringEncoding];
    }
    if (!theString) {
        theString = [[NSString alloc] initWithData:urlData NSWindowsCP1252StringEncoding];
    }
*/
    // at this point fileSource should have a copy of the NSData from the file read and the file can be closed
    [fileHandle closeFile];

    [self parseFile];
}

//
// TODO: profile and optimize the file parsing
//
- (void) parseFile { // should support better error handling e.g. error:(NSError *)err ??

    //
    // TODO: trim \r if using Windows CRLF format
    //

    NSArray *lines = [self.fileSource componentsSeparatedByString:@"\n"];

    // index set is for converting quads into triangles
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)];

    NSMutableArray *activeVertices = [[NSMutableArray alloc] init];
    NSMutableArray *activeTexCoords = [[NSMutableArray alloc] init];
    NSMutableArray *activeNormals = [[NSMutableArray alloc] init];

    for (NSString *line in lines) {

        //
        // TODO: to play it safe may want to consider converting to whole line to lower case, while
        //       the "official" spec seems to indicate case sensitivity but better safe than sorry
        //

        if ([line hasPrefix:g_matPrefix]) {
            NSString *path = [self.objPath stringByAppendingPathComponent:[line substringFromIndex:g_matPrefix.length]];
            [self parseMaterialFile:path];
        }
        else if ([line hasPrefix:g_objPrefix]) {

            //
            // TODO: only storing one object name for now, will need to eventually handle N
            //

            (self.object).objectName = [line substringFromIndex:g_objPrefix.length];
        }
        else if ([line hasPrefix:g_groupPrefix]) {
            NSString *groupName = [line substringFromIndex:g_groupPrefix.length];

            // allocate a new group (which will be the current active group) and add to object's group array
            self.activeGroup = [[WFGroup alloc] init];
            [self.object.groups addObject:self.activeGroup];

            // start populating the active group
            self.activeGroup.groupName = groupName;

            [self.activeGroup.vertices addObjectsFromArray:activeVertices];
            [self.activeGroup.textureCoords addObjectsFromArray:activeTexCoords];
            [self.activeGroup.normals addObjectsFromArray:activeNormals];

            [activeVertices removeAllObjects];
            [activeTexCoords removeAllObjects];
            [activeNormals removeAllObjects];

            NSLog(@"group name: %@", groupName);
        }
        else if ([line hasPrefix:g_useMatPrefix]) {
            NSString *matName = [line substringFromIndex:g_useMatPrefix.length];

            if (![matName isEqualToString:@"(null)"] && ![matName isEqualToString:@"null"]) {
                self.activeGroup.materialName = matName;
            }
            else {
                //
                // TODO: need a better mechanism for creating default objects and groups
                //
/*
                if (self.activeObject == nil) {
                    //
                    // TODO: allocate a new object (which will be the current active object) and add to the object array
                    //

                    //[self.object setObjectName:@"default_object"];
                }
*/

/*
                if (self.activeGroup == nil) {
                    // allocate a new group (which will be the current active group) and add to object's group array
                    self.activeGroup = [[WFGroup alloc] init];
                    [self.object.groups addObject:self.activeGroup];

                    //
                    // TODO: parse group name, if none exists then create a default one
                    //
                    self.activeGroup.groupName = @"default_group";

                    NSLog(@"group created when parsing material");
                }
*/

                //
                // TODO: textures need to be processed independently and managed through a texture cache
                //
                NFSurfaceModel *defaultSurface = [NFSurfaceModel defaultSurfaceModel];
                [self.materialsArray addObject:defaultSurface];

                self.activeGroup.materialName = defaultSurface.name;
            }
        }
        else if ([line hasPrefix:g_vertPrefix]) {

            //
            // TODO: if vertex, texture coordinate, or normal data is found after faces have been listed
            //       then create a new object or group (whatever makes the most sense and seems to comply
            //       with existing Wavefront Obj files)
            //

            NSArray *vertArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_vertPrefix];
            [NFWavefrontObj parseVertexArray:vertArray processedArray:activeVertices];
        }
        else if ([line hasPrefix:g_texPrefix]) {
            NSArray *texArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_texPrefix];
            [NFWavefrontObj parseTextureCoordArray:texArray processedArray:activeTexCoords];
        }
        else if ([line hasPrefix:g_normPrefix]) {
            NSArray *normArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_normPrefix];
            [NFWavefrontObj parseNormalVectorArray:normArray processedArray:activeNormals];
        }
        else if ([line hasPrefix:@"vp "]) {
            // TODO: add support for parameter space vertices
        }
        else if ([line hasPrefix:g_facePrefix]) {
            NSArray *faceIndexArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_facePrefix];

            if (self.activeObject == nil) {
                //
                // TODO: allocate a new object (which will be the current active object) and add to the object array
                //

                //[self.object setObjectName:@"default_object"];
            }

            if (self.activeGroup == nil) {
                // allocate a new group (which will be the current active group) and add to object's group array
                self.activeGroup = [[WFGroup alloc] init];
                [self.object.groups addObject:self.activeGroup];
                self.activeGroup.groupName = @"default_group";

                [self.activeGroup.vertices addObjectsFromArray:activeVertices];
                [self.activeGroup.textureCoords addObjectsFromArray:activeTexCoords];
                [self.activeGroup.normals addObjectsFromArray:activeNormals];

                [activeVertices removeAllObjects];
                [activeTexCoords removeAllObjects];
                [activeNormals removeAllObjects];
            }

            // check if face is a triangle or a quad (quads need to be converted into triangles)
            if (faceIndexArray.count == 3) {
                [self.activeGroup.faceStrArray addObjectsFromArray:faceIndexArray];
            }
            else if (faceIndexArray.count == 4) {
                // triangles per cube quad in Wavefront obj file
                // 0 1 2
                // 0 2 3

                // process first triangle
                NSArray *triangle = [faceIndexArray objectsAtIndexes:indexSet];
                [self.activeGroup.faceStrArray addObjectsFromArray:triangle];

                // process second triangle
                [indexSet shiftIndexesStartingAtIndex:1 by:1];
                triangle = [faceIndexArray objectsAtIndexes:indexSet];
                [self.activeGroup.faceStrArray addObjectsFromArray:triangle];

                // reset index set
                [indexSet shiftIndexesStartingAtIndex:2 by:-1];
            }
        }
    }
}

- (void) parseMaterialFile:(NSString *)file {
    NSError *nsErr = nil;
    NSStringEncoding encoding;

    //
    // TODO: don't need to save the material source, remove property
    //
    self.mtlSource = [NSString stringWithContentsOfFile:file usedEncoding:&encoding error:&nsErr];
    NSAssert(self.mtlSource != nil, @"Failed to find path, error: %@", nsErr);

    NSArray *lines = [self.mtlSource componentsSeparatedByString:@"\n"];

    BOOL matValid = NO;

    static NSString *g_newMatPrefix = @"newmtl "; // create a new struct of the given name

    // TODO: these are just the supported material params for the cube, there are more types in the spec
    static NSString *g_NsPrefix = @"Ns "; // specular coeff
    static NSString *g_NiPrefix = @"Ni "; // optical density (also known as index of refraction)
    //static NSString *g_dPrefix = @"d "; // disolve factor // not currently used in the cube file
    static NSString *g_TrPrefix = @"Tr "; // transparency
    static NSString *g_ilPrefix = @"illum "; // illumination model

    static NSString *g_KaPrefix = @"Ka "; // ambient color
    static NSString *g_KdPrefix = @"Kd "; // diffuse color
    static NSString *g_KsPrefix = @"Ks "; // specular color
    static NSString *g_KePrefix = @"Ke "; // emisive color

    static NSString *g_mapKdPrefix = @"map_Kd "; // diffuse color texture map=

    NFSurfaceModel *mat = [[NFSurfaceModel alloc] init];

    // need to use __strong qualifer to allow variables used in fast enumeration to be modified
    for (__strong NSString *line in lines) {

        //
        // TODO: will also need to handle leading tabs, should be able to update regex
        //       to find either leading whitespace or tabs
        //

        // remove any white space in the front of the line
        NSRange range = [line rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        line = [line stringByReplacingCharactersInRange:range withString:@""];

        if ([line hasPrefix:g_newMatPrefix]) {
            //if (matValid == YES) {
                //NSValue *value = [NSValue value:&mat withObjCType:g_matType];
                //[self.materials addObject:value];
            //}
            mat.name = [line substringFromIndex:g_newMatPrefix.length];
            matValid = YES;
        }
        else if ([line hasPrefix:g_NsPrefix]) {
            NSString *truncLine = [line substringFromIndex:g_NsPrefix.length];
            mat.Ns = truncLine.floatValue;
        }
        else if ([line hasPrefix:g_NiPrefix]) {
            NSString *truncLine = [line substringFromIndex:g_NiPrefix.length];
            mat.Ni = truncLine.floatValue;
        }
        else if ([line hasPrefix:g_TrPrefix]) {
            //NSString *truncLine = [line substringFromIndex:[g_TrPrefix length]];
            //NSArray *words = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            // Tr doesn't seem to be listed in any of the "formal" specs

            //
            // TODO: need to work out the ambiguity between "d" and "Tr" (should be dissolve factor and transparency)
            //

            // valid dissolve factor formats:
            // d factor
            // d -halo factor

            // examples:
            // d 1.0
            // d -halo 1.0
        }
        else if ([line hasPrefix:g_ilPrefix]) {
            NSString *truncLine = [line substringFromIndex:g_ilPrefix.length];
            mat.illum = truncLine.integerValue;

            //
            // TODO: will need to parse the illumination model definition when converting the
            //       Wavefront obj material into an NSAssetData object
            //

            // illumination model definition breakdown
            // 0: color on and ambient off
            // 1: color on and ambient on
            // 2: highlight on
            // 3: reflection on and ray trace on
            // 4: transparency: glass on // reflection: ray trace on
            // 5: reflection: fresnel on and ray trace on
            // 6: transparency: refraction on // reflection: fresnel off and ray trace on
            // 7 transparency: refraction on // reflection: fresnel on and ray trace on
            // 8: reflection on and ray trace off
            // 9: transparency: glass on // reflection: ray trace off
            // 10: casts shadows onto invisible surfaces
        }
        else if ([line hasPrefix:g_KaPrefix]) {
            mat.Ka = wfParseVector3(line, g_KaPrefix);
        }
        else if ([line hasPrefix:g_KdPrefix]) {
            mat.Kd = wfParseVector3(line, g_KdPrefix);
        }
        else if ([line hasPrefix:g_KsPrefix]) {
            mat.Ks = wfParseVector3(line, g_KsPrefix);
        }
        else if ([line hasPrefix:g_KePrefix]) {
            mat.Ke = wfParseVector3(line, g_KePrefix);
        }
        else if ([line hasPrefix:g_mapKdPrefix]) {
            NSString *mapFile = [line substringFromIndex:g_mapKdPrefix.length];
            NSString *imgPath = [self.objPath stringByAppendingPathComponent:mapFile];
            mat.map_Kd = [NFAssetUtils parseTextureFile:imgPath flipVertical:YES];

            // should record the file name + path and then perform the parse in the
            // category of NFAssetData in order to avoid introducing a renderer specific
            // object dependency (NFSurfaceModel) to the Wavefront obj parsing code
        }
    }

    if (matValid == YES) {
        // finished parsing material add it to the object's materials array
        [self.materialsArray addObject:mat];
    }
}

@end
