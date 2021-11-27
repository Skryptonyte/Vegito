#import <Foundation/Foundation.h>
#import "VEGITOPREFRootListController.h"
#include <spawn.h>
@implementation VEGITOPREFRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void) doRespring
{
	pid_t pid;

	int status;

	const char* args[] = {"sbreload", NULL, NULL, NULL};

	posix_spawn(&pid, "/usr/bin/sbreload", NULL, NULL, (char* const*)args, NULL);

	waitpid(pid, &status, WEXITED);
}

@end
