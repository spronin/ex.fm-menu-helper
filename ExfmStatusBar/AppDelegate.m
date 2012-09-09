//
//  AppDelegate.m
//  ExfmTry
//
//  Created by Sergey Pronin on 6/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Carbon/Carbon.h>
#import "AudioStreamer.h"
#import "BPUtils.h"
#import "SimpleImageFetcher.h"
#import <AudioToolbox/AudioToolbox.h>

static NSString *kExfmUsername = @"exfm_username";
static NSString *kExfmLastChoice = @"exfm_lastchoice";
static NSString *kExfmPassword = @"exfm_password";
static NSString *kExfmShuffle = @"exfm_shuffle";
static NSString *kExfmNotification = @"ExfmNotificaion";

static const int kExfmTrendingOverall = 40;
static const int kExfmTrendingBlues = 1;
static const int kExfmTrendingChillwave = 2;
static const int kExfmTrendingClassical = 3;
static const int kExfmTrendingCountry = 4;
static const int kExfmTrendingDubstep = 5;
static const int kExfmTrendingElectronica = 6;
static const int kExfmTrendingExperimental = 7;
static const int kExfmTrendingFolk = 8;
static const int kExfmTrendingHiphop = 9;
static const int kExfmTrendingHouse = 10;
static const int kExfmTrendingIndie = 11;
static const int kExfmTrendingJazz = 12;
static const int kExfmTrendingMashup = 13;
static const int kExfmTrendingMetal = 14;
static const int kExfmTrendingPop = 15;
static const int kExfmTrendingPunk = 16;
static const int kExfmTrendingReggae = 17;
static const int kExfmTrendingRock = 18;
static const int kExfmTrendingShoegaze = 19;
static const int kExfmTrendingSoul = 20;
static const int kExfmTrendingSynthpop = 21;
static const int kExfmFavourites = 30;

@implementation AppDelegate

@synthesize window = _window, menu, currentSong=currentSong_, songs=songs_;

- (void)dealloc
{
    [playingSongs release];
    self.currentSong = nil;
    self.songs = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"stream_error" object:nil];
    [self destroyStreamer];
    [super dealloc];
}

+ (void)initialize {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"];
	NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:file];
	[defaults registerDefaults:appDefaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    
    [NSBundle loadNibNamed:@"StatusMenu" owner:self];
    
    [GrowlApplicationBridge setGrowlDelegate:self];
    
    playingSongs = [[NSMutableArray alloc] init];
    
    miTrendingBlues.tag = kExfmTrendingBlues;
    miTrendingChillwave.tag = kExfmTrendingChillwave;
    miTrendingClassical.tag = kExfmTrendingClassical;
    miTrendingCountry.tag = kExfmTrendingCountry;
    miTrendingDubstep.tag = kExfmTrendingDubstep;
    miTrendingElectronica.tag = kExfmTrendingElectronica;
    miTrendingExperimental.tag = kExfmTrendingExperimental;
    miTrendingFolk.tag = kExfmTrendingFolk;
    miTrendingHiphop.tag = kExfmTrendingHiphop;
    miTrendingHouse.tag = kExfmTrendingHouse;
    miTrendingIndie.tag = kExfmTrendingIndie;
    miTrendingJazz.tag = kExfmTrendingJazz;
    miTrendingMashup.tag = kExfmTrendingMashup;
    miTrendingMetal.tag = kExfmTrendingMetal;
    miTrendingOverall.tag = kExfmTrendingOverall;
    miTrendingPop.tag = kExfmTrendingPop;
    miTrendingPunk.tag = kExfmTrendingPunk;
    miTrendingReggae.tag = kExfmTrendingReggae;
    miTrendingRock.tag = kExfmTrendingRock;
    miTrendingShoegaze.tag = kExfmTrendingShoegaze;
    miTrendingSoul.tag = kExfmTrendingSoul;
    miTrendingSynthpop.tag = kExfmTrendingSynthpop;
    miFavourites.tag = kExfmFavourites;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamError:) name:@"stream_error" object:nil];
    
    [self.window setExcludedFromWindowsMenu:YES];
    [self.window setIsVisible:NO];
    
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    NSStatusItem *item = [statusBar statusItemWithLength:NSVariableStatusItemLength];
    [item retain];
    [item setImage:[NSImage imageNamed:@"ex32_3.png"]];
    [item setHighlightMode:YES];
    [item setMenu:menu];
    
    [self setupEvents];
    [self loadMenuStates:NO];
    
}

-(void)streamError:(NSNotification *)notifcation {
    miNowPlaying.title = @"!! Connection error !!";
}

OSStatus MyHotKeyHandler(EventHandlerCallRef nextHandler,EventRef theEvent,
                         void *userData)
{
    //Do something once the key is pressed
    NSLog(@"play");
    return noErr;
}

- (void) setupEvents {
	// Create an event tap. We are interested in system defined keys.
	eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, CGEventMaskBit(NX_SYSDEFINED), myCGEventCallback, self);
	// Create a run loop source
	CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
	//Add to the current run loop.
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
}

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
	AppDelegate *appDelegate = (AppDelegate *)refcon;
	return [appDelegate processEvent:event withType:type];
}

- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type {
	//Paranoid sanity check.
	if (type == kCGEventTapDisabledByTimeout) {
		CGEventTapEnable(eventTap, YES);
		return event;
	} else if (type != NX_SYSDEFINED) {
		return event;
	}
	
	NSEvent *e = [NSEvent eventWithCGEvent:event];
	//We're getting a special event
	if ([e type] == NSSystemDefined && [e subtype] == 8) {
		if ([e data1] == 1051136) {
			NSLog(@"play\n");
            double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self clickPlay:nil];
            });
			return NULL;
		} else if ([e data1] == 1313280) {
			double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self clickPrevious:nil];
            });
			return NULL;
		} else if ([e data1] == 1247744) {
			double delayInSeconds = 0.3f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self clickNext:nil];
            });
			return NULL;
		}
	}
	
	return event;
}

-(void)loadMenuStates:(BOOL)withAction {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    if ([defs objectForKey:kExfmUsername]) {
        miFavourites.action = @selector(clickFavourites:);
        miLove.action = @selector(clickLove:);
        miSignedin.action = @selector(clickProfile:);
        miSignedin.title = [defs objectForKey:kExfmUsername];
        miSignin.title = @"Sign out";
    } else {
        miFavourites.action = NULL;
        miLove.action = NULL;
        miSignedin.action = NULL;
        miSignedin.title = @"Not signed in";
        miSignin.title = @"Sign in"; 
    }
    
    miLove.title = @"Love";
    
    if (self.currentSong) {
        miNowPlaying.title = [self.currentSong name];
        if (self.currentSong.loved) miLove.title = @"Unlove";
        miNext.action = @selector(clickNext:);
        miPrevious.action = @selector(clickPrevious:);
    } else {
        miNowPlaying.title = @"None";
        miNext.action = NULL;
        miPrevious.action = NULL;
        miLove.action = NULL;
    }
    
    NSNumber *shuffling = [defs objectForKey:kExfmShuffle];
    if (!shuffling) {
        shuffling = [NSNumber numberWithBool:NO];
        [defs setObject:shuffling forKey:kExfmShuffle];
    }
    shuffle = [shuffling boolValue];
    
    if (playing) {
        miPlay.title = @"Stop";
    } else {
        miPlay.title = @"Play";
    }
    
    NSNumber *choice = [defs objectForKey:kExfmLastChoice];
    if (!choice) {
        choice = [NSNumber numberWithInt:kExfmTrendingOverall];
        [defs setObject:choice forKey:kExfmLastChoice];
    }
    
    miTrendingSynthpop.state = miTrendingSoul.state = miTrendingShoegaze.state = miTrendingRock.state = miTrendingReggae.state = miTrendingPunk.state = miTrendingPop.state = miTrendingOverall.state = miTrendingMetal.state = miTrendingMashup.state = miTrendingJazz.state = miTrendingIndie.state = miTrendingHouse.state = miTrendingHiphop.state = miTrendingFolk.state = miTrendingExperimental.state = miTrendingElectronica.state = miTrendingDubstep.state = miTrendingCountry.state = miTrendingClassical.state = miTrendingChillwave.state = miTrendingBlues.state = miFavourites.state = 0;
    
    NSString *tag = nil;
    
    
    switch ([choice intValue]) {
        case kExfmTrendingBlues:
            miTrendingBlues.state = 2;
            tag = @"blues";
            break;    
        case kExfmTrendingChillwave:
            miTrendingChillwave.state = 2;
            tag = @"chillwave";
            break;
        case kExfmTrendingClassical:
            miTrendingClassical.state = 2;
            tag = @"classical";
            break;
        case kExfmTrendingCountry:
            miTrendingCountry.state = 2;
            tag = @"country";
            break;
        case kExfmTrendingDubstep:
            miTrendingDubstep.state = 2;
            tag = @"dubstep";
            break;
        case kExfmTrendingElectronica:
            miTrendingElectronica.state = 2;
            tag = @"electronica";
            break;
        case kExfmTrendingExperimental:
            miTrendingExperimental.state = 2;
            tag = @"experimental";
            break;
        case kExfmFavourites:
            miFavourites.state = 2;
            tag = @"fave";
            break;
        case kExfmTrendingFolk:
            miTrendingFolk.state = 2;
            tag = @"folk";
            break;
        case kExfmTrendingHiphop:
            miTrendingHiphop.state = 2;
            tag = @"hiphop";
            break;
        case kExfmTrendingHouse:
            miTrendingHouse.state = 2;
            tag = @"house";
            break;
        case kExfmTrendingIndie:
            miTrendingIndie.state = 2;
            tag = @"indie";
            break;
        case kExfmTrendingJazz:
            miTrendingJazz.state = 2;
            tag = @"jazz";
            break;
        case kExfmTrendingMashup:
            miTrendingMashup.state = 2;
            tag = @"mashup";
            break;
        case kExfmTrendingMetal:
            miTrendingMetal.state = 2;
            tag = @"metal";
            break;
        case kExfmTrendingOverall:
            miTrendingOverall.state = 2;
            tag = @"all";
            break;
        case kExfmTrendingPop:
            miTrendingPop.state = 2;
            tag = @"pop";
            break;
        case kExfmTrendingPunk:
            miTrendingPunk.state = 2;
            tag = @"punk";
            break;
        case kExfmTrendingReggae:
            miTrendingReggae.state = 2;
            tag = @"reggae";
            break;
        case kExfmTrendingRock:
            miTrendingRock.state = 2;
            tag = @"rock";
            break;
        case kExfmTrendingShoegaze:
            miTrendingShoegaze.state = 2;
            tag = @"shoegaze";
            break;
        case kExfmTrendingSoul:
            miTrendingSoul.state = 2;
            tag = @"soul";
            break;
        case kExfmTrendingSynthpop:
            miTrendingSynthpop.state = 2;
            tag = @"synthpop";
            break;
    }
    
    if (withAction) {
        NSString *url = nil;
        
        if ([tag isEqualToString:@"fave"]) {
            url = [NSString stringWithFormat:@"user/%@/loved", [defs objectForKey:kExfmUsername]];
        } else if ([tag isEqualToString:@"all"]) {
            url = @"trending";
        } else {
            url = [NSString stringWithFormat:@"trending/tag/%@", tag];
        }
        
        NSString *params = nil;
        if ([defs objectForKey:kExfmUsername]) {
            params = [NSString stringWithFormat:@"username=%@&password=%@&results=100", [defs objectForKey:kExfmUsername], [defs objectForKey:kExfmPassword]];
        } else {
            params = @"results=100";
        }
        
        [BPUtils GETWithParams:params toURL:url withCallback:^(BOOL success, NSDictionary *result, int code) {
            if (success) {
                NSMutableArray *array = [NSMutableArray array];
                NSArray *arraySongs = [result objectForKey:@"songs"];
                for (NSDictionary *dictSong in arraySongs) {
                    Song *song = [Song song];
                    song.artist = [dictSong objectForKey:@"artist"];
                    song.url = [dictSong objectForKey:@"url"];
                    song.title = [dictSong objectForKey:@"title"];
                    id loved = [dictSong objectForKey:@"viewer_love"];
                    if (![loved isKindOfClass:[NSNull class]]) song.loved = YES;
                    else song.loved = NO;
                    song.songID = [dictSong objectForKey:@"id"];
                    song.imageURLSmall = [[dictSong objectForKey:@"image"] objectForKey:@"small"];
                    song.imageURLBig = [[dictSong objectForKey:@"image"] objectForKey:@"large"];
                    [array addObject:song];
                }
             if ([array count] > 0) {
                 self.currentSong = [array objectAtIndex:0];
                 self.songs = array;
                 
                 [playingSongs removeAllObjects];
                 [playingSongs addObjectsFromArray:self.songs];
                 if (shuffle) {
                     [playingSongs shuffle];
                     int k = [playingSongs indexOfObject:self.currentSong];
                     [playingSongs exchangeObjectAtIndex:0 withObjectAtIndex:k];
                 }
                 
                 [self stop];
                 [self play];
                 
                 [self loadMenuStates:NO];
             }
            }
        }];
    }
    
    
    [defs synchronize];
}

- (IBAction)clickSignIn:(id)sender {
    
    //TODO show spinner or smth
    
    
    [BPUtils GETWithParams:[NSString stringWithFormat:@"username=%@&password=%@", textFieldLogin.stringValue, textFieldPassword.stringValue] 
                     toURL:@"me" 
              withCallback:^(BOOL success, NSDictionary *result, int code) {
                  if (success) {
                      
                      NSDictionary *user = [result objectForKey:@"user"];
                      NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                      [defs setObject:[user objectForKey:@"username"] forKey:kExfmUsername];
                      [defs setObject:textFieldPassword.stringValue forKey:kExfmPassword];
                      [defs synchronize];
                      
                      [self loadMenuStates:NO];
                      
                      //TODO show success
                      
                      [self.window setIsVisible:NO];
                  } else {
                      //TODO show error
                  }
    }];
    
    
}

- (IBAction)clickFavourites:(id)sender {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSNumber *choice = [defs objectForKey:kExfmLastChoice];
    if ([choice intValue] == [sender tag]) return;
    [defs setObject:[NSNumber numberWithInt:[sender tag]] forKey:kExfmLastChoice];
    [defs synchronize];
    
    [self loadMenuStates:YES];
}

- (IBAction)clickTrending:(id)sender {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSNumber *choice = [defs objectForKey:kExfmLastChoice];
    if ([choice intValue] == [sender tag]) return;
    [defs setObject:[NSNumber numberWithInt:[sender tag]] forKey:kExfmLastChoice];
    [defs synchronize];
    
    [self loadMenuStates:YES];
}

-(IBAction)clickPlay:(id)sender {
    if (playing) {
        [self pause];
    } else {
        if (self.currentSong) {
            [self play];
        } else {
            [self loadMenuStates:YES];
        }
    }
}

-(void)play {
    playing = YES;
    paused = NO;
    [self createStreamer];
    [streamer start];
    
    
}

-(void)pause {
    playing = NO;
    paused = YES;
    [streamer pause];
}

-(void)stop {
    playing = NO;
    paused = NO;
    [self destroyStreamer];
}

-(void)next {
    
    int k = [playingSongs indexOfObject:currentSong_];
    if (k+1 < [playingSongs count]) {
        self.currentSong = [playingSongs objectAtIndex:k+1];
        
        if (playing || paused) {
            [self stop];
            [self play];
        }
        
        
        [self loadMenuStates:NO];
    }
}

-(void)previous {
    int k = [playingSongs indexOfObject:currentSong_];
    if (k > 0) {
        self.currentSong = [playingSongs objectAtIndex:k-1];
        
        if (playing || paused) {
            [self stop];
            [self play];
        }
        
        [self loadMenuStates:NO];
    }
}

- (void)destroyStreamer
{
	if (streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
		
		[streamer stop];
		[streamer release];
		streamer = nil;
	}
}

- (void)createStreamer
{
	if (streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	
	NSString *escapedValue =
    [(NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                         nil,
                                                         (CFStringRef)currentSong_.url,
                                                         NULL,
                                                         NULL,
                                                         kCFStringEncodingUTF8)
     autorelease];
    
	NSURL *url = [NSURL URLWithString:escapedValue];
	streamer = [[AudioStreamer alloc] initWithURL:url];
	
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:streamer];
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([streamer isWaiting])
	{
		NSLog(@"waiting");
	}
	else if ([streamer isPlaying])
	{
		NSLog(@"playing");
        
        if (self.currentSong) {
            
            SimpleImageFetcher *fetcher = [[SimpleImageFetcher alloc] init];
            [fetcher fetchImageWithURL:[NSURL URLWithString:self.currentSong.imageURLSmall] callback:^(NSImage *image) {
                
                [GrowlApplicationBridge
                 notifyWithTitle:self.currentSong.title
                 description:self.currentSong.artist
                 notificationName:kExfmNotification
                 iconData:[image TIFFRepresentation]
                 priority:0
                 isSticky:NO
                 clickContext:nil];
            
                [fetcher autorelease];
            }];
            
            
        }
        
	}
	else if ([streamer isIdle])
	{
		NSLog(@"idle");
        [self next];
	}
}

- (IBAction)clickProfile:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ex.fm/%@", [[NSUserDefaults standardUserDefaults] objectForKey:kExfmUsername]]]];
}

- (IBAction)clickSigninMenu:(id)sender {
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kExfmUsername]) {
        
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        [defs removeObjectForKey:kExfmPassword];
        [defs removeObjectForKey:kExfmUsername];
        
        
        NSNumber *choice = [defs objectForKey:kExfmLastChoice];
        if ([choice intValue] == kExfmFavourites) {
            choice = [NSNumber numberWithInt:kExfmTrendingOverall];
            [defs setObject:choice forKey:kExfmLastChoice];    
        }
        
        [defs synchronize];
        
        [self loadMenuStates:NO];
        return;
    }
    
    textFieldLogin.stringValue = @"";
    textFieldPassword.stringValue = @"";
    
    [self.window setIsVisible:YES];
    [self.window orderFrontRegardless];
}

- (IBAction)clickLove:(id)sender {
    
    if (!self.currentSong) return;
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSString *username = [defs objectForKey:kExfmUsername];
    NSString *password = [defs objectForKey:kExfmPassword];
    
    if (!username || !password) return;
    
    NSString *love = @"love";
    if (currentSong_.loved) {
        love = @"unlove";
    }
    
    [BPUtils POSTWithParams:[NSString stringWithFormat:@"username=%@&password=%@", username, password] 
                      toURL:[NSString stringWithFormat:@"song/%@/%@", self.currentSong.songID, love] 
               withCallback:^(BOOL success, NSDictionary *result, int code){
                   self.currentSong.loved = !self.currentSong.loved;
                   [self loadMenuStates:NO];
               }];
}


- (IBAction)clickNext:(id)sender {
    if (self.currentSong) {
        [self next];
    }
}

- (IBAction)clickPrevious:(id)sender {
    if (self.currentSong) {
        [self previous];
    }
}

- (IBAction)clickShuffle:(id)sender {
    shuffle = !shuffle;
    miShuffle.state = shuffle;
    
    if ([playingSongs count] == 0) return;
    
    if (shuffle) {
        [playingSongs shuffle];
        if (self.currentSong) {
            int k = [playingSongs indexOfObject:self.currentSong];
            [playingSongs exchangeObjectAtIndex:k withObjectAtIndex:0];
        }
    } else {
        [playingSongs removeAllObjects];
        [playingSongs addObjectsFromArray:self.songs];
    }
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSNumber *shuffling = [defs objectForKey:kExfmShuffle];
    shuffling = [NSNumber numberWithBool:shuffle];
    [defs setObject:shuffling forKey:kExfmShuffle];
    [defs synchronize];
}

#pragma mark - Growl

- (NSDictionary *) registrationDictionaryForGrowl {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSArray arrayWithObject:kExfmNotification] forKey:GROWL_NOTIFICATIONS_ALL];
    [dict setObject:[NSArray arrayWithObject:kExfmNotification] forKey:GROWL_NOTIFICATIONS_DEFAULT];
    return dict;
}

- (NSString *) applicationNameForGrowl {
    return @"Exfm Menu";
}



@end
