set BUILD_CONFIG to "Debug"
(*
tell application "Xcode"
    set theProject to project of active project document
    repeat with theTarget in targets of theProject
        set isUnitTest to my isTargetUnitTest(theTarget)
        
        if isUnitTest is yes then
            --set myFiles to getUnitTestFiles(compile sources phase of theTarget)
            --log myFiles
            set active target of theProject to theTarget
            set theTranscript to build with transcript
            log theTranscript
            exit repeat
            my modifyBuildSetting(theTarget)
        end if
    end repeat -- iterate over targets
end tell
*)

tell application "Xcode"
    --  set theTarget to getCurrentTarget()
    set theTarget to my findTargetByName("SZChartUnitTests")
    set theProduct to product reference of theTarget
    set theName to full path of theProduct
    log theName
    repeat with theContent in entire contents of theProduct
        log theContent
    end repeat
end tell

on getCurrentTarget()
    tell application "Xcode"
        return active target of project of active project document
    end tell
end getCurrentTarget

on getUnitTestBundles()
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
end getUnitTestBundles

on getUnitTestBundlePath(theTargetName)
    tell application "Xcode"
        set theTarget to my findTargetByName(theTargetName)
        set theProduct to product reference of theTarget
        return full path of theProduct
    end tell
end getUnitTestBundlePath

on setCurrentTarget(theTargetName)
    tell application "Xcode"
        set theTarget to my findTargetByName(theTargetName)
        set active target of project of active project document to theTarget
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

on getActiveProjectName()
    tell application "Xcode"
        return name of project of active project document
    end tell
end getActiveProjectName

on getUnitTestFiles(theCompilePhase)
    tell application "Xcode"
        set theList to {}
        repeat with theFile in build files of theCompilePhase
            set theList to theList & {name of theFile}
        end repeat
        return theList
    end tell
end getUnitTestFiles

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

on modifyBuildSetting(theTarget)
    global BUILD_CONFIG
    tell application "Xcode"
        repeat with theBuildConf in build configurations of theTarget
            if name of theBuildConf is BUILD_CONFIG then
                repeat with theSetting in build settings of theBuildConf
                    if name of theSetting is "OTHER_TEST_FLAGS" then
                        set value of theSetting to ""
                    end if
                end repeat
            end if
        end repeat
    end tell
end modifyBuildSetting
