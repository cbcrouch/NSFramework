//
//  NFAssetLoader.m
//  NSFramework
//
//  Copyright (c) 2016 Casey Crouch. All rights reserved.
//

#import "NFAssetLoader.h"

#import "NFAssetData+Procedural.h"
#import "NFAssetData+Wavefront.h"


@implementation NFAssetLoader

+ (NFAssetData *) allocAssetDataOfType:(ASSET_TYPE)type withArgs:(id)firstArg, ... NS_REQUIRES_NIL_TERMINATION {

    NFAssetData *asset = [[NFAssetData alloc] init];

    switch (type) {
        case kWavefrontObj: {
            NSAssert(firstArg != nil, @"ERROR: expected a string for the file name and path, received nil");
            NSString *fileNamePath = (NSString *)firstArg;

            //
            // NOTE: va_list/args will only get data off the stack after the firstArg
            //
            va_list args;
            va_start(args, firstArg);
            id obj = va_arg(args, id);
            if (obj) {
                NSLog(@"allocAssetDataOfType second arg is present, should be a bundle");
            }
            va_end(args);

            NFWavefrontObj *wavefrontObj = [[NFWavefrontObj alloc] init];
            [wavefrontObj loadFileWithPath:fileNamePath];


            //
            // TODO: profile and optimize the file parsing
            //
            [wavefrontObj parseFile];

            if (wavefrontObj.object.textureCoords.count == 0) {
                [wavefrontObj.object calculateTextureCoordinates];
            }

            if (wavefrontObj.object.normals.count == 0) {
                [wavefrontObj.object calculateNormals];
            }


            //
            // TODO: only one Wavefront object is currently supported, will need to update
            //       when support has been added for multiple Wavefront objects
            //
            [asset setNumberOfSubsets:wavefrontObj.object.groups.count];

            NSUInteger index = 0;
            for (WFGroup *group in wavefrontObj.object.groups) {
                [asset addSubsetWithIndices:group.faceStrArray ofObject:wavefrontObj.object atIndex:index];
                ++index;
            }


            // loop through all values and convert them into NFLightingModel objects
            NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
            for (NFSurfaceModel *surface in wavefrontObj.materialsArray) {
                // would convert the asset surface model to the internal framework
                // representation here if they were different
                [surfaceModels addObject:surface];
            }

            asset.surfaceModelArray = surfaceModels;

            NFSurfaceModel * (^findSurfaceModel)(NSString *) = ^ NFSurfaceModel * (NSString *name) {
                for (NFSurfaceModel *surface in asset.surfaceModelArray) {
                    if (surface.name == name) {
                        return surface;
                    }
                }
                return nil;
            };

            NSInteger subsetIndex = 0;
            for (WFGroup *group in wavefrontObj.object.groups) {
                // NOTE: subsets are 1-1 with the groups, this code will need to be udpated
                //       when support for multiple objects is added
                NFAssetSubset *subset = asset.subsetArray[subsetIndex];
                subset.surfaceModel = findSurfaceModel(group.materialName);
                ++subsetIndex;
            }

/*
            for (NFAssetSubset *subset in asset.subsetArray) {
                GLushort *pIndices = subset.indices;
                for (int i=0; i<subset.numIndices; i+=3) {
                    NSLog(@"%d, %d, %d", pIndices[0], pIndices[1], pIndices[2]);
                    pIndices += 3;
                }

                NFVertex_t *pVertices = (NFVertex_t*)subset.vertices;
                for (int i=0; i<subset.numVertices; ++i) {
                    NSLog(@"pos: %f, %f, %f", pVertices->pos[0], pVertices->pos[1], pVertices->pos[2]);
                    NSLog(@"tex: %f, %f", pVertices->texCoord[0], pVertices->texCoord[1]);
                    NSLog(@"norm: %f, %f, %f", pVertices->norm[0], pVertices->norm[1], pVertices->norm[2]);
                    pVertices++;
                }
            }
*/
        }
        break;

            //
            // TODO: parse arg for size and pass along to asset generation for plane, grid, axis, and cube
            //

        case kSolidPlane: {

            //[asset createPlaneOfSize:4];
            [asset createPlaneOfSize:16];

            // NOTE: default draw mode should work

            NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
            NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;
            for (NFAssetSubset *subset in asset.subsetArray) {
                subset.surfaceModel = surfaceModels[0];
            }
        }
        break;

        case kGridWireframe:
            [asset createGridOfSize:4];
            for (NFAssetSubset *subset in asset.subsetArray) {
                subset.drawMode = kDrawLines;
            }
        break;

        case kAxisWireframe:
            [asset createAxisOfSize:10];
            for (NFAssetSubset *subset in asset.subsetArray) {
                subset.drawMode = kDrawLines;
            }
        break;

        case kCubeMapGeometry: {
            [asset createCubeMapGeometryOfSize:1];

            NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
            NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;
            for (NFAssetSubset *subset in asset.subsetArray) {
                subset.surfaceModel = surfaceModels[0];
            }
        }
        break;

            //
            // TODO: need to be able to pass in stacks, slices, and height values for the sphere,
            //       cylinder, and cone geometry creation methods
            //

        case kSolidCylinder: {
            NF_VERTEX_FORMAT vertexType = kVertexFormatDefault;
            if(firstArg != nil) {
                NSNumber* numObj = (NSNumber*)firstArg;
                [numObj getValue:(void*)&vertexType];
            }

            // 8  => 45 degree slices     very low resolution
            // 16 => 22.5 degree slices   low resolution
            // 32 => 11.25 degree slices  medium resolution
            // 64 => 5.625 degree slices  high resolution
            [asset createCylinderWithRadius:1.0f ofHeight:2.0f withSlices:16 withVertexFormat:vertexType];

            if (vertexType == kVertexFormatDefault) {
                NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
                NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
                [surfaceModels addObject:surface];

                asset.surfaceModelArray = surfaceModels;
                for (NFAssetSubset *subset in asset.subsetArray) {
                    subset.surfaceModel = surfaceModels[0];
                }
            }
        }
        break;

        case kSolidUVSphere: {
            NF_VERTEX_FORMAT vertexType = kVertexFormatDefault;
            if(firstArg != nil) {
                NSNumber* numObj = (NSNumber*)firstArg;
                [numObj getValue:(void*)&vertexType];
            }

            // with radius 1.0 (model space == world space)
            // - 8   16 for low resolution
            // - 16  32 for medium resolution
            // - 32  64 for high resolution
            [asset createUVSphereWithRadius:1 withStacks:32 withSlices:64 withVertexFormat:vertexType];

            if (vertexType == kVertexFormatDefault) {
                NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
                NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
                [surfaceModels addObject:surface];

                asset.surfaceModelArray = surfaceModels;
                for (NFAssetSubset *subset in asset.subsetArray) {
                    subset.surfaceModel = surfaceModels[0];
                }
            }
        }
        break;

        case kSolidCone: {
            NF_VERTEX_FORMAT vertexType = kVertexFormatDefault;
            if(firstArg != nil) {
                NSNumber* numObj = (NSNumber*)firstArg;
                [numObj getValue:(void*)&vertexType];
            }

            // with radius 1.0 (model space == world space)
            // - 8  for low resolution
            // - 16 for medium resolution
            // - 32 for high resolution
            [asset createConeWithRadius:1.0f ofHeight:1.0f withSlices:16 withVertexFormat:vertexType];

            if (vertexType == kVertexFormatDefault) {
                NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
                NSMutableArray *surfaceModels = [[NSMutableArray alloc] init];
                [surfaceModels addObject:surface];

                asset.surfaceModelArray = surfaceModels;
                for (NFAssetSubset *subset in asset.subsetArray) {
                    subset.surfaceModel = surfaceModels[0];
                }
            }
        }
        break;

            //
            // TODO: would be awesome to be able to pass in an equation, a range for each variable, and number
            //       of increments per variable and the shape would be generated (would still be useful to have
            //       some custom defined functions that hardcoded the equation/ranges/slices/etc.)
            //

        default:
            NSAssert(nil, @"ERROR: received unknown type for loading asset");
        break;
    }

    return asset;
}

@end
