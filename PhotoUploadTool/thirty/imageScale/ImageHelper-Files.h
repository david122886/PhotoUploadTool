/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook, 3.0 Edition
 BSD License, Use at your own risk
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
CGContextRef CreateARGBBitmapContext (CGSize size);
void FlipContextVertically(CGContextRef context, CGSize size);
void addRoundedRectToContext(CGContextRef context, CGRect rect, CGSize ovalSize);

@interface ImageHelper : NSObject
@end

@interface ImageHelper (Files)
+ (NSString *) documentsFolder;
+ (NSString *) bundleFolder;
+ (NSString *) DCIMFolder;
+ (UIImage *) imageNamed: (NSString *) aName;
+ (UIImage *) imageFromURLString: (NSString *) urlstring;
+ (NSArray *) DCIMImages;
+ (UIImage *) DCIMImageNamed: (NSString *) aName;


// Create image
+ (UIImage *) imageFromView: (UIView *) theView;

// Bits
+ (UIImage *) imageWithBits: (unsigned char *) bits withSize: (CGSize) size;
+ (unsigned char *) bitmapFromImage: (UIImage *) image;

// Base Image Fitting
+ (CGSize) fitSize: (CGSize)thisSize inSize: (CGSize) aSize;
+ (CGRect) frameSize: (CGSize)thisSize inSize: (CGSize) aSize;

+ (UIImage *) unrotateImage: (UIImage *) image;

+ (UIImage *) image: (UIImage *) image fitInSize: (CGSize) size; // retain proportions, fit in size
+ (UIImage *) image: (UIImage *) image fitInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image centerInSize: (CGSize) size; // center, no resize
+ (UIImage *) image: (UIImage *) image centerInView: (UIView *) view; 

+ (UIImage *) image: (UIImage *) image fillSize: (CGSize) size; // fill all pixels
+ (UIImage *) image: (UIImage *) image fillView: (UIView *) view; 
+ (UIImage *)scale:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *) cutImage:(UIImage *) image cutRect:(CGRect)rect;
// Paths
+ (void) addRoundedRect:(CGRect) rect toContext:(CGContextRef) context withOvalSize:(CGSize) ovalSize;
+ (UIImage *) roundedImage: (UIImage *) image withOvalSize: (CGSize) ovalSize withInset: (CGFloat) inset;
+ (UIImage *) roundedImage: (UIImage *) img withOvalSize: (CGSize) ovalSize;
+ (UIImage *) roundedBacksplashOfSize: (CGSize)size andColor:(UIColor *) color withRounding: (CGFloat) rounding andInset: (CGFloat) inset;
+ (UIImage *) ellipseImage: (UIImage *) image withInset: (CGFloat) inset;

#if SUPPPORTS_UNDOCUMENTED_APIS
+ (UIImage *) image: (UIImage *) image withOrientation: (UIImageOrientation) orientation;
#endif

+ (CGSize) fitImageSize: (CGSize)thisSize inwidth: (int) width;
+ (CGSize) fitImageSize: (CGSize)thisSize inheight: (int) height;

@end
