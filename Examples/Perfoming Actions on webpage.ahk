#include ..\Rufaydium.ahk 

; Defining Mouse Ineractions
MI := mouse() 
; to move mouse pointer to MI.move(x,y,delay)
MI.move(288,258,10)
; Click down where .press(Mouse.LButton) is default MButton, RButton can also be used
MI.press()
MI.move(288,258,10)
MI.release()
MI.press()
MI.move(391,181,10)
MI.release()
MI.press()
MI.move(493,258,10)
MI.release()
MI.press()
MI.move(454,358,10)
MI.release()
MI.press()
MI.move(328,358,10)
MI.release()
MI.press()
MI.move(288,258,10)
MI.release()
MI.press()
MI.release()

; Initialize Rufayium
Chrome := Rufaydium()
; Creating Session
Page := Chrome.NewSession()

; Navigating to URL
Page.Url := "quickdraw.withgoogle.com"

; Maximize Page for Drawing
Page.Maximize()

msgbox "Click Lets draw Then Click on Lefts Go then Press ok to Draw a Hexagon","Rufaydium: Drawing Example", 4096

; Performing Mouse Ineractions will draw Pantagon
Page.actions(MI)

msgbox "Action has been performed`nPress ok to Close Session and Termninate Driver","Rufaydium: Hexagon Drawing Complete","Owner" WinGetID(Page.title)

; Close all Sessions close for active tab  use Page.Close()
Page.quit()
; Exitting Rufaydium and Ternminating WebDriver
Chrome.Exit()
exitapp

