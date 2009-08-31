Introduction
============

This is a Cocoa application to help make running unit tests in Xcode a bit easier. It provides a means of selecting which unit tests will run as well as a visual pass/fail indication. I plan to add some features like "rerun only failing tests", etc. 

Description
===========

To enable SenTest distributed notifications, you should add SZSentTestNotifier.m into your unit test target. This provides some communication back and forth to the Cocoa app. 

Aside from that, just launch the app and it should query Xcode every so often. If the currently active project has a unit test, those test should get loaded into the app. You can then select what you'd like to run, and hit 'Run Tests'.

The UI needs a bit more polish, but the guts seem to be working. If you play with this and find bugs, please file them on the github Issues page.

How are unit tests discovered? A unit test shows up if the active project has a target which is a bundle with an extension of octest. If this is found, that bundles is loaded and queried to find classes deriving from SenTestCase with
methods starting with "test". All such methods should show up.


