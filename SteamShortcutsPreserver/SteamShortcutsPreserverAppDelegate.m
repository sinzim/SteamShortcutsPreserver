//
//  SteamShortcutsPreserverAppDelegate.m
//  SteamShortcutsPreserver
//
//  Created by Harald Hauknes on 6/3/11.
//  Copyright 2011. All rights reserved.
//
#import "SteamShortcutsPreserverAppDelegate.h"
#import "LaunchAtLoginController.h"

@implementation SteamShortcutsPreserverAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // I expect this is the equilent of a main method
    
    // Declare default values
    NSMutableString *steam_path, *backup_path, *output;
    output = @"";
    steam_path =  @"/Applications/Steam.app/Contents/MacOS/config/shortcuts.vdf";
    backup_path = [@"~/Library/Application\ Support/Steam/steam_shortcuts_backup.vdf" stringByExpandingTildeInPath];

    if(![self steamPathIsCorrect:steam_path]){
      
      NSOpenPanel *op = [NSOpenPanel openPanel];
      if ([op runModal] == NSOKButton)
      {
          steam_path = [[op filename] stringByAppendingString:@"/Contents/MacOS/config/shortcuts.vdf"];
      }
                      
    }
    
    // Check if the backup exists
    if ([self backupFileExists:backup_path]){
        output = [output stringByAppendingString:@"Backup file eksists.\n"];
        
        int backupSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:backup_path error:nil] fileSize];
        // Check if Steam exists
        if ([self steamPathIsCorrect: steam_path]){
            output = [output stringByAppendingString:@"Steam folder found.\n"];
            int steamSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:steam_path error:nil] fileSize];
        
            NSString *s = [NSString stringWithFormat:@"This is a %d test", steamSize];
            NSString *b = [NSString stringWithFormat:@"This is a %d test", backupSize];

            [words setStringValue:b];
            // If the backup is larger, replace steams copy
            if(backupSize > steamSize){
                [[NSFileManager defaultManager] removeItemAtPath:steam_path error:nil];
                [[NSFileManager defaultManager] copyPath:backup_path toPath:steam_path handler:nil];
                output = [output stringByAppendingString:@"Backup was larger, replaced steam copy with ours.\nDone."];

            }
            if(backupSize == steamSize) output = [output stringByAppendingString:@"The two files match in size.\nNo action taken.\n"];
            if(backupSize < steamSize){
                [[NSFileManager defaultManager] removeItemAtPath:backup_path error:nil];
                [[NSFileManager defaultManager] copyPath:steam_path toPath:backup_path handler:nil];
                output = [output stringByAppendingString:@"The Steam copy was larger, replaced backup.\n"];
                
            }

            
        }
        else{
            // Couldnt find steam
            output = @"Could not find Steam, aborted!\n";
        }

    }
    else if ([self backupFileExists:steam_path]){
        // Create backup file
        output = [output stringByAppendingString:@"Backup was not found.\nCreated backup file.\n"];
        [[NSFileManager defaultManager] copyPath:steam_path toPath:backup_path handler:nil];
    
    } else output = [output stringByAppendingString:@"Steam location not found.\nAborting!\n"]; 
    [words setStringValue:[output stringByAppendingString:@"Done."]];
    
}// end main
- (BOOL)fixShortcuts:(id)sender{
   // [words setStringValue:[sender description]];
    /*NSMutableString *bundlePath;
    bundlePath = [[NSBundle mainBundle] resourcePath];
    if ([LaunchAtLoginController  willLaunchAtLogin:[NSURL fileURLWithPath:bundlePath]]){
        [words setStringValue:@"True"];
        [words setNeedsDisplay:YES];
    

    }else{
    [words setStringValue:@"False retuned"];
    [words setNeedsDisplay:YES];
    }
    */
    LaunchAtLoginController *launchController = [[LaunchAtLoginController alloc] init];
    BOOL *currentState = [launchController launchAtLogin];
    
    [launchController setLaunchAtLogin:!currentState];
    [launchController release];
            
    
}
- (BOOL)backupIsSmallerThenCurrent:(int *)backup_size:(int *) current_size{
    return backup_size < current_size;
    
}
- (BOOL)steamPathIsCorrect:(NSMutableString *)steam_path{
    return (BOOL)[[NSFileManager defaultManager] fileExistsAtPath:steam_path];
}
- (BOOL)backupFileExists:(NSMutableString *)backup_path{
    return (BOOL)[[NSFileManager defaultManager] fileExistsAtPath:backup_path];
}

@end
