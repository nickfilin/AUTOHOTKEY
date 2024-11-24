#Requires AutoHotkey v2
#SingleInstance Force
; запуск Rufaydium
#include Rufaydium.ahk
Chrome := Rufaydium() ; run's webdriver
Chrome.capabilities.setUserProfile("MAINPROFILE","J:/AUTOHOTKEY/PROFILE/")
Page := Chrome.NewSession() ; creates sessions
; Пытаемся запустить Браузер с URL из Клипборда
Page.Navigate(A_Clipboard)