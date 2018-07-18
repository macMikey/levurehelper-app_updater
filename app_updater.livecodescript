script "AppUpdater"
local sUpdateIsAvailable = "false"
local sPerformingUpdate = "false"
local sInitialized = "false"
local sReadyToUse = "false"


/**
Summary: Call before setting any updater properties.

Description:
This handler will perform any initialization required for the updater library being used
and will assign any default properties configured in `app.yml`. After calling this handler
you can safely set properties before calling `appupdaterRun`.

Returns: empty
*/
command appupdaterInitialize
  if _killUpdater() then return empty

  if the platform is "macos" then
    get sparkleInitialize()
    get sparkleSetFeedUrl( levureAppGet("appcast url") )
  else if the platform is "win32" then
    get winSparkleSetFeedUrl( levureAppGet("appcast url") )
  end if

  put true into sInitialized

  return empty
end appupdaterInitialize


/**
Summary: Call at the end of `OpenApplication` after you have displayed your application UI.

Description:
This handler will start any automated checks for updates using the current configuration.

Returns: empty
*/
command appupdaterRun
  if _killUpdater() then return empty

  if the platform is "macos" then
    get sparkleResetUpdateCycle()
  else if the platform is "win32" then
    get winSparkleInitialize()
  end if

  put true into sReadyToUse

  return empty
end appupdaterRun


/**
Summary: Cleans up after the updater being used.

Description:
Call in `PreShutdownApplication`.

Returns: empty
*/
command appupdaterCleanup
  if _killUpdater() then return empty

  if the platform is "win32" then
    get winSparkleCleanup()
  end if

  return empty
end appupdaterCleanup


/**
Summary: Checks for updates with UI feedback. Use in a Check for Updates... menu item.

Returns: empty
*/
command appupdaterCheckForUpdates
  if _killUpdater() then return empty

  if not sInitialized then appupdaterInitialize
  if not sReadyToUse then appupdaterRun

  if the platform is "macos" then
    get sparkleCheckForUpdates()
  else if the platform is "win32" then
    get winSparkleCheckForUpdates()
  end if

  return empty
end appupdaterCheckForUpdates


/**
Summary: Return whether or not an update is being applied.

Description:
Call this function if your code needs to know if a shutdown was
triggered by the app updater.

Returns: Boolean
*/
function appupdaterPerformingUpdate
  return sPerformingUpdate
end appupdaterPerformingUpdate


/**
Summary: Return whether or not an update is available.

Returns: Boolean
*/
function appupdaterIsUpdateAvailable
  return sUpdateIsAvailable
end appupdaterIsUpdateAvailable


/**
Summary: The updater should not run in dev environment or test mode.

Returns: Boolean
*/
private function _killUpdater
  return the environment is "development" OR levureBuildProfile() is "test"
end _killUpdater


/* CALLBACKS */

/**
Summary: Sent when an update is found. Flag that update is available.
*/
on sparkleFoundUpdate
  put true into sUpdateIsAvailable

  pass sparkleFoundUpdate
end sparkleFoundUpdate


/**
Summary: Sent when an update is found. Flag that update is available.
*/
on sparkleFoundUpdate
  put true into sUpdateIsAvailable

  pass sparkleFoundUpdate
end sparkleFoundUpdate


/**
Summary: Sent when an update is not found. Flag that update is not available.
*/
on sparkleDidNotFindUpdate
  put false into sUpdateIsAvailable

  pass sparkleDidNotFindUpdate
end sparkleDidNotFindUpdate


on sparkleDownloadCanceledByUser

  pass sparkleDownloadCanceledByUser
end sparkleDownloadCanceledByUser


/**
Summary: Callback sent if an error occurs.

Description:
winSparkle doesn't send an error parameter.
*/
on sparkleDidAbortWithError pError
  if pError["description"] is not empty then
    if the last char of pError["description"] is not "." then put "." after pError["description"]
    answer error pError["description"] & cr & cr & "(" & pError["failure reason"] & ")"
  end if
  pass sparkleDidAbortWithError
end sparkleDidAbortWithError


/**
Summary: Callback sent from WinSparkle when the application should quit.
*/
on sparkleShutdownApplication
  quit
end sparkleShutdownApplication


/**
Summary: Callback sent from WinSparkle asking whether or not the relaunch should be postponed.

Description:
This handler is called after the user clicks on the Install Update button in the dialog
that alerts them about an update.

Currently LCB doesn't support returning TRUE/FALSE to WinSparkle because the message is sent on
a different thread. Therefore there is nothing that can be done in this handler.
*/
on sparkleShouldPostponeRelaunchForUpdate
  put true into sPerformingUpdate

  pass sparkleShouldPostponeRelaunchForUpdate
end sparkleShouldPostponeRelaunchForUpdate


/**
Summary: Sent before the app is relaunched. Use this opportunity to save any session data then call sparkleRelaunch to trigger the relaunch.
*/
on sparklePreRelaunchForUpdate
  put true into sPerformingUpdate

  dispatch "PreUpdateApplication" to stack levureAppStackName()
  if it is "handled" and the result is not false then
    levureShutdownApplication
  end if

  # Continue with relaunch and install after this handler has finished.
  send "__relaunchSparkle" to me in 0 seconds
end sparklePreRelaunchForUpdate


command __relaunchSparkle
  if the platform is "macos" then
    get sparkleRelaunch()
  end if
end __relaunchSparkle
