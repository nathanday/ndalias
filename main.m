#import <Cocoa/Cocoa.h>
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

NSString		* kDirOfTestProject = @"~/Developer/Projects/NDAlias/";	// you need to change this to the location of NDAlias

NSString		* filePath = @"Test File.txt",
				* folderPath = @"Test Folder",
				* aliasFilePath = @"AliasFile";

void testUsingFileFolder( NSString * aFilePath );
void testCreatingAliasFileFor( NSString * aFilePath );
void testReadingAliasFile( NSString * aAliasPath );

int main (int argc, const char * argv[])
{
	NSAutoreleasePool		* pool = [[NSAutoreleasePool alloc] init];
	char					theChoice;
	char					theString[1024];
	
	printf( "Path is [%s]\n", getcwd( theString, sizeof(theString) ) );

	printf("Do you want to;\n1)\ttest alias records,\n2)\ttest writting an alias file or,\n3)\ttest reading an alias file?\n<1,  2 or 3>");

	fflush(stdout);

	theChoice = getchar();

	switch( theChoice )
	{
	case '1':
	default:
		getchar();
		testUsingFileFolder( [[kDirOfTestProject stringByAppendingString:filePath] stringByExpandingTildeInPath] );
		break;
	case '2':
//		getchar();
		testCreatingAliasFileFor( [[kDirOfTestProject stringByAppendingString:filePath] stringByExpandingTildeInPath] );
		break;
	case '3':
//		getchar();
		testReadingAliasFile( [[kDirOfTestProject stringByAppendingString:aliasFilePath] stringByExpandingTildeInPath] );
		break;
	}
	
	[pool release];
	return 0;
}

/*
 * testUsingFileFolder()
 */
void testUsingFileFolder( NSString * aFilePath )
{
	NDAlias		* theOriginalAlias = nil,
				* theNewAlias = nil;
	NSString	* theOriginalPath = nil;
	NSData		* theAliasData = nil;

	theOriginalAlias = [NDAlias aliasWithPath:aFilePath fromPath:NSHomeDirectory()];

	theOriginalPath = [theOriginalAlias path];
	
	printf("Made alias of %s\n", [theOriginalPath fileSystemRepresentation]);

	theAliasData = [NSArchiver archivedDataWithRootObject:theOriginalAlias];

	printf("OK move it somewhere and I'll try find it.\n<hit return>");
	fflush(stdout);
	while( getchar() != '\n') {};

	printf("Where could it be.\n");

	theNewAlias = [NSUnarchiver unarchiveObjectWithData:theAliasData];
	
	printf("%s\n", [[theNewAlias description] fileSystemRepresentation] );
	if( [theOriginalPath isEqualToString:[theNewAlias path]] )
	{
		printf("You didn't move it.\n");
		[[NSWorkspace sharedWorkspace] selectFile:[theNewAlias path] inFileViewerRootedAtPath:@""];
	}
	else if( [[NSFileManager defaultManager] movePath:[theNewAlias path] toPath:theOriginalPath handler:nil] )
	{
		printf("Peek a boo, I found you.\n");
		[[NSWorkspace sharedWorkspace] selectFile:[theNewAlias path] inFileViewerRootedAtPath:@""];
	}
	else
	{
		printf("OK where did you hide it.\n");
	}
}

void testCreatingAliasFileFor( NSString * aFilePath )
{
	if( [[NDAlias aliasWithPath:aFilePath fromPath:NSHomeDirectory()] writeToFile:aliasFilePath] )
	{
		printf("I have created an alias file for\n\t%s.\n", [aFilePath fileSystemRepresentation]);
		[[NSWorkspace sharedWorkspace] selectFile:aliasFilePath inFileViewerRootedAtPath:@""];
	}
	else
	{
		printf("Alias file creation failed.\n");
	}
}

void testReadingAliasFile( NSString * aAliasPath )
{
	NDAlias		* theNewAlias;
	
	if( theNewAlias = [NDAlias aliasWithContentsOfFile:aAliasPath] )
	{
		printf("Here is the original for %s.\n", [aAliasPath fileSystemRepresentation]);
		[[NSWorkspace sharedWorkspace] selectFile:[theNewAlias path] inFileViewerRootedAtPath:@""];
	}
	else
	{
		printf("Alias file reading has failed.\n");
	}
}
