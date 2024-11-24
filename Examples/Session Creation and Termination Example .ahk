#include ..\Rufaydium.ahk

Chrome := Rufaydium() ; run's webdriver
Page := Chrome.NewSession() ; creates sessions
Page.url := "https://www.autohotkey.com/boards/viewtopic.php?f=83&t=112753" ; navigates to url
msgbox "click ok to close","Rufaydium Test", "owner" WinGetID("ahk_pid " Page.pid) ; msgbox example
Page.Close() ; close session
Chrome.Exit() ; exits webdriver
