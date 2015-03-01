//
//  NFWavefrontObj.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
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
static NSString * const g_useMatPrefix = @"usemtl "; // need to handle the "(null)" material as well

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

void (^wfParseTriplet)(NSString *, NSString *, NSArray *) = ^ void (NSString *line, NSString *prefix, NSArray *triplet) {
    NSString *truncLine = [line substringFromIndex:[prefix length]];
    NSArray *words = [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [triplet initWithObjects:[NSNumber numberWithFloat:[[words objectAtIndex:0] floatValue]],
     [NSNumber numberWithFloat:[[words objectAtIndex:1] floatValue]],
     [NSNumber numberWithFloat:[[words objectAtIndex:2] floatValue]], nil];
};

//
//
//

@implementation WFObject
@synthesize objectName = _objectName;
@synthesize groups = _groups;

@synthesize vertices = _vertices;
@synthesize textureCoords = _textureCoords;
@synthesize normals = _normals;

- (NSMutableArray *)vertices {
    if (_vertices == nil) {
        _vertices = [[[NSMutableArray alloc] init] autorelease];
    }
    return _vertices;
}

- (NSMutableArray *)textureCoords {
    if (_textureCoords == nil) {
        _textureCoords = [[[NSMutableArray alloc] init] autorelease];
    }
    return _textureCoords;
}

- (NSMutableArray *)normals {
    if (_normals == nil) {
        _normals = [[[NSMutableArray alloc] init] autorelease];
    }
    return _normals;
}

- (NSMutableArray *)groups {
    if (_groups == nil) {
        _groups = [[[NSMutableArray alloc] init] autorelease];
    }
    return _groups;
}

//
// TODO: should take a param that will determine whether to use area weighted normals or angle weighted normals
//
// enum
// - useFaceNormals
// - unbiasedVertexNormals
// - surfaceAreaWeightedVertexNormals
// - faceAngleWeightedVertexNormals
// - areaAndAngleWeightedVertexNormals (TODO: determine how feasible this is)

- (void) calculateNormals {
    //
    // NOTE: Wavefront obj normals are per-vertex
    //
    NSUInteger vertexCount = [[self vertices] count];
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
        NSMutableArray* faceStrings = [group faceStrArray];
        NSUInteger faceCount = [faceStrings count];

        //
        // NOTE: test one face to see if it contains a texture coordinate, doing this rather than checking if
        //       self.textureCoords count > 0 since it is possible that one group will have texture coordinates
        //       and another will not
        //
        BOOL hasTextureCoordinates = NO;
        NSArray *groupParts = [faceStrings[0] componentsSeparatedByString:@"/"];
        for (NSInteger i=0; i<[groupParts count]; ++i) {
            NSInteger intValue = [[groupParts objectAtIndex:i] integerValue];
            switch (i) {
                case kGroupIndexTex: normalizeObjIndex(intValue, [self.textureCoords count]);
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
                index1 = [[[faceStrings[i] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
                index2 = [[[faceStrings[i + 1] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
                index3 = [[[faceStrings[i + 2] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
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
        NSMutableArray* tempFaceNormals = [[[NSMutableArray alloc] initWithCapacity:faceIndex] autorelease];
        for (int i=0; i<faceIndex; ++i) {
            NSValue *value = [NSValue value:&(faceArray[i]) withObjCType:faceType];
            [tempFaceNormals addObject:value];
        }
        NSArray* faceNormals = [[[NSArray alloc] initWithArray:tempFaceNormals] autorelease];

        // calculate vertex normals and update Wavefront obj face
        for (int i=0; i<faceCount; ++i) {
            int index = -1;
            if (hasTextureCoordinates) {
                index = [[[faceStrings[i] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
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
                int texCoordIndex = [[[faceStrings[i] componentsSeparatedByString:@"/"] objectAtIndex:1] intValue];
                NSString* str = [NSString stringWithFormat:@"%d/%d/%d", index+1, texCoordIndex, (int)([self.normals count])];
                [[group faceStrArray] setObject:str atIndexedSubscript:i];
            }
            else {
                NSString* str = [NSString stringWithFormat:@"%d//%d", index+1, (int)([self.normals count])];
                [[group faceStrArray] setObject:str atIndexedSubscript:i];
            }
        }
    }
}
@end

@implementation WFGroup
@synthesize groupName = _groupName;
@synthesize materialName = _materialName;
@synthesize faceStrArray = _faceStrArray;

- (NSMutableArray *)faceStrArray {
    if (_faceStrArray == nil) {
        _faceStrArray = [[[NSMutableArray alloc] init] autorelease];
    }
    return _faceStrArray;
}
@end

//
//
//

@interface NFWavefrontObj()

+ (NSArray *) componentsFromWavefrontObjLine:(NSString *)line withPrefix:(NSString *)prefix;

@property (nonatomic, retain) NSString *objPath;
@property (nonatomic, retain) NSString *fileSource;
@property (nonatomic, retain) NSString *mtlSource;

@property (nonatomic, assign) WFObject *activeObject;
@property (nonatomic, assign) WFGroup *activeGroup;

- (void) parseVertexArray:(NSArray *)vertexArray;
- (void) parseTextureCoordArray:(NSArray *)texCoordArray;
- (void) parseNormalVectorArray:(NSArray *)normVectorArray;
// parseParamArray

- (void) parseMaterialFile:(NSString *)file;
- (NFDataMap *) parseTextureFile:(NSString *)file;

@end

// TODO: use pragma mark to help organize this source file

@implementation NFWavefrontObj

@synthesize object = _object;

@synthesize activeObject = _activeObject;
@synthesize activeGroup = _activeGroup;

@synthesize objPath = _objPath;
@synthesize fileSource = _fileSource;
@synthesize mtlSource = _mtlSource;

@synthesize materialsArray = _materialsArray;

+ (NSArray *) componentsFromWavefrontObjLine:(NSString *)line withPrefix:(NSString *)prefix {
    // NOTE: there can be an indeterminant amount of white space after the prefix, need
    //       to remove leading and trailing whitespace as well as the prefix
    NSString *truncLine = [line substringFromIndex:[prefix length]];

    //
    // TODO: verify will remove leading whitespace
    //
    NSRange range = [truncLine rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
    truncLine = [truncLine stringByReplacingCharactersInRange:range withString:@""];

    //
    // TODO: verify will remove trailing whitespace
    //
    range = [truncLine rangeOfString:@"\\s*$" options:NSRegularExpressionSearch];
    truncLine = [truncLine stringByReplacingCharactersInRange:range withString:@""];

    return [truncLine componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSMutableArray *)materialsArray {
    if (_materialsArray == nil) {
        _materialsArray = [[[NSMutableArray alloc] init] autorelease];
    }
    return _materialsArray;
}

- (instancetype) init {
    self = [super init];
    if (self == nil) {
        return nil;
    }

    //
    // TODO: need to clean up this comment and probably move some where else, perhaps include a text file
    //       with the project on the coding convention used
    //

    // in general, you should use accessor methods or dot syntax for property access even if you’re accessing an
    // object’s properties from within its own implementation, in which case you should use self
    // the exception to this rule is when writing initialization, deallocation or custom accessor methods

    [self setActiveObject:nil];
    [self setActiveGroup:nil];

    [self setObject:[[[WFObject alloc] init] autorelease]];

    //
    // TODO: for modern objective C compliance should be returning an instanceType
    //       instead of an id for better type checking and consistency
    //

    return self;
}

- (void) dealloc {
    [super dealloc];
}

- (void) loadFileWithPath:(NSString *)filePath { // currently used load method
    NSError *nsErr = nil;
    NSStringEncoding encoding;

    // record copy of obj path
    self.objPath = [filePath stringByDeletingLastPathComponent];

    // to remove file extension if needed
    //NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];

    // NOTE: it would appear that the NSString that is being pointed to is an autorelease object
    self.fileSource = [NSString stringWithContentsOfFile:filePath usedEncoding:&encoding error:&nsErr];
    NSAssert(self.fileSource != nil, @"Failed to find path, error: %@", nsErr);
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
    self.fileSource = [[[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding] autorelease];
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
}

- (void) parseFile { // should support better error handling e.g. error:(NSError *)err ??
    NSArray *lines = [self.fileSource componentsSeparatedByString:@"\n"];

    // index set is for converting quads into triangles
    NSMutableIndexSet *indexSet = [[[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 3)] autorelease];

    for (NSString *line in lines) {

        //
        // TODO: to play it safe may want to consider converting to whole line to lower case, while
        //       the "official" spec seems to indicate case sensitivity but better safe than sorry
        //

        if ([line hasPrefix:g_matPrefix]) {
            NSString *path = [self.objPath stringByAppendingPathComponent:[line substringFromIndex:[g_matPrefix length]]];
            [self parseMaterialFile:path];
        }
        else if ([line hasPrefix:g_objPrefix]) {

            //
            // TODO: only storing one object name for now, will need to eventually handle N
            //

            NSString *objName = [line substringFromIndex:[g_objPrefix length]];

            [self.object setObjectName:objName];
        }
        else if ([line hasPrefix:g_groupPrefix]) {
            NSString *groupName = [line substringFromIndex:[g_groupPrefix length]];

            // allocate a new group (which will be the current active group) and add to object's group array
            self.activeGroup = [[[WFGroup alloc] init] autorelease];
            [self.object.groups addObject:self.activeGroup];

            // start populating the active group
            self.activeGroup.groupName = groupName;

        }
        else if ([line hasPrefix:g_useMatPrefix]) {

            //
            // TODO: should remove all prefixes using something like the componentsFromWavefrontObjLine
            //       class method, should try to implement something like a stringFromWavefrontObjLine
            //       (really could use a better name)
            //
            NSString *matName = [line substringFromIndex:[g_useMatPrefix length]];

            //
            // TODO: may need to also check against "null" in addition to "(null)"
            //
            if (![matName isEqualToString:@"(null)"]) {
                self.activeGroup.materialName = matName;
            }
            else {
                //
                // TODO: fallback to a default texture and material, will need to perform a UV mapping algorithm
                //
                NSLog(@"WARNING: should fallback to default texture, this is behavior is not yet implemented");

                // simple UV mapping algorithm (basically treat model as if it is spherical)
                // - calc center point of geometry
                // - for each vertex calc vector from center point to vertex
                // - normalize vector
                // - u = 0.5 + arctan2(vec.z, vec.x)/2pi
                // - v = 0.5 - arcsin(vec.y)/pi

                // NOTE: not sure if applying a UV unwrapping algorithm to the model will be worthwhile, though
                //       it will flatten the model so it can easily be transformed into texture coordinate space,
                //       it most likely won't cleanly map the texture to the model (i.e. UV unwrapping is largely
                //       performed to allow artist to draw on a "flat" model surface)
            }
        }
        else if ([line hasPrefix:g_vertPrefix]) {
            NSArray *vertArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_vertPrefix];
            [self parseVertexArray:vertArray];
        }
        else if ([line hasPrefix:g_texPrefix]) {
            NSArray *texArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_texPrefix];
            [self parseTextureCoordArray:texArray];
        }
        else if ([line hasPrefix:g_normPrefix]) {
            NSArray *normArray = [NFWavefrontObj componentsFromWavefrontObjLine:line withPrefix:g_normPrefix];
            [self parseNormalVectorArray:normArray];
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
                self.activeGroup = [[[WFGroup alloc] init] autorelease];
                [self.object.groups addObject:self.activeGroup];
                self.activeGroup.groupName = @"default_group";
            }


            // check if face is a triangle or a quad (quads need to be converted into triangles)
            if ([faceIndexArray count] == 3) {
                [self.activeGroup.faceStrArray addObjectsFromArray:faceIndexArray];
            }
            else if ([faceIndexArray count] == 4) {
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

- (void) parseVertexArray:(NSArray *)vertexArray {
    // parse vertex
    GLKVector3 vertex;
    vertex.x = [[vertexArray objectAtIndex:0] floatValue];
    vertex.y = [[vertexArray objectAtIndex:1] floatValue];
    vertex.z = [[vertexArray objectAtIndex:2] floatValue];

    // add vertex to parent class NSAssetData
    NSValue *value = [NSValue value:&vertex withObjCType:g_vertexType];
    [self.object.vertices addObject:value];
}

- (void) parseTextureCoordArray:(NSArray *)texCoordArray {
    // parse texture coord
    GLKVector3 texCoord;
    texCoord.s = [[texCoordArray objectAtIndex:0] floatValue];
    texCoord.t = [[texCoordArray objectAtIndex:1] floatValue];

    // if texture coordiante supports depth use it
    if ([texCoordArray count] > 2) {
        texCoord.p = [[texCoordArray objectAtIndex:2] floatValue];
    }
    else {
        texCoord.p = 0.0f;
    }

    // add texture coord to parent NSAssetData
    NSValue *value = [NSValue value:&texCoord withObjCType:g_texType];
    [self.object.textureCoords addObject:value];
}

- (void) parseNormalVectorArray:(NSArray *)normVectorArray {
    // parse normal vector
    GLKVector3 normal;
    normal.x = [[normVectorArray objectAtIndex:0] floatValue];
    normal.y = [[normVectorArray objectAtIndex:1] floatValue];
    normal.z = [[normVectorArray objectAtIndex:2] floatValue];

    // add normal to parent NSAssetData
    NSValue *value = [NSValue value:&normal withObjCType:g_normType];
    [self.object.normals addObject:value];
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

    NFSurfaceModel *mat = [[[NFSurfaceModel alloc] init] autorelease];

    //
    // TODO: try and simplify some of this functionality using the NSScanner class
    //

    for (NSString *line in lines) {

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
            mat.name = [line substringFromIndex:[g_newMatPrefix length]];
            matValid = YES;
        }
        else if ([line hasPrefix:g_NsPrefix]) {
            NSString *truncLine = [line substringFromIndex:[g_NsPrefix length]];
            mat.Ns = [truncLine floatValue];
        }
        else if ([line hasPrefix:g_NiPrefix]) {
            NSString *truncLine = [line substringFromIndex:[g_NiPrefix length]];
            mat.Ni = [truncLine floatValue];
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
            NSString *truncLine = [line substringFromIndex:[g_ilPrefix length]];
            mat.illum = [truncLine integerValue];

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
            wfParseTriplet(line, g_KaPrefix, mat.Ka);
        }
        else if ([line hasPrefix:g_KdPrefix]) {
            wfParseTriplet(line, g_KdPrefix, mat.Kd);
        }
        else if ([line hasPrefix:g_KsPrefix]) {
            wfParseTriplet(line, g_KsPrefix, mat.Ks);
        }
        else if ([line hasPrefix:g_KePrefix]) {
            wfParseTriplet(line, g_KePrefix, mat.Ke);
        }
        else if ([line hasPrefix:g_mapKdPrefix]) {

            NSString *mapFile = [line substringFromIndex:[g_mapKdPrefix length]];
            mat.map_Kd = [self parseTextureFile:mapFile];

            // should record the file name + path and then perform the parse in the
            // category of NFAssetData in order to avoid introducing a renderer specific
            // object dependency (NFSurfaceModel) to the Wavefront obj parsing code
        }
    }

    if (matValid == YES) {

        // finished parsing material add it to the object's materials array
        //NSValue *value = [NSValue value:&mat withObjCType:g_matType];
        //[self.materialsArray addObject:value];

        [[self materialsArray] addObject:mat];
    }
}

- (NFDataMap *) parseTextureFile:(NSString *)file {
    // NOTE: not using the GLK texture loader class since I want to store the texture in both
    //       my own OpenGL specific format and as an NSImage for displaying in a utility window

    NSString *imgPath = [self.objPath stringByAppendingPathComponent:file];
    NSImage *nsimage = [[NSImage alloc] initWithContentsOfFile:imgPath];

    //
    // TODO: switch off the file name extension to use the correct representation when loading
    //       the NSBitmapImage object
    //
    // use NSImage NSBitmapImageRep to load TIFF, BMP, JPEG, GIF, PNG, DIB, ICO
    // to get a complete list of all supported image formats use the NSImage method imageFileTypes
    NSBitmapImageRep *imageClass = [[NSBitmapImageRep alloc] initWithData:[nsimage TIFFRepresentation]];

    CGImageRef cgImage = imageClass.CGImage;
    NSAssert(cgImage != NULL, @"ERROR: NSBitmapImageRep has a NULL CGImage");

    CGRect mapSize = CGRectMake(0.0, 0.0, CGImageGetWidth(cgImage), CGImageGetHeight(cgImage));
    size_t rowByteSize = CGImageGetBytesPerRow(cgImage);

    GLenum format = GL_INVALID_ENUM;
    GLenum type = GL_INVALID_ENUM;

    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    //size_t bitsPerPixel = CGImageGetBitsPerPixel(cgImage); // not currently needed

    CGColorSpaceRef colorSpace = CGImageGetColorSpace(cgImage);
    CGColorSpaceModel colorModel = CGColorSpaceGetModel(colorSpace);
    CGBitmapInfo bitmapInfo = (CGBitmapInfo)kCGImageAlphaNone;
    if (colorModel == kCGColorSpaceModelRGB) {
        if ([imageClass hasAlpha]) {
            //
            // TODO: remove all OpenGL dependencies from asset parsing/processing by defining common data types
            //
            format = GL_RGBA;
            bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
        }
        else {
            format = GL_RGB;
            // NOTE: as stated by the Apple developer docs for the CGBitmapContextCreate function
            // "The constants for specifying the alpha channel information are declared with the CGImageAlphaInfo type but can be passed to this parameter safely."
            bitmapInfo = (CGBitmapInfo)kCGImageAlphaNoneSkipLast;

            NSAssert(bitsPerComponent == 8, @"ERROR: RGB images currently only support 8 bits per component");
            rowByteSize = CGRectGetWidth(mapSize) * 4;
        }
    }
    else {
        NSAssert(NO, @"ERROR: unsupported color model");
    }

    // check if sample size is the same as unsigned byte size
    if ([imageClass bitsPerSample] / CHAR_BIT == sizeof(GLubyte)) {
        type = GL_UNSIGNED_BYTE;
    }
    else {
        NSAssert(NO, @"ERROR: unsupported sample type");
    }

    GLubyte *pData = (GLubyte *)malloc(mapSize.size.height * rowByteSize);
    NSAssert(pData != NULL, @"ERROR: failed to allocate image data buffer");

    BOOL flipVertical = YES;
    CGContextRef context = CGBitmapContextCreate(pData, CGRectGetWidth(mapSize), CGRectGetHeight(mapSize),
                                                 bitsPerComponent, rowByteSize, CGImageGetColorSpace(cgImage),
                                                 bitmapInfo);

    CGContextSetBlendMode(context, kCGBlendModeCopy);
    if (flipVertical) {
        CGContextTranslateCTM(context, 0.0, CGRectGetHeight(mapSize));
        CGContextScaleCTM(context, 1.0, -1.0);
    }
    // copy cgImage into the image data buffer provided in the CG context
    CGContextDrawImage(context, CGRectMake(0.0, 0.0, CGRectGetWidth(mapSize), CGRectGetHeight(mapSize)), cgImage);
    CGContextRelease(context);

    [imageClass release];

#if 0
    int winStyleMask = NSTitledWindowMask | NSClosableWindowMask;
    // NSMiniaturizableWindowMask | NSResizableWindowMask
    // NSTexturedBackgroundWindowMask
    // NSBorderlessWindowMask // use to make it a splash screen

    CGRect imageRect = CGRectMake(0, 0, [nsimage size].width, [nsimage size].height);

    NSWindow *imageWindow = [[NSWindow alloc] initWithContentRect:imageRect
                                                        styleMask:winStyleMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:NO];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:imageRect];

    [imageView setImage:nsimage];
    [imageView setBounds:imageRect];
    [[imageWindow contentView] addSubview:imageView];

    [imageWindow setHasShadow:YES];
    [imageWindow center];
    [imageWindow makeKeyAndOrderFront:self]; // will issue a dispaly call to all sub views
    //[imageView display]; // explicit call not currently needed but may be in future versions of OS X

    [imageView release];
#endif

    [nsimage release];

    NFDataMap *dataMap = [[[NFDataMap alloc] init] autorelease];
    [dataMap loadWithData:pData ofSize:mapSize ofType:type withFormat:format];

    NSAssert(pData != NULL, @"ERROR: image data buffer pointer was set to NULL prior to freeing memory");
    free(pData);

    return dataMap;
}

@end
