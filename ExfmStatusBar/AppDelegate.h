//
//  AppDelegate.h
//  ExfmStatusBar
//
//  Created by Sergey Pronin on 6/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOKit/hidsystem/ev_keymap.h>
#import "Song.h"
#import <Growl/Growl.h>
#import "NSMutableArray+Shuffling.h"

@class AudioStreamer;

@interface AppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
    CFMachPortRef eventTap;
    AudioStreamer *streamer;
    
    IBOutlet NSTextField *textFieldLogin;
    IBOutlet NSSecureTextField *textFieldPassword;
    
    NSMenu *menu;
    IBOutlet NSMenu *menuTrending;
    
    IBOutlet NSMenuItem *miNowPlaying;
    IBOutlet NSMenuItem *miFavourites;
    IBOutlet NSMenuItem *miTrendingOverall;
    IBOutlet NSMenuItem *miTrendingBlues;
    IBOutlet NSMenuItem *miTrendingChillwave;
    IBOutlet NSMenuItem *miTrendingClassical;
    IBOutlet NSMenuItem *miTrendingCountry;
    IBOutlet NSMenuItem *miTrendingDubstep;
    IBOutlet NSMenuItem *miTrendingElectronica;
    IBOutlet NSMenuItem *miTrendingExperimental;
    IBOutlet NSMenuItem *miTrendingFolk;
    IBOutlet NSMenuItem *miTrendingHiphop;
    IBOutlet NSMenuItem *miTrendingHouse;
    IBOutlet NSMenuItem *miTrendingIndie;
    IBOutlet NSMenuItem *miTrendingJazz;
    IBOutlet NSMenuItem *miTrendingMashup;
    IBOutlet NSMenuItem *miTrendingMetal;
    IBOutlet NSMenuItem *miTrendingPop;
    IBOutlet NSMenuItem *miTrendingPunk;
    IBOutlet NSMenuItem *miTrendingReggae;
    IBOutlet NSMenuItem *miTrendingRock;
    IBOutlet NSMenuItem *miTrendingShoegaze;
    IBOutlet NSMenuItem *miTrendingSoul;
    IBOutlet NSMenuItem *miTrendingSynthpop;
    IBOutlet NSMenuItem *miPlay;
    IBOutlet NSMenuItem *miNext;
    IBOutlet NSMenuItem *miPrevious;
    IBOutlet NSMenuItem *miLove;
    IBOutlet NSMenuItem *miSignedin;
    IBOutlet NSMenuItem *miSignin;
    IBOutlet NSMenuItem *miShuffle;
    
    Song *currentSong_;
    NSArray *songs_;
    NSMutableArray *playingSongs;
    BOOL playing;
    BOOL paused;
    BOOL shuffle;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSMenu *menu;
@property (nonatomic, retain) Song *currentSong;
@property (nonatomic, retain) NSArray *songs;

- (void)loadMenuStates:(BOOL)withAction;
- (CGEventRef) processEvent:(CGEventRef)event withType:(CGEventType)type;
- (IBAction)clickSignIn:(id)sender;

- (IBAction)clickFavourites:(id)sender;
- (IBAction)clickTrending:(id)sender;
- (IBAction)clickProfile:(id)sender;
- (IBAction)clickSigninMenu:(id)sender;
- (IBAction)clickLove:(id)sender;
- (IBAction)clickPlay:(id)sender;
- (IBAction)clickNext:(id)sender;
- (IBAction)clickPrevious:(id)sender;

- (IBAction)clickShuffle:(id)sender;


@end
