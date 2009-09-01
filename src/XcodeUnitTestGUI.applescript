--
-- XcodeUnitTestGUI.applescript
--
-- Xcode Unit Test GUI
-- Copyright (c) 2009 Jon Nall, STUNTAZ!!!
-- All rights reserved.
--
-- Permission is hereby granted, free of charge, to any person
-- obtaining a copy of this software and associated documentation
-- files (the "Software"), to deal in the Software without
-- restriction, including without limitation the rights to use,
-- copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following
-- conditions:
-- 
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.

on getCurrentTarget()
	tell application "Xcode"
		return active target of project of active project document
	end tell
end getCurrentTarget

on getUnitTestTargets()
	tell application "Xcode"
		set theList to {}
		set theProject to project of active project document
		repeat with theTarget in targets of theProject
			if (my isTargetUnitTest(theTarget) is 1) then
				set theList to theList & {name of theTarget}
			end if
		end repeat
		
		return theList
	end tell
end getUnitTestTargets

on getUnitTestConfigs(theTargetName)
	tell application "Xcode"
		set theList to {}
		set theTarget to my findTargetByName(theTargetName)
		repeat with theBuildConf in build configurations of theTarget
			set theList to theList & {name of theBuildConf}
		end repeat
		
		return theList
	end tell
end getUnitTestConfigs

on getUnitTestTargetPath(theTargetName)
	tell application "Xcode"
		set theTarget to my findTargetByName(theTargetName)
		set theProduct to product reference of theTarget
		return full path of theProduct
	end tell
end getUnitTestTargetPath

on setCurrentTarget(theTargetName, theConfigName)
	tell application "Xcode"
		set theTarget to my findTargetByName(theTargetName)
		set active target of project of active project document to theTarget
		set theConf to my findBuildConfByName(theConfigName, theTarget)
		set active build configuration type of project of active project document to theConf
	end tell
end setCurrentTarget

on findTargetByName(theName)
	tell application "Xcode"
		set theProject to project of active project document
		repeat with theTarget in targets of theProject
			if (name of theTarget is theName) then
				return theTarget
			end if
		end repeat
		return null
	end tell
end findTargetByName

on findBuildConfByName(theName, theTarget)
	tell application "Xcode"
		repeat with theConf in build configurations of theTarget
			if name of theConf is theName then
				return theConf
			end if
		end repeat
		return null
	end tell
end findBuildConfByName

on getActiveProjectName()
	tell application "Xcode"
		return name of project of active project document
	end tell
end getActiveProjectName

on doBuild()
	tell application "Xcode"
		set theTranscript to build with transcript
		return theTranscript
	end tell
end doBuild

on isTargetUnitTest(theTarget)
	tell application "Xcode"
		set foundOCTest to 0
		if target type of theTarget is "Bundle" then
			repeat with theBuildConf in build configurations of theTarget
				repeat with theSetting in build settings of theBuildConf
					if name of theSetting is "WRAPPER_EXTENSION" and value of theSetting is "octest" then
						set foundOCTest to 1
						exit repeat
					end if
				end repeat -- iterate over build settings
			end repeat -- iterate over build configs
		end if -- execute if this target is a bundle
		
		return foundOCTest
	end tell
end isTargetUnitTest

on modifyBuildSetting(theTargetName, theBuildConfName, theSettingName, theSettingValue)
	tell application "Xcode"
		set theTarget to my findTargetByName(theTargetName)
		set theBuildConf to my findBuildConfByName(theBuildConfName, theTarget)
		if theBuildConf is not null then
			repeat with theSetting in build settings of theBuildConf
				if name of theSetting is theSettingName then
					set value of theSetting to theSettingValue
				end if
			end repeat
		end if
	end tell
end modifyBuildSetting
