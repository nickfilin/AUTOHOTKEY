#Requires AutoHotkey v2
#SingleInstance Force
; запуск Rufaydium
#include Rufaydium.ahk
Chrome := Rufaydium() ; run's webdriver
Chrome.capabilities.setUserProfile("MAINPROFILE","J:/V2/WORKPROFILE/")
Page := Chrome.NewSession() ; creates sessions
Page.Navigate("https://lk.eisrf.ru/adm/sites/cp/352830/news/new/edit")