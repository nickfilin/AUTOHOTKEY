#include ..\Rufaydium.ahk
Chrome := Rufaydium() ; Runs Webdriver
Page := Chrome.NewSession() ; creates sessions
Page.Url := "www.the-automator.com" ; navigates to webpage
Page.CaptureFullSizeScreenShot(A_Desktop "\Rufaydium Snap.png") ; save a fullsize screen shot
msgbox "Took snapshot: " A_Desktop "\Rufaydium Snap.png`nPress ok to Close Session and Termninate Driver" ; msgbox notification
Page.quit() ; close the session
Chrome.Exit() ; exits the webdriver
Exitapp