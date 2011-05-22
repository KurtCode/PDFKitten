#import "Scanner.h"


@interface Scanner ()

// Text-showing operators
void Tj(CGPDFScannerRef scanner, void *info);
void quot(CGPDFScannerRef scanner, void *info);
void doubleQuot(CGPDFScannerRef scanner, void *info);
void TJ(CGPDFScannerRef scanner, void *info);

// Text-positioning operators
void Td(CGPDFScannerRef scanner, void *info);
void TD(CGPDFScannerRef scanner, void *info);
void Tm(CGPDFScannerRef scanner, void *info);
void TStar(CGPDFScannerRef scanner, void *info);

// Text state operators
void Tc(CGPDFScannerRef scanner, void *info);
void Tw(CGPDFScannerRef scanner, void *info);
void Tz(CGPDFScannerRef scanner, void *info);
void TL(CGPDFScannerRef scanner, void *info);
void Tf(CGPDFScannerRef scanner, void *info);
void Ts(CGPDFScannerRef scanner, void *info);

// Special graphics state operators
void q(CGPDFScannerRef scanner, void *info);
void Q(CGPDFScannerRef scanner, void *info);
void cm(CGPDFScannerRef scanner, void *info);

void BT(CGPDFScannerRef scanner, void *info);

@property (nonatomic, retain) Selection *currentSelection;
@property (nonatomic, readonly) RenderingState *currentRenderingState;
@property (nonatomic, readonly) Font *currentFont;
@property (nonatomic, readonly) CGPDFDocumentRef pdfDocument;
@property (nonatomic, copy) NSURL *documentURL;
@property (nonatomic, readonly) CGPDFOperatorTableRef operatorTable;
@end

@implementation Scanner

- (id)initWithDocument:(CGPDFDocumentRef)document
{
	if ((self = [super init]))
	{
		pdfDocument = CGPDFDocumentRetain(document);
	}
	return self;
}

- (id)initWithContentsOfFile:(NSString *)path
{
	if ((self = [super init]))
	{
		self.documentURL = [NSURL fileURLWithPath:path];
	}
	return self;
}

- (RenderingState *)currentRenderingState
{
	return [[self renderingStateStack] topRenderingState];
}

- (Font *)currentFont
{
	return [[[self renderingStateStack] topRenderingState] font];
}

- (CGPDFDocumentRef)pdfDocument
{
	if (!pdfDocument)
	{
		pdfDocument = CGPDFDocumentCreateWithURL((CFURLRef)self.documentURL);
	}
	return pdfDocument;
}

/* The operator table used for scanning PDF pages */
- (CGPDFOperatorTableRef)operatorTable
{
	if (operatorTable)
	{
		return operatorTable;
	}
	
	operatorTable = CGPDFOperatorTableCreate();

	// Text-showing operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tj", Tj);
	CGPDFOperatorTableSetCallback(operatorTable, "\'", quot);
	CGPDFOperatorTableSetCallback(operatorTable, "\"", doubleQuot);
	CGPDFOperatorTableSetCallback(operatorTable, "TJ", TJ);
	
	// Text-positioning operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tm", Tm);
	CGPDFOperatorTableSetCallback(operatorTable, "Td", Td);		
	CGPDFOperatorTableSetCallback(operatorTable, "TD", TD);
	CGPDFOperatorTableSetCallback(operatorTable, "T*", TStar);
	
	// Text state operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tw", Tw);
	CGPDFOperatorTableSetCallback(operatorTable, "Tc", Tc);
	CGPDFOperatorTableSetCallback(operatorTable, "TL", TL);
	CGPDFOperatorTableSetCallback(operatorTable, "Tz", Tz);
	CGPDFOperatorTableSetCallback(operatorTable, "Ts", Ts);
	CGPDFOperatorTableSetCallback(operatorTable, "Tf", Tf);
	
	// Graphics state operators
	CGPDFOperatorTableSetCallback(operatorTable, "cm", cm);
	CGPDFOperatorTableSetCallback(operatorTable, "q", q);
	CGPDFOperatorTableSetCallback(operatorTable, "Q", Q);
	
	CGPDFOperatorTableSetCallback(operatorTable, "BT", BT);
	
	return operatorTable;
}

/* Create a font dictionary given a PDF page */
- (FontCollection *)fontCollectionWithPage:(CGPDFPageRef)page
{
	CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
	CGPDFDictionaryRef resources;
	if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources)) return nil;
	CGPDFDictionaryRef fonts;
	if (!CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) return nil;
	FontCollection *collection = [[FontCollection alloc] initWithFontDictionary:fonts];
	return [collection autorelease];
}

void embeddedObject(const char *key, CGPDFObjectRef object, void *info)
{
	if (!CGPDFObjectGetType(object) == kCGPDFObjectTypeStream) return;
	
	CGPDFStreamRef stream = nil;
	if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeStream, &stream)) return;
	
	CGPDFDictionaryRef meta = CGPDFStreamGetDictionary(stream);
	
	const char *subtype;
	if (!CGPDFDictionaryGetName(meta, "Subtype", &subtype)) return;
	
	if (strcmp(subtype, "Image") != 0) return;

	NSString *keyString = [NSString stringWithCString:key encoding:NSUTF8StringEncoding];
	if (!keyString)
	{
		keyString = [NSString stringWithFormat:@"Object%d", [(NSMutableDictionary *)info count]];
	}

	CGPDFArrayRef colorSpace;
	if (!CGPDFDictionaryGetArray(meta, "ColorSpace", &colorSpace)) return;
	
	CGPDFStreamRef csStream;
	if (!CGPDFArrayGetStream(colorSpace, 1, &csStream)) return;
	
	CFDataRef csData = CGPDFStreamCopyData(csStream, nil);
	
	CGDataProviderRef csProvider = CGDataProviderCreateWithCFData(csData);
	CFRelease(csData);
	
	NSData *data = (NSData *) CGPDFStreamCopyData(stream, nil);
	
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)data);
	
	CGColorSpaceRef rgbSpace = CGColorSpaceCreateDeviceRGB();
	
	const CGFloat range[8] = {0, 255, 0, 255, 0, 255};
	
	CGColorSpaceRef cs = CGColorSpaceCreateICCBased(3, range, csProvider, rgbSpace);
	const CGFloat decodeValues[6] = {0.0, 1.0, 0.0, 1.0, 0.0, 1.0};
	CGImageRef sourceImage = CGImageCreate(505, 185, 8, 8 * 3, 1515, cs, 0, provider, decodeValues, NO, kCGRenderingIntentDefault);
	UIImage *image = [UIImage imageWithCGImage:sourceImage];
	CGImageRelease(sourceImage);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(rgbSpace);
	CGColorSpaceRelease(cs);
	CGDataProviderRelease(csProvider);

	[(NSMutableDictionary *)info setObject:image forKey:keyString];
	
	
	[data release];
}

- (NSDictionary *)embeddedImages:(CGPDFPageRef)page
{
	CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
	CGPDFDictionaryRef resources;
	if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources)) return nil;
	CGPDFDictionaryRef objects;
	if (!CGPDFDictionaryGetDictionary(resources, "XObject", &objects)) return nil;
	
	NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
	CGPDFDictionaryApplyFunction(objects, embeddedObject, mutableDict);
	return mutableDict;
}

/* Scan the given page of the current document */
- (void)scanPage:(NSUInteger)pageNumber
{
	// Return immediately if no keyword set
	if (!keyword) return;

	[self.stringDetector reset];

	CGPDFPageRef page = CGPDFDocumentGetPage(self.pdfDocument, pageNumber);

	// Initialize font collection (per page)
	self.fontCollection = [self fontCollectionWithPage:page];
	
//	NSDictionary *images = [self embeddedImages:page];
//	for (NSString *str in [images allKeys])
//	{
//		UIImage *image = [images objectForKey:str];
//		NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//		NSString *path = [[docs lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", str]];
//		[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
//	}
		
	CGPDFContentStreamRef content = CGPDFContentStreamCreateWithPage(page);
	CGPDFScannerRef scanner = CGPDFScannerCreate(content, self.operatorTable, self);
	CGPDFScannerScan(scanner);
	CGPDFScannerRelease(scanner); scanner = nil;
	CGPDFContentStreamRelease(content); content = nil;
}


#pragma mark -
#pragma mark StringDetectorDelegate

- (void)detector:(StringDetector *)detector didScanCharacter:(unichar)character
{
	RenderingState *state = [self currentRenderingState];
	CGFloat width = [self.currentFont widthOfCharacter:character withFontSize:state.fontSize];
	width /= 1000;
	width += state.characterSpacing;
	if (character == 32)
	{
		width += state.wordSpacing;
	}
	[state translateTextPosition:CGSizeMake(width, 0)];
}

- (void)detector:(StringDetector *)detector didStartMatchingString:(NSString *)string
{
	Selection *sel = [[Selection alloc] initWithStartState:self.currentRenderingState];
	self.currentSelection = sel;
	[sel release];
}

- (void)detector:(StringDetector *)detector foundString:(NSString *)needle
{
	RenderingState *state = [[self renderingStateStack] topRenderingState];
	[self.currentSelection finalizeWithState:state];
		
	if (self.currentSelection)
	{
		[self.selections addObject:self.currentSelection];
		self.currentSelection = nil;
	}
}

void BT(CGPDFScannerRef scanner, void *info)
{
	[[(Scanner *)info currentRenderingState] setTextMatrix:CGAffineTransformIdentity replaceLineMatrix:YES];
}

#pragma mark Text showing operators

/* Called any time the scanner scans a string */
void didScanString(CGPDFStringRef pdfString, Scanner *scanner)
{
	[[scanner stringDetector] appendPDFString:pdfString withFont:[scanner currentFont]];
}

/* Show a string */
void Tj(CGPDFScannerRef scanner, void *info)
{
	CGPDFStringRef pdfString = nil;
	if (!CGPDFScannerPopString(scanner, &pdfString)) return;
	didScanString(pdfString, info);
}

/* Equivalent to operator sequence [T*, Tj] */
void quot(CGPDFScannerRef scanner, void *info)
{
	TStar(scanner, info);
	Tj(scanner, info);
}

/* Equivalent to the operator sequence [Tw, Tc, '] */
void doubleQuot(CGPDFScannerRef scanner, void *info)
{
	Tw(scanner, info);
	Tc(scanner, info);
	quot(scanner, info);
}

/* Array of strings and spacings */
void TJ(CGPDFScannerRef scanner, void *info)
{
	CGPDFArrayRef array;
	if (!CGPDFScannerPopArray(scanner, &array)) return;
	
	for (int i = 0; i < CGPDFArrayGetCount(array); i++)
	{
		CGPDFObjectRef object;
		if (!CGPDFArrayGetObject(array, i, &object)) continue;
		CGPDFObjectType type = CGPDFObjectGetType(object);

		if (type == kCGPDFObjectTypeString)
		{
			CGPDFStringRef pdfString;
			if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeString, &pdfString)) continue;
			didScanString(pdfString, info);
		}
		else if (type == kCGPDFObjectTypeReal)
		{
			RenderingState *state = [(Scanner *)info currentRenderingState];
			CGPDFReal tx;
			if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeReal, &tx)) continue;
			float width = (float)tx/1000*[state fontSize];
			[state translateTextPosition:CGSizeMake(-width, 0)];
			
			if (abs(tx) >= [state.font widthOfSpace])
			{
				[[(Scanner *)info stringDetector] reset];
			}
		}
		else if (type == kCGPDFObjectTypeInteger)
		{
			RenderingState *state = [(Scanner *)info currentRenderingState];
			CGPDFInteger tx;
			if (!CGPDFObjectGetValue(object, kCGPDFObjectTypeInteger, &tx)) continue;
			float width = (float)tx/1000*[state fontSize];
			[state translateTextPosition:CGSizeMake(-width, 0)];

			if (abs(tx) >= [state.font widthOfSpace])
			{
				[[(Scanner *)info stringDetector] reset];
			}
		}
		else
		{
			NSLog(@"Unsupported value: %d", type);
		}
	}
}

#pragma mark Text positioning operators

/* Move to start of next line */
void Td(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	[[(Scanner *)info currentRenderingState] newLineWithLineHeight:ty indent:tx save:NO];
}

/* Move to start of next line, and set leading */
void TD(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	[[(Scanner *)info currentRenderingState] newLineWithLineHeight:ty indent:tx save:YES];
}

/* Set line and text matrixes */
void Tm(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	if (!CGPDFScannerPopNumber(scanner, &d)) return;
	if (!CGPDFScannerPopNumber(scanner, &c)) return;
	if (!CGPDFScannerPopNumber(scanner, &b)) return;
	if (!CGPDFScannerPopNumber(scanner, &a)) return;
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
	[[(Scanner *)info currentRenderingState] setTextMatrix:t replaceLineMatrix:YES];
}

/* Go to start of new line, using stored text leading */
void TStar(CGPDFScannerRef scanner, void *info)
{
	[[(Scanner *)info currentRenderingState] newLine];
}

#pragma mark Text State operators

/* Set character spacing */
void Tc(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal charSpace;
	if (!CGPDFScannerPopNumber(scanner, &charSpace)) return;
	[[(Scanner *)info currentRenderingState] setCharacterSpacing:charSpace];
}

/* Set word spacing */
void Tw(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal wordSpace;
	if (!CGPDFScannerPopNumber(scanner, &wordSpace)) return;
	[[(Scanner *)info currentRenderingState] setWordSpacing:wordSpace];
}

/* Set horizontal scale factor */
void Tz(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal hScale;
	if (!CGPDFScannerPopNumber(scanner, &hScale)) return;
	[[(Scanner *)info currentRenderingState] setHorizontalScaling:hScale];
}

/* Set text leading */
void TL(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal leading;
	if (!CGPDFScannerPopNumber(scanner, &leading)) return;
	[[(Scanner *)info currentRenderingState] setLeadning:leading];
}

/* Font and font size */
void Tf(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal fontSize;
	const char *fontName;
	if (!CGPDFScannerPopNumber(scanner, &fontSize)) return;
	if (!CGPDFScannerPopName(scanner, &fontName)) return;
	RenderingState *state = [(Scanner *)info currentRenderingState];
	Font *font = [[(Scanner *)info fontCollection] fontNamed:[NSString stringWithUTF8String:fontName]];
	[state setFont:font];
	[state setFontSize:fontSize];
}

/* Set text rise */
void Ts(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal rise;
	if (!CGPDFScannerPopNumber(scanner, &rise)) return;
	[[(Scanner *)info currentRenderingState] setTextRise:rise];
}


#pragma mark Graphics state operators

/* Push a copy of current rendering state */
void q(CGPDFScannerRef scanner, void *info)
{
	RenderingStateStack *stack = [(Scanner *)info renderingStateStack];
	RenderingState *state = [[(Scanner *)info currentRenderingState] copy];
	[stack pushRenderingState:state];
	[state release];
}

/* Pop current rendering state */
void Q(CGPDFScannerRef scanner, void *info)
{
	[[(Scanner *)info renderingStateStack] popRenderingState];
}

/* Update CTM */
void cm(CGPDFScannerRef scanner, void *info)
{
	CGPDFReal a, b, c, d, tx, ty;
	if (!CGPDFScannerPopNumber(scanner, &ty)) return;
	if (!CGPDFScannerPopNumber(scanner, &tx)) return;
	if (!CGPDFScannerPopNumber(scanner, &d)) return;
	if (!CGPDFScannerPopNumber(scanner, &c)) return;
	if (!CGPDFScannerPopNumber(scanner, &b)) return;
	if (!CGPDFScannerPopNumber(scanner, &a)) return;
	
	RenderingState *state = [(Scanner *)info currentRenderingState];
	CGAffineTransform t = CGAffineTransformMake(a, b, c, d, tx, ty);
	state.ctm = CGAffineTransformConcat(state.ctm, t);
}


#pragma mark -
#pragma mark Memory management

- (RenderingStateStack *)renderingStateStack
{
	if (!renderingStateStack)
	{
		renderingStateStack = [[RenderingStateStack alloc] init];
	}
	return renderingStateStack;
}

- (StringDetector *)stringDetector
{
	if (!stringDetector)
	{
		stringDetector = [[StringDetector alloc] initWithKeyword:self.keyword];
		stringDetector.delegate = self;
	}
	return stringDetector;
}

- (NSMutableArray *)selections
{
	if (!selections)
	{
		selections = [[NSMutableArray alloc] init];
	}
	return selections;
}

- (void)dealloc
{
	CGPDFOperatorTableRelease(operatorTable);
	[currentSelection release];
	[fontCollection release];
	[renderingStateStack release];
	[keyword release]; keyword = nil;
	[stringDetector release];
	[documentURL release]; documentURL = nil;
	CGPDFDocumentRelease(pdfDocument); pdfDocument = nil;
	[super dealloc];
}

@synthesize documentURL, keyword, stringDetector, fontCollection, renderingStateStack, currentSelection, selections;
@end
