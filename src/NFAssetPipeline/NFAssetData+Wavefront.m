//
//  NFAssetData+Wavefront.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetData+Wavefront.h"

@implementation NFAssetData (Wavefront)

- (void) setNumberOfSubsets:(NSInteger)numSubsets {
    // build subset array
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:numSubsets];

    NFAssetSubset *subset;
    for (int i=0; i<numSubsets; ++i) {
        subset = [[NFAssetSubset alloc] init];
        [tempArray addObject:subset];
    }

    // set the non-mutable asset data subset array
    self.subsetArray = [tempArray copy]; // will return nil if tempArray is nil
    //self.subsetArray = [NSArray arrayWithArray:tempArray]; // will return @[] (empty array) if tempArray is nil

    // NOTE: if copy fits the design better than arrayWithArray then perhaps use the copy
    //       qualifier for the subsetArray property
}

- (void) addSubsetWithIndices:(NSMutableArray *)indices ofObject:(WFObject *)wfObj atIndex:(NSUInteger)idx {
    NFAssetSubset *subset = (self.subsetArray)[idx];

    //
    // NOTE: removing duplicates will still be useful for determining the number of
    //       NFVertex_t vertices to allocate
    //
    NSMutableArray *uniqueArray = [[NSMutableArray alloc] init];
    [uniqueArray addObjectsFromArray:[NSSet setWithArray:indices].allObjects]; // remove duplicates

    NFVertex_t *pData = (NFVertex_t *)malloc(uniqueArray.count * sizeof(NFVertex_t));
    GLushort *pIndices = (GLushort *)malloc(indices.count * sizeof(GLushort));
    memset(pData, 0x00, [uniqueArray count] * sizeof(NFVertex_t));
    memset(pIndices, 0x00, [indices count] * sizeof(GLushort));

    NSUInteger dataIndex = 0;



    // just directly parse the triplet, add the NFVertex_t to the array, and then add the index to
    // the index array (a face index that can create a duplicate NFVertex_t, as an optimization check
    // for this condition and then set the index to the already created vertex)

#if 0

    NSMutableDictionary* indexDict = [[NSMutableDictionary alloc] initWithCapacity:uniqueArray.count];

    int eltIdx = 0;

    for (NSUInteger i=0; i<indices.count; ++i) {
        NSString* str = indices[i];

        // build a dictionary of the face and corresponding index value and search that for duplicates
        BOOL isDuplicate = NO;
        NSUInteger duplicateIndex = 0;
        for (NSString* key in indexDict) {
            if ([str isEqualToString:key]) {
                isDuplicate = YES;
                NSNumber* num = [indexDict valueForKey:key];
                duplicateIndex = [num unsignedIntegerValue];
                break;
            }
        }

        /*
        [myDict enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
            // do something with key and obj
        }];
        */



        if (!isDuplicate) {
            NSInteger vertIndex = -1;
            NSInteger texIndex = -1;
            NSInteger normIndex = -1;
            NSArray *groupParts = [str componentsSeparatedByString:@"/"];

            NSUInteger count = groupParts.count;
            NSInteger intValue;
            for (NSUInteger i=0; i<count; ++i) {
                // NOTE: will have an empty string i.e. "" at the texture coordinate or normal position when
                //       there is no texture coordinate given and this will return an intValue of 0
                intValue = [groupParts[i] intValue];
                switch (i) {
                    case kGroupIndexVertex: vertIndex = normalizeObjIndex(intValue, wfObj.vertices.count); break;
                    case kGroupIndexTex: texIndex = normalizeObjIndex(intValue, wfObj.textureCoords.count); break;
                    case kGroupIndexNorm: normIndex = normalizeObjIndex(intValue, wfObj.normals.count); break;
                    default: NSAssert(nil, @"Error, unknown face index type"); break;
                }
            }

            //NSLog(@"%@ %ld/%ld/%ld", str, vertIndex, texIndex, normIndex);

            NSValue *valueObj;
            if (vertIndex != -1) {
                GLKVector3 vertex;
                valueObj = wfObj.vertices[vertIndex];
                [valueObj getValue:&vertex];
                pData[dataIndex].pos[0] = vertex.x;
                pData[dataIndex].pos[1] = vertex.y;
                pData[dataIndex].pos[2] = vertex.z;
                pData[dataIndex].pos[3] = 1.0f;
            }

            if (texIndex != -1) {
                GLKVector3 texCoord;
                valueObj = wfObj.textureCoords[texIndex];
                [valueObj getValue:&texCoord];
                pData[dataIndex].texCoord[0] = texCoord.s;
                pData[dataIndex].texCoord[1] = texCoord.t;
                pData[dataIndex].texCoord[2] = texCoord.p;
            }

            if (normIndex != -1) {
                GLKVector3 normal;
                valueObj = wfObj.normals[normIndex];
                [valueObj getValue:&normal];
                pData[dataIndex].norm[0] = normal.x;
                pData[dataIndex].norm[1] = normal.y;
                pData[dataIndex].norm[2] = normal.z;
                pData[dataIndex].norm[3] = 0.0f;
            }

            // set the element index
            pIndices[eltIdx] = (GLushort)dataIndex;
            [indexDict setValue:@(dataIndex) forKey:str];
            ++dataIndex;
        }
        else {
            // record the duplicate index to the indexArray
            pIndices[eltIdx] = (GLushort)duplicateIndex;
        }

        // increment the element index
        ++eltIdx;
        NSAssert(eltIdx <= indices.count, @"ERROR: created too many indices");
    }

#else

    //
    // TODO: benchmark this against the new implementation above, and check that the recorded TEST.obj
    //       is consistently recorded between implementations
    //

    //
    // TODO: also getting a black cube when loading TEST.obj using the above method
    //

    NSMutableArray *indexArray = [[NSMutableArray alloc] initWithCapacity:uniqueArray.count];

    //
    // TODO: why is this being sorted again ?? may not need to do this
    //
/*
    NSArray *sortedArray = [uniqueArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        return [(NSString *)b compare:(NSString *)a];
    }];
*/

    //
    // TODO: based on how the sorted array processing is being handled the indices array must be
    //       the raw strings values of each face index triple vp/vt/vn
    //

    //for (NSString *faceStr in sortedArray) {
    for (NSString *faceStr in uniqueArray) {
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
        // TODO: should see if vertices themselves are optional i.e. if a file only has NURBS data
        //       does it need to contain faces for the indexes or are they generated from the NURBS ??
        //

        // NOTE: indices in file start at 1, need to make zero based and if you ever see a negative face index
        //       it means go back that many vertices i.e. -8 means go back 8 vertices from the last one read

        // NOTE: this will only work if all the faces are listed after the vertices they reference
        //       (is this guaranteed by the WavefrontObj file format ?? )

        NSUInteger count = groupParts.count;
        NSInteger intValue;
        for (NSUInteger i=0; i<count; ++i) {
            // NOTE: will have an empty string i.e. "" at the texture coordinate or normal position when
            //       there is no texture coordinate given and this will return an intValue of 0
            intValue = [groupParts[i] intValue];
            switch (i) {
                case kGroupIndexVertex: vertIndex = normalizeObjIndex(intValue, wfObj.vertices.count); break;
                case kGroupIndexTex: texIndex = normalizeObjIndex(intValue, wfObj.textureCoords.count); break;
                case kGroupIndexNorm: normIndex = normalizeObjIndex(intValue, wfObj.normals.count); break;
                default: NSAssert(nil, @"Error, unknown face index type"); break;
            }
        }

        NSValue *valueObj;

        // NOTE: w component of norm should be 0.0, and 1.0 for position (for vectors w = 0.0 and for points w = 1.0)

        if (vertIndex != -1) {
            GLKVector3 vertex;
            valueObj = wfObj.vertices[vertIndex];
            [valueObj getValue:&vertex];
            pData[dataIndex].pos[0] = vertex.x;
            pData[dataIndex].pos[1] = vertex.y;
            pData[dataIndex].pos[2] = vertex.z;
            pData[dataIndex].pos[3] = 1.0f;
        }

        if (texIndex != -1) {
            GLKVector3 texCoord;
            valueObj = wfObj.textureCoords[texIndex];
            [valueObj getValue:&texCoord];
            pData[dataIndex].texCoord[0] = texCoord.s;
            pData[dataIndex].texCoord[1] = texCoord.t;
            pData[dataIndex].texCoord[2] = texCoord.p;
        }

        if (normIndex != -1) {
            GLKVector3 normal;
            valueObj = wfObj.normals[normIndex];
            [valueObj getValue:&normal];
            pData[dataIndex].norm[0] = normal.x;
            pData[dataIndex].norm[1] = normal.y;
            pData[dataIndex].norm[2] = normal.z;
            pData[dataIndex].norm[3] = 0.0f;
        }

        // record data index to be associated with specific Wavefront obj face value
        [indexArray addObject:@(dataIndex)];
        ++dataIndex;
    }

    // build a dictionary of which face string corresponds with which vertex using the uniqueArray
    // (should also investigate using an NSMapTable or CFDictionary)

    //NSDictionary *indexDict = [NSDictionary dictionaryWithObjects:indexArray forKeys:sortedArray];
    NSDictionary *indexDict = [NSDictionary dictionaryWithObjects:indexArray forKeys:uniqueArray];

    // iterate through faceStrArray and set index value based on dictionary lookup
    dataIndex = 0;
    for (NSString *faceStr in indices) {
        NSNumber *indexNum = indexDict[faceStr];
        pIndices[dataIndex] = (GLushort)indexNum.intValue;
        ++dataIndex;
    }

#endif


    // allocate and load vertex/index data into the subset
    [subset allocateIndicesWithNumElts:indices.count];
    [subset loadIndexData:pIndices ofSize:indices.count * sizeof(GLushort)];

    [subset allocateVerticesOfType:kVertexFormatDefault withNumVertices:uniqueArray.count];
    [subset loadVertexData:pData ofType:kVertexFormatDefault withNumVertices:uniqueArray.count];

    free(pData);
    free(pIndices);
}

@end
