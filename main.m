/*
	main.m

	Created by Nathan Day on 05.12.01 under a MIT-style license.
	Copyright (c) 2008-2011 Nathan Day

	Permission is hereby granted, free of charge, to any person obtaining a copy
	of this software and associated documentation files (the "Software"), to deal
	in the Software without restriction, including without limitation the rights
	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
	copies of the Software, and to permit persons to whom the Software is
	furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included in
	all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
	THE SOFTWARE.
 */

#import <AppKit/AppKit.h>
#import "NDAlias.h"
#import "NDAlias+AliasFile.h"

// ********** you need to change this to the location of the folder containing NDAlias.xcodeproj **********
// ********** and it must be within your home folder somewhere.                                  **********
static NSString * const		kDirOfTestProject = @"~/Developer/Projects/NDAlias/";

static NSString * const		kTestFileName = @"Test File.txt";
static NSString * const		kAliasFileName = @"AliasFile";

static void testUsingFileFolder( NSString * aFilePath );
static void testCreatingAliasFileFor( NSString * aFilePath );
static void testReadingAliasFile( NSString * aAliasPath );

int main (int argc, const char * argv[])
{
	(void)argc;
	(void)argv;
	
	NSAutoreleasePool		* pool = [[NSAutoreleasePool alloc] init];
	char					theChoice;
	char					theString[PATH_MAX];
	
	printf( "Path is [%s]\n", getcwd( theString, sizeof(theString) ) );

	printf("Do you want to;\n1)\ttest alias records,\n2)\ttest writing an alias file or,\n3)\ttest reading an alias file?\n<1, 2 or 3>");

	fflush(stdout);

	theChoice = getchar();

	switch( theChoice )
	{
	case '1':
	default:
		getchar();
		testUsingFileFolder( [[kDirOfTestProject stringByAppendingPathComponent:kTestFileName] stringByExpandingTildeInPath] );
		break;
	case '2':
//		getchar();
		testCreatingAliasFileFor( [[kDirOfTestProject stringByAppendingPathComponent:kTestFileName] stringByExpandingTildeInPath] );
		break;
	case '3':
//		getchar();
		testReadingAliasFile( [[kDirOfTestProject stringByAppendingPathComponent:kAliasFileName] stringByExpandingTildeInPath] );
		break;
	}
	
	[pool drain];
	return 0;
}

/*
 * testUsingFileFolder()
 */
static void testUsingFileFolder( NSString * aFilePath )
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
		printf("OK, where did you hide it?\n");
	}
}

static void testCreatingAliasFileFor( NSString * aFilePath )
{
	NDAlias		* theAlias = [NDAlias aliasWithPath:aFilePath fromPath:NSHomeDirectory()];
	
	if( [theAlias writeToFile:kAliasFileName] )
	{
		printf("I have created an alias file for\n\t%s.\n", [aFilePath fileSystemRepresentation]);
		[[NSWorkspace sharedWorkspace] selectFile:[theAlias path] inFileViewerRootedAtPath:@""];
	}
	else
	{
		printf("Alias file creation failed.\n");
	}
}

static void testReadingAliasFile( NSString * aAliasPath )
{
	NDAlias		* theNewAlias = [NDAlias aliasWithContentsOfFile:aAliasPath];
	
	if( theNewAlias )
	{
		printf("Here is the original for %s.\n", [aAliasPath fileSystemRepresentation]);
		[[NSWorkspace sharedWorkspace] selectFile:[theNewAlias path] inFileViewerRootedAtPath:@""];
	}
	else
	{
		printf("Alias file reading has failed.\n");
	}
}
