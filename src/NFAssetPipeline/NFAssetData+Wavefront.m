//
//  NFAssetData+Wavefront.m
//  NSGLFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Wavefront.h"

typedef NS_ENUM(NSUInteger, FaceGroupType) {
    kGroupIndexVertex = 0,
    kGroupIndexTex = 1,
    kGroupIndexNorm = 2
};

@implementation NFAssetData (Wavefront)

- (void) setNumberOfSubsets:(NSInteger)numSubsets {
    // build subset array
    NSMutableArray *tempArray = [[[NSMutableArray alloc] initWithCapacity:numSubsets] autorelease];

    NFSubset *subset;
    for (int i=0; i<numSubsets; ++i) {
        subset = [[[NFSubset alloc] init] autorelease];
        [tempArray addObject:subset];
    }

    // set the non-mutable asset data subset array
    self.subsetArray = [[tempArray copy] autorelease]; // will return nil if tempArray is nil
    //self.subsetArray = [NSArray arrayWithArray:tempArray]; // will return @[] (empty array) if tempArray is nil

    // NOTE: if copy fits the design better than arrayWithArray then perhaps use the copy
    //       qualifier for the subsetArray property
}

- (void) addSubsetWithIndices:(NSMutableArray *)indices ofObject:(WFObject *)wfObj atIndex:(NSUInteger)idx {

    //
    // TODO: as part of parsing/processing the Wavefront obj file it would be a good time to
    //       potentially improve vertex cache performance by sorting/reordering the vertices/indices
    //       (see home.comcast.net/~tom_forsyth/fast_vert_cache_opt.html for reference)
    //

    NFSubset *subset = [self.subsetArray objectAtIndex:idx];

    NSMutableArray *uniqueArray = [[[NSMutableArray alloc] init] autorelease];
    [uniqueArray addObjectsFromArray:[[NSSet setWithArray:indices] allObjects]];

    NSArray *sortedArray = [uniqueArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [(NSString *)b compare:(NSString *)a];
    }];

    NFVertex_t *pData = (NFVertex_t *)malloc([uniqueArray count] * sizeof(NFVertex_t));
    GLushort *pIndices = (GLushort *)malloc([indices count] * sizeof(GLushort));
    memset(pData, 0x00, [uniqueArray count] * sizeof(NFVertex_t));
    memset(pIndices, 0x00, [indices count] * sizeof(GLushort));

    NSMutableArray *indexArray = [[[NSMutableArray alloc] init] autorelease];

    NSInteger (^indexCheck)(NSInteger, NSUInteger) = ^ NSInteger (NSInteger intValue, NSUInteger count) {
        //return -1 if the intValue or the count are 0
        if (intValue == 0 || count == 0) {
            return -1;
        }
        return (intValue > 0) ? (intValue - 1) : (count + intValue);
    };

    //
    // TODO: break out the parsing of the sorted array into a sub/helper method that parses the
    //       vertx ("face") string
    //

    // iterate through the uniqueArray and create interleaved vertices
    int dataIndex = 0;

    for (NSString *faceStr in sortedArray) {
        NSInteger vertIndex = -1;
        NSInteger texIndex = -1;
        NSInteger normIndex = -1;
        NSArray *groupParts = [faceStr componentsSeparatedByString:@"/"];

        // face indices are grouped as vertex/texture-coord/normal
        //f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3

        // normals are optional, faces can also be quads
        //f v1/vt1 v2/vt2 v3/vt3 v4/vt4

        // texture coordinates are also optional
        //f v1//vn1 v2//vn2 v3//vn3



        //
        // TODO: if there is no normal data calculate a normal vector from the three
        //       vertices listed by the face
        //

        // https://www.opengl.org/wiki/Calculating_a_Surface_Normal

        // for a triangle with points p1, p2, p3

        // U = p2 - p1
        // V = p3 - p1
        // N = U X V

        // Nx = UyVz - UzVy
        // Ny = UzVx - UxVz
        // Nz = UxVy - UyVx


        //
        // TODO: should see if vertices themselves are optional i.e. if a file only has NURBS data
        //       does it need to contain faces for the indexes or are they generated from the NURBS
        //

        // NOTE: indices in file start at 1, need to make zero based and if you ever see a negative face index
        //       it means go back that many vertices i.e. -8 means go back 8 vertices from the last one read

        // NOTE: this will only work if all the faces are listed after the vertices they reference
        //       (is this guaranteed by the WavefrontObj file format ?? )

        NSUInteger count = [groupParts count];
        NSInteger intValue;
        for (NSUInteger i=0; i<count; ++i) {
            // NOTE: will have an empty string i.e. "" at the texture coordinate position when
            //       there is no texture coordinate given and this will return an intValue of 0
            intValue = [[groupParts objectAtIndex:i] intValue];
            switch (i) {
                case kGroupIndexVertex: vertIndex = indexCheck(intValue, [[wfObj vertices] count]); break;
                case kGroupIndexTex: texIndex = indexCheck(intValue, [[wfObj textureCoords] count]); break;
                case kGroupIndexNorm: normIndex = indexCheck(intValue, [[wfObj normals] count]); break;
                default: NSAssert(false, @"Error, unknown face index type"); break;
            }
        }

        //
        // TODO: should safe guard must be in place for the texture coordinate and the normal, once
        //       parsing parametric surfaces, NURBS, etc. will need to verify if vertices can be optional
        //       when defining faces
        //

        NSValue *valueObj;

        // NOTE: w component of norm should be 0.0, and 1.0 for position (for vectors w = 0.0 and for points w = 1.0)

        if (vertIndex != -1) {
            Vertex3f_t vertex;
            valueObj = [[wfObj vertices] objectAtIndex:vertIndex];
            [valueObj getValue:&vertex];
            pData[dataIndex].pos[0] = vertex.x;
            pData[dataIndex].pos[1] = vertex.y;
            pData[dataIndex].pos[2] = vertex.z;
            pData[dataIndex].pos[3] = 1.0f;
        }

        if (texIndex != -1) {
            MapCoord3f_t texCoord;
            valueObj = [[wfObj textureCoords] objectAtIndex:texIndex];
            [valueObj getValue:&texCoord];
            pData[dataIndex].texCoord[0] = texCoord.u;
            pData[dataIndex].texCoord[1] = texCoord.v;
            pData[dataIndex].texCoord[2] = texCoord.w;
        }

        if (normIndex != -1) {
            Vector3f_t normal;
            valueObj = [[wfObj normals] objectAtIndex:normIndex];
            [valueObj getValue:&normal];
            pData[dataIndex].norm[0] = normal.x;
            pData[dataIndex].norm[1] = normal.y;
            pData[dataIndex].norm[2] = normal.z;
            pData[dataIndex].norm[3] = 0.0f;
        }

        // record data index to be associated with specific Wavefront obj face value
        NSNumber *num = [NSNumber numberWithInt:dataIndex];
        [indexArray addObject:num];
        ++dataIndex;
    }

    // build a dictionary of which face string corresponds with which vertex using the uniqueArray
    // (should also investigate using an NSMapTable or CFDictionary)
    NSDictionary *indexDict = [NSDictionary dictionaryWithObjects:indexArray forKeys:sortedArray];

    // iterate through faceStrArray and set index value based on dictionary lookup
    dataIndex = 0;
    for (NSString *faceStr in indices) {
        NSNumber *indexNum = [indexDict objectForKey:faceStr];
        pIndices[dataIndex] = (GLushort)[indexNum intValue];
        ++dataIndex;
    }

    // allocate and load vertex/index data into the subset
    [subset allocateVerticesWithNumElts:[uniqueArray count]];
    [subset allocateIndicesWithNumElts:[indices count]];
    [subset loadVertexData:pData ofSize:[uniqueArray count] * sizeof(NFVertex_t)];
    [subset loadIndexData:pIndices ofSize:[indices count] * sizeof(GLushort)];

    free(pData);
    free(pIndices);
}

@end
