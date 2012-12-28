#import "Scanner.h"

BOOL isSpace(float width, Scanner *scanner) {
	return abs(width) >= scanner.renderingState.font.widthOfSpace;
}

void didScanSpace(float value, void *info) {
	Scanner *scanner = (Scanner *) info;
    float width = [scanner.renderingState convertToUserSpace:value];
    [scanner.renderingState translateTextPosition:CGSizeMake(-width, 0)];
    if (isSpace(value, scanner)) {
        [scanner.stringDetector reset];
    }
}

void didScanString(CGPDFStringRef pdfString, void *info) {
	Scanner *scanner = (Scanner *) info;
	StringDetector *stringDetector = scanner.stringDetector;
	Font *font = scanner.renderingState.font;
	NSString *string = [stringDetector appendPDFString:pdfString withFont:font];
	[scanner.content appendString:string];
}

void didScanNewLine(CGPDFScannerRef pdfScanner, Scanner *scanner, BOOL persistLeading) {
	CGPDFReal tx, ty;
	CGPDFScannerPopNumber(pdfScanner, &ty);
	CGPDFScannerPopNumber(pdfScanner, &tx);
	[scanner.renderingState newLineWithLeading:-ty indent:tx save:persistLeading];
}

CGPDFStringRef getString(CGPDFScannerRef pdfScanner) {
	CGPDFStringRef pdfString;
	CGPDFScannerPopString(pdfScanner, &pdfString);
	return pdfString;
}

CGPDFReal getNumber(CGPDFScannerRef pdfScanner) {
	CGPDFReal value;
	CGPDFScannerPopNumber(pdfScanner, &value);
	return value;
}

CGPDFArrayRef getArray(CGPDFScannerRef pdfScanner) {
	CGPDFArrayRef pdfArray;
	CGPDFScannerPopArray(pdfScanner, &pdfArray);
	return pdfArray;
}

CGPDFObjectRef getObject(CGPDFArrayRef pdfArray, int index) {
	CGPDFObjectRef pdfObject;
	CGPDFArrayGetObject(pdfArray, index, &pdfObject);
	return pdfObject;
}

CGPDFStringRef getStringValue(CGPDFObjectRef pdfObject) {
	CGPDFStringRef string;
	CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeString, &string);
	return string;
}

float getNumericalValue(CGPDFObjectRef pdfObject, CGPDFObjectType type) {
	if (type == kCGPDFObjectTypeReal) {
		CGPDFReal tx;
		CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeReal, &tx);
		return tx;
	}
	else if (type == kCGPDFObjectTypeInteger) {
		CGPDFInteger tx;
		CGPDFObjectGetValue(pdfObject, kCGPDFObjectTypeInteger, &tx);
		return tx;
	}

	return 0;
}

CGAffineTransform getTransform(CGPDFScannerRef pdfScanner) {
	CGAffineTransform transform;
	transform.ty = getNumber(pdfScanner);
	transform.tx = getNumber(pdfScanner);
	transform.d = getNumber(pdfScanner);
	transform.c = getNumber(pdfScanner);
	transform.b = getNumber(pdfScanner);
	transform.a = getNumber(pdfScanner);
	return transform;
}

#pragma mark Text parameters

void setHorizontalScale(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setHorizontalScaling:getNumber(pdfScanner)];
}

void setTextLeading(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setLeadning:getNumber(pdfScanner)];
}

void setFont(CGPDFScannerRef pdfScanner, void *info) {
	CGPDFReal fontSize;
	const char *fontName;
	CGPDFScannerPopNumber(pdfScanner, &fontSize);
	CGPDFScannerPopName(pdfScanner, &fontName);
	
	Scanner *scanner = (Scanner *) info;
	RenderingState *state = scanner.renderingState;
	Font *font = [scanner.fontCollection fontNamed:[NSString stringWithUTF8String:fontName]];
	[state setFont:font];
	[state setFontSize:fontSize];
}

void setTextRise(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setTextRise:getNumber(pdfScanner)];
}

void setCharacterSpacing(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setCharacterSpacing:getNumber(pdfScanner)];
}

void setWordSpacing(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setWordSpacing:getNumber(pdfScanner)];
}


#pragma mark Set position

void newLine(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState newLine];
}

void newLineWithLeading(CGPDFScannerRef pdfScanner, void *info) {
	didScanNewLine(pdfScanner, (Scanner *) info, NO);
}

void newLineSetLeading(CGPDFScannerRef pdfScanner, void *info) {
	didScanNewLine(pdfScanner, (Scanner *) info, YES);
}

void newParagraph(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setTextMatrix:CGAffineTransformIdentity replaceLineMatrix:YES];
}

void setTextMatrix(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingState setTextMatrix:getTransform(pdfScanner) replaceLineMatrix:YES];
}


#pragma mark Print strings

void printString(CGPDFScannerRef pdfScanner, void *info) {
	didScanString(getString(pdfScanner), info);
}

void printStringNewLine(CGPDFScannerRef scanner, void *info) {
	newLine(scanner, info);
	printString(scanner, info);
}

void printStringNewLineSetSpacing(CGPDFScannerRef scanner, void *info) {
	setWordSpacing(scanner, info);
	setCharacterSpacing(scanner, info);
	printStringNewLine(scanner, info);
}

void printStringsAndSpaces(CGPDFScannerRef pdfScanner, void *info) {
	CGPDFArrayRef array = getArray(pdfScanner);
	for (int i = 0; i < CGPDFArrayGetCount(array); i++) {
		CGPDFObjectRef pdfObject = getObject(array, i);
		CGPDFObjectType valueType = CGPDFObjectGetType(pdfObject);

		if (valueType == kCGPDFObjectTypeString) {
			didScanString(getStringValue(pdfObject), info);
		}
		else {
			didScanSpace(getNumericalValue(pdfObject, valueType), info);
		}
	}
}


#pragma mark Graphics state operators

void pushRenderingState(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	RenderingState *state = [scanner.renderingState copy];
	[scanner.renderingStateStack pushRenderingState:state];
	[state release];
}

void popRenderingState(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	[scanner.renderingStateStack popRenderingState];
}

/* Update CTM */
void applyTransformation(CGPDFScannerRef pdfScanner, void *info) {
	Scanner *scanner = (Scanner *) info;
	RenderingState *state = scanner.renderingState;
	state.ctm = CGAffineTransformConcat(getTransform(pdfScanner), state.ctm);
}
