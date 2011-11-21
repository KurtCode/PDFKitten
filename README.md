# Kurt the PDFKitten

A framework for searching PDF documents on iOS.

### Why?

iOS, up to and including the current fifth version, does not provide any public APIs for searching PDF documents, or determining where on a page a given word is drawn. Any developer aiming to provide these features in an app must use low-level Core Graphics APIs, and keep track of the stateful process of laying out the content of the page.

This project is meant to facilitate this by implementing a complete workflow, taking as input a PDF document, a keyword string, and returning a set of selections that can be drawn on top of the PDF document.

### How?

First, create a new instance of the scanner.

```
	Scanner *scanner = [[Scanner alloc] init];
```

Set a keyword (case-insensitive) and scan a page.

```
	scanner.keyword = @"happiness";
	CGPDFPageRef page = CGPDFDocumentGetPage(document, 1);
	[scanner scanPage:page];
```

Finally, scan the page and draw the selections.

```
	for (Selection *selection in scanner.selections)
	{
		// draw selection
	}
```

### Limitations

The PDF specification is huge, allowing for different fonts, text encodings et cetera. This means strict design is a must, and thorough testing is needed. At this point, this project is not fully compatible with all font types, and especially suppert for non-latin characters will require further development.


### License and Warranty

This software is provided as is, meaning that we are not responsible for the results of its use.