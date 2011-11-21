#import "DocumentsView.h"

@implementation DocumentsView

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)loadDocuments
{
	NSArray *userDocuments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSURL *docementsURL = [NSURL fileURLWithPath:[userDocuments lastObject]];
	NSLog(@"%@", docementsURL);
	NSArray *documentsURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:docementsURL 
														   includingPropertiesForKeys:nil 
																			  options:NSDirectoryEnumerationSkipsHiddenFiles
																				error:nil];

	NSMutableArray *names = [NSMutableArray array];
	NSMutableDictionary *urls = [NSMutableDictionary dictionary];

	NSArray *bundledResources = [[NSBundle mainBundle] URLsForResourcesWithExtension:@"pdf" subdirectory:nil];
	documentsURLs = [documentsURLs arrayByAddingObjectsFromArray:bundledResources];

	for (NSURL *docURL in documentsURLs)
	{
		NSString *title = [[docURL lastPathComponent] stringByDeletingPathExtension];
		[names addObject:title];
		[urls setObject:docURL forKey:title];
	}

	documents = [[NSArray alloc] initWithArray:[names sortedArrayUsingSelector:@selector(compare:)]];
	urlsByName = [[NSDictionary alloc] initWithDictionary:urls];
}

- (void)viewDidLoad
{
	tableViewController = [[UITableViewController alloc] init];
	tableViewController.tableView.delegate = self;
	tableViewController.tableView.dataSource = self;
	tableViewController.navigationItem.title = @"Library";

	[self loadDocuments];
	
	[self pushViewController:tableViewController animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self setContentSizeForViewInPopover:CGSizeMake(100, 100)];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [documents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *identifier = @"CellIdentifier";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	NSString *title = [documents objectAtIndex:indexPath.row];
	cell.textLabel.text = title;
	cell.detailTextLabel.text = [[urlsByName objectForKey:title] relativePath];
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *title = [documents objectAtIndex:indexPath.row];
	NSURL *url = [urlsByName objectForKey:title];

	if ([delegate respondsToSelector:@selector(didSelectDocument:)])
	{
		[delegate performSelector:@selector(didSelectDocument:) withObject:url];
	}
}


#pragma mark Memory Management

- (void)dealloc
{
	[tableViewController release];
	[documents release];
	[super dealloc];
}

@synthesize delegate;
@end
