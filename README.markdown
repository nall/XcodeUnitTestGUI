Introduction
============

This is a Cocoa application to help make running unit tests in Xcode a bit easier. It provides a means of selecting which unit tests will run as well as a visual pass/fail indication. I plan to add some features like "rerun only failing tests", etc. 

Description
===========

XcodeUnitTestGUI utilizes distributed notifications to be updated with the current pass/fail state of unit tests. In order to enable these notifications, you need to link your unit test target with the supplied XcodeUnitTestGUIHelper.framework.

Aside from that, just launch the app and it should query Xcode every so often. If the currently active project has a unit test, those test should get loaded into the app. You can then select what you'd like to run, and hit 'Run'. Sometimes no tests will show up. This is the case when the unit test bundle is not currently built. In this case you should either choose 'Run' from XcodeUnitTestGUI which will initiate a build in Xcode. Alternatively, you can just build the unit test bundle in Xcode before running XcodeUnitTestGUI.

Please log any issues or feature ideas on the github Issues page.

How are unit tests discovered?
==============================

A unit test shows up if the active project has a built target which is a bundle with an extension of octest. If this is found, that bundle is loaded and queried to find classes deriving from SenTestCase with
methods starting with "test". All such methods should show up.


