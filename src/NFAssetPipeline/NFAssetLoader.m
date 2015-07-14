//
//  NFAssetLoader.m
//  NSFramework
//
//  Copyright (c) 2015 Casey Crouch. All rights reserved.
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

            NFWavefrontObj *wavefrontObj = [[[NFWavefrontObj alloc] init] autorelease];
            [wavefrontObj loadFileWithPath:fileNamePath];


            //
            // TODO: profile and optimize the file parsing
            //
            [wavefrontObj parseFile];

            if ([[[wavefrontObj object] textureCoords] count] == 0) {
                [[wavefrontObj object] calculateTextureCoordinates];
            }

            if ([[[wavefrontObj object] normals] count] == 0) {
                [[wavefrontObj object] calculateNormals];
            }


            //
            // TODO: only one Wavefront object is currently supported, will need to update
            //       when support has been added for multiple Wavefront objects
            //
            [asset setNumberOfSubsets:[[[wavefrontObj object] groups] count]];

            NSUInteger index = 0;
            for (WFGroup *group in [[wavefrontObj object] groups]) {
                [asset addSubsetWithIndices:[group faceStrArray] ofObject:[wavefrontObj object] atIndex:index];
                ++index;
            }


            // loop through all values and convert them into NFLightingModel objects
            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            for (NFSurfaceModel *surface in [wavefrontObj materialsArray]) {
                // would convert the asset surface model to the internal framework
                // representation here if they were different
                [surfaceModels addObject:surface];
            }

            [asset setSurfaceModelArray:surfaceModels];

            NFSurfaceModel * (^findSurfaceModel)(NSString *) = ^ NFSurfaceModel * (NSString *name) {
                for (NFSurfaceModel *surface in [asset surfaceModelArray]) {
                    if (surface.name == name) {
                        return surface;
                    }
                }
                return nil;
            };

            NSInteger subsetIndex = 0;
            for (WFGroup *group in [[wavefrontObj object] groups]) {
                // NOTE: subsets are 1-1 with the groups, this code will need to be udpated
                //       when support for multiple objects is added
                NFAssetSubset *subset = [[asset subsetArray] objectAtIndex:subsetIndex];
                subset.surfaceModel = findSurfaceModel([group materialName]);
                ++subsetIndex;
            }
        }
        break;

        case kSolidPlane: {
            [asset createPlaneOfSize:4];
            // NOTE: default draw mode should work

            NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];

            NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
            [surfaceModels addObject:surface];

            asset.surfaceModelArray = surfaceModels;

            for (NFAssetSubset *subset in [asset subsetArray]) {
                subset.surfaceModel = [surfaceModels objectAtIndex:0];
            }
        }
        break;

        case kGridWireframe:
            [asset createGridOfSize:4];
            for (NFAssetSubset *subset in [asset subsetArray]) {
                [subset setDrawMode:kDrawLines];
            }
        break;

        case kAxisWireframe:
            [asset createAxisOfSize:10];
            for (NFAssetSubset *subset in [asset subsetArray]) {
                [subset setDrawMode:kDrawLines];
            }
        break;

        case kSolidCylinder: {
            //
            // TODO: implement
            //
        }
        break;

        case kSolidUVSphere: {
            NF_VERTEX_FORMAT vertexType = kVertexFormatDefault;

            if(firstArg != nil) {
                vertexType = (NF_VERTEX_FORMAT)firstArg;
            }

            // with radius 1.0
            // - 8   16 for low resolution
            // - 16  32 for medium resolution
            // - 32  64 for high resolution
            [asset createUVSphereWithRadius:1 withStacks:32 withSlices:64 withVertexFormat:vertexType];

            if (vertexType == kVertexFormatDefault) {
                NFSurfaceModel *surface = [NFSurfaceModel defaultSurfaceModel];
                NSMutableArray *surfaceModels = [[[NSMutableArray alloc] init] autorelease];
                [surfaceModels addObject:surface];

                asset.surfaceModelArray = surfaceModels;
                for (NFAssetSubset *subset in [asset subsetArray]) {
                    subset.surfaceModel = [surfaceModels objectAtIndex:0];
                }
            }
        }
        break;

        case kSolidCone: {
            //
            // TODO: implement
            //
        }
        break;

            //
            // TODO: would be awesome to be able to pass in an equation, a range for each variable, and number
            //       of increments per variable and the shape would be generated (would still be useful to have
            //       some custom defined functions that hardcoded the equation/ranges/slices/etc.)
            //

        default:
            NSAssert(NO, @"ERROR: received unknown type for loading asset");
        break;
    }

    return asset;
}

@end
