# NgKeyboardTracker

Objective-c library for tracking keyboard in iOS apps.

## Adding to your project

If you are using Cocoapods, add to your Podfile:

```ruby
pod NgKeyboardTracker
```

To manually add to your projects:

1. Add files in `NgKeyboardTracker` folder to your project.
2. Add these frameworks to your project: `UIKit`.

## Features

`NgKeyboardTracker` encapsulates keyboard tracking for iOS apps.
It provides convenience to query keyboard's properties anywhere in your application.

You can also use `NgKeyboardTracker` to implement iMessage's text input behavior on iOS 7 (`UIScrollViewKeyboardDismissModeInteractive` + persistent `inputAccessoryView`) using `NgPseudoInputAccessoryViewCoordinator`.

## Usage

### Start and stop keyboard tracking

In your application delegate:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[NgKeyboardTracker sharedTracker] start]; // start tracking
  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  [[NgKeyboardTracker sharedTracker] stop]; // stop tracking
}
```

### Responding to keyboard updates

1. Implement `NgKeyboardTrackerDelegate` protocol.
2. Register as delegate by calling `-addDelegate:` method
3. Make sure to call `-removeDelegate:` to stop receiving keyboard updates

Keyboard tracker's properties:

- `appearanceState` : current appearance state
- `beginFrame` : last known begin frame
- `endFrame`: last known frame
- `animationDuration`: last known animation duration
- `animationCurve`: last known animation curve
- `animationOptions` : derived from `animationCurve` for convenience

### Pseudo input accessory view coordinator

`NgPseudoInputAccessoryViewCoordinator` is `NgKeyboardTracker` extension that makes it easier to implement iMessage's text input behavior in iOS 7 with `UIScrollViewKeyboardDismissModeInteractive` and persistent `inputAccessoryView`.

1. Set `UIScrollView`'s keyboard dismiss mode to `UIScrollViewKeyboardDismissModeInteractive`.
2. Create `NgPseudoInputAccessoryViewCoordinator` by calling `-createPseudoInputAccessoryViewCoordinator`.
3. Track `UITextView` or `UITextField` with coordinator's `-trackInteractiveKeyboardDismissalForTextView:` or `-trackInteractiveKeyboardDismissalForTextField:`.
4. Set desired height of input accessory view with `-setPseudoInputAccessoryViewFrame:` each time it changes.
5. Layout view to emulate 'sticky' input accessory view on ever keyboard updates.
6. Make sure to call coordinator's `-endTracking` at the end

P.S. See demo application for example.
