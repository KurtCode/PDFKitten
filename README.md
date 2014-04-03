# Kurt the PDFKitten

A framework for searching PDF documents on iOS.

### Why?

iOS, up to and including the current fifth version, does not provide any public APIs for searching PDF documents, or determining where on a page a given word is drawn. Any developer aiming to provide these features in an app must use low-level Core Graphics APIs, and keep track of the stateful process of laying out the content of the page.

This project is meant to facilitate this by implementing a complete workflow, taking as input a PDF document, a keyword string, and returning a set of selections that can be drawn on top of the PDF document.

### How?

First, create a new instance of the scanner.

```
	CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
	Scanner *scanner = [Scanner scannerWithPage:page];
```

Set a keyword (case-insensitive) and scan a page.

```
	NSArray *selections = [scanner select:@"happiness"];
```

Finally, scan the page and draw the selections.

```
	for (Selection *selection in selections)
	{
		// draw selection
	}
```

### Limitations

The PDF specification is huge, allowing for different fonts, text encodings et cetera. This means strict design is a must, and thorough testing is needed. At this point, this project is not fully compatible with all font types, and especially suppert for non-latin characters will require further development.

Offering a complete solution for processing any PDF document would apparently require the inclusion of a complete library of font files. We currently do not intend to include more than the bare essentials for a proof-of-concept application. 

Only latin character sets are currently supported.

### License and Warranty

This software is provided under the MIT license, see License.txt.
