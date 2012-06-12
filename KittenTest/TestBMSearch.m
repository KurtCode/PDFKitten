#import "TestBMSearch.h"
#import "BMSearcher.h"

@implementation TestBMSearch

- (void)testBMSearch {
	BMSearcher *seacher = [[BMSearcher alloc] initWithPattern:@"Kurt"];
	[seacher search:@"KuKurtTheKurtKurtCat"];
}

@end
