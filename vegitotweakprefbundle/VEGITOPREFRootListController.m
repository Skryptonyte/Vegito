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

- (void) doFilePick
{
	UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
	imagePicker.delegate = self;
	imagePicker.allowsEditing = NO;
	imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info;
{
	NSURL* url = info[UIImagePickerControllerMediaURL];
	NSLog(@"%@",url.absoluteString);

	NSURL* newurl = [NSURL fileURLWithPath: [NSString stringWithFormat:@"/var/mobile/%@", url.lastPathComponent]];

	[[NSFileManager defaultManager] copyItemAtURL:url toURL:newurl error: nil];

	[[NSUserDefaults standardUserDefaults] setURL:newurl forKey: @"url"];
	[picker dismissViewControllerAnimated:YES completion: NULL];
}
@end
