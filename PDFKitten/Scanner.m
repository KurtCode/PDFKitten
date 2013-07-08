#import "Scanner.h"
#import "pdfScannerCallbacks.mm"

@implementation Scanner

+ (Scanner *)scannerWithPage:(CGPDFPageRef)page {
	return [[[Scanner alloc] initWithPage:page] autorelease];
}

- (id)initWithPage:(CGPDFPageRef)page {
	if (self = [super init]) {
		pdfPage = page;
		self.fontCollection = [self fontCollectionWithPage:pdfPage];
		self.selections = [NSMutableArray array];
	}
	
	return self;
}

- (NSArray *)select:(NSString *)keyword {
    self.content = [NSMutableString string];
	self.stringDetector = [StringDetector detectorWithKeyword:keyword delegate:self];
	[self.selections removeAllObjects];
    self.renderingStateStack = [RenderingStateStack stack];
    
 	CGPDFOperatorTableRef operatorTable = [self newOperatorTable];
	CGPDFContentStreamRef contentStream = CGPDFContentStreamCreateWithPage(pdfPage);
	CGPDFScannerRef scanner = CGPDFScannerCreate(contentStream, operatorTable, self);
	CGPDFScannerScan(scanner);
	
	CGPDFScannerRelease(scanner);
	CGPDFContentStreamRelease(contentStream);
	CGPDFOperatorTableRelease(operatorTable);
	
    self.stringDetector.delegate = nil;
    self.stringDetector = nil;
    
	return self.selections;
}

- (CGPDFOperatorTableRef)newOperatorTable {
	CGPDFOperatorTableRef operatorTable = CGPDFOperatorTableCreate();

	// Text-showing operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tj", printString);
	CGPDFOperatorTableSetCallback(operatorTable, "\'", printStringNewLine);
	CGPDFOperatorTableSetCallback(operatorTable, "\"", printStringNewLineSetSpacing);
	CGPDFOperatorTableSetCallback(operatorTable, "TJ", printStringsAndSpaces);
	
	// Text-positioning operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tm", setTextMatrix);
	CGPDFOperatorTableSetCallback(operatorTable, "Td", newLineWithLeading);
	CGPDFOperatorTableSetCallback(operatorTable, "TD", newLineSetLeading);
	CGPDFOperatorTableSetCallback(operatorTable, "T*", newLine);
	
	// Text state operators
	CGPDFOperatorTableSetCallback(operatorTable, "Tw", setWordSpacing);
	CGPDFOperatorTableSetCallback(operatorTable, "Tc", setCharacterSpacing);
	CGPDFOperatorTableSetCallback(operatorTable, "TL", setTextLeading);
	CGPDFOperatorTableSetCallback(operatorTable, "Tz", setHorizontalScale);
	CGPDFOperatorTableSetCallback(operatorTable, "Ts", setTextRise);
	CGPDFOperatorTableSetCallback(operatorTable, "Tf", setFont);
	
	// Graphics state operators
	CGPDFOperatorTableSetCallback(operatorTable, "cm", applyTransformation);
	CGPDFOperatorTableSetCallback(operatorTable, "q", pushRenderingState);
	CGPDFOperatorTableSetCallback(operatorTable, "Q", popRenderingState);
	
	CGPDFOperatorTableSetCallback(operatorTable, "BT", newParagraph);
	
	return operatorTable;
}

/* Create a font dictionary given a PDF page */
- (FontCollection *)fontCollectionWithPage:(CGPDFPageRef)page {
	CGPDFDictionaryRef dict = CGPDFPageGetDictionary(page);
	if (!dict) 	{
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing");
		return nil;
	}
	
	CGPDFDictionaryRef resources;
	if (!CGPDFDictionaryGetDictionary(dict, "Resources", &resources)) {
		NSLog(@"Scanner: fontCollectionWithPage: page dictionary missing Resources dictionary");
		return nil;
	}

	CGPDFDictionaryRef fonts;
	if (!CGPDFDictionaryGetDictionary(resources, "Font", &fonts)) {
		return nil;
	}

	FontCollection *collection = [[FontCollection alloc] initWithFontDictionary:fonts];
	return [collection autorelease];
}

- (void)detector:(StringDetector *)detector didScanCharacter:(unichar)character {
    Font *font = self.renderingState.font;
    unichar cid = character;
    if (font.toUnicode) {
        cid = [font.toUnicode cidCharacter:character];
    }

	CGFloat width = [font widthOfCharacter:cid withFontSize:self.renderingState.fontSize];
	width /= 1000;
	width += self.renderingState.characterSpacing;
	if (character == 32) {
		width += self.renderingState.wordSpacing;
	}

	[self.renderingState translateTextPosition:CGSizeMake(width, 0)];
}

- (void)detectorDidStartMatching:(StringDetector *)detector {
    possibleSelection = [[Selection selectionWithState:self.renderingState] retain];
}

- (void)detectorFoundString:(StringDetector *)detector {
    if (possibleSelection) {
	    possibleSelection.finalState = self.renderingState;
        [self.selections addObject:possibleSelection];
        [possibleSelection release];
        possibleSelection = nil;
    }
}

- (RenderingState *)renderingState {
	return [self.renderingStateStack topRenderingState];
}

- (void)dealloc {
    [possibleSelection release];
	[fontCollection release];
	[selections release];
	[renderingStateStack release];
	[stringDetector release];
	[content release];
	[super dealloc];
}

@synthesize stringDetector, fontCollection, renderingStateStack, content, selections, renderingState;
@end
