#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <Foundation/NSUserDefaults+Private.h>

#include <SpringBoard/SpringBoard.h>

#import <AVFoundation/AVFoundation.h>
#import "GcUniversal/GcImagePickerUtils.h"



int __isOSVersionAtLeast(int major, int minor, int patch) { 
	NSOperatingSystemVersion version; version.majorVersion = major; 
	version.minorVersion = minor; version.patchVersion = patch; return 
	[[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:version]; }


@interface SBWallpaperViewController: UIViewController
@end

@interface SBCoverSheetPrimarySlidingViewController: UIViewController
@end

@interface SBFWallpaperView: UIView
@end

@interface _SBFakeBlurView: UIView
@property (nonatomic, assign, readwrite, getter=isHidden) BOOL hidden;
@end

@interface CSCoverSheetViewController: UIViewController
@end

@interface SBWallpaperController: NSObject
@end

@interface SBBacklightController : NSObject
-(void)_notifyObserversDidAnimateToFactor:(float)arg1 source:(long long)arg2 ;
@end


// Power Monitor
 @interface SBWorkspace: NSObject
 @end

 @interface SBMainWorkspace : SBWorkspace
 -(void)powerMonitorSystemWillSleep:(id)arg1 ;
 @end

 
static NSString * nsDomainString = @"com.skrypton.vegito";
static NSString * nsNotificationString = @"com.skrypton.vegito/preferences.changed";

static BOOL enabled;
static int powerLevel = 0;

static AVPlayerLooper* apl = nil;
static AVQueuePlayer* apv = nil;

static BOOL playerCreated = NO;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	NSNumber * enabledValue = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
	NSNumber * powerSave = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"powerSave" inDomain:nsDomainString];
	//videoPathFile = path;
	enabled = (enabledValue)? [enabledValue boolValue] : YES;
	powerLevel = powerSave ? [powerSave intValue]: 0;
}


%hook SBWallpaperViewController

-(void) viewDidLayoutSubviews
{
	%orig;
	NSURL *url = [GcImagePickerUtils videoURLFromDefaults:@"com.skrypton.vegito" withKey:@"video"];

	// Set up AVPlayer objects with looping.
	if (!playerCreated && enabled && url)
	{
		// Create AV objects to set up a looping video
		AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:url];
		AVQueuePlayer* player = [AVQueuePlayer queuePlayerWithItems:@[playerItem]];
		AVPlayerLooper* playerLooper = [AVPlayerLooper playerLooperWithPlayer:player templateItem:playerItem];
		
		player.muted = true;
		player.preventsDisplaySleepDuringVideoPlayback = NO;

		AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
		playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

		// Save to static vars to access the player globally
		apl = playerLooper;
		apv = player;

		playerLayer.frame = self.view.bounds;
		
		// The AVPlayer will kill off background play of other apps otherwise so we fix with this snippet
		[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
		[[AVAudioSession sharedInstance] setActive:YES error:nil];

		[self.view.layer addSublayer:playerLayer];
		[player play];

		playerCreated = YES;
	}

}

%end


%hook SpringBoard
- (void) frontDisplayDidChange:(id)newDisplay      // Pause or resume player depending on whether application is on front or not...
{												   // Admittedly a more aggressive method of conserving power. The resume from paused state will be noticeable to users.
	%orig;

	if (apv)
	{
		if (newDisplay != nil && powerLevel >= 2) 
		{
			[apv pause];
		}
		else{
			[apv play];
		}
	}
}

%end

%hook SBBacklightController
-(void)_notifyObserversDidAnimateToFactor:(float)arg1 source:(long long)arg2   // Pause or play depending on screen backlight state
{
	%orig;
	if (apv)
	{
		if (powerLevel >= 1 && arg1 == 0.0)
			[apv pause];
		else
			[apv play];
	}
}

%end


%hook _SBFakeBlurView

-(void) layoutSubviews{     // Get rid of popup of original wallpaper during transition between lock and home screen
	%orig;					// Bit ugly, will definitely change this later
	if (enabled)
	self.hidden = YES;
}
%end
%ctor {
	// Set variables on start up
	notificationCallback(NULL, NULL, NULL, NULL, NULL);

	// Register for 'PostNotification' notifications
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, notificationCallback, (CFStringRef)nsNotificationString, NULL, CFNotificationSuspensionBehaviorCoalesce);
}


