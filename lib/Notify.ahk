#Requires Autohotkey v2.0-
/**
 * ============================================================================ *
 * Want a clear path for learning AutoHotkey?                                   *
 * Take a look at our AutoHotkey Udemy courses.                                 *
 * They're structured in a way to make learning AHK EASY                        *
 * Right now you can  get a coupon code here: https://the-Automator.com/Learn   *
 * ============================================================================ *
 */

/*
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;;;;;;;;;Notify AHK V2;;By Xeo786;;;;;;;;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	text colors supported: Black,Silver,Gray,White,Maroon,Red,Purple,Fuchsia,Green,Lime,Olive,Yellow,Navy,Blue,Teal,Aqua

	
	'Duration' is how long you want notice to wait and then disappear
	it should be number, if 0 msg will not disappear user have Class
	will then add click event which will callback using notify.close and hide the Gui with transition effect
	and another callback will

	examples
	Notify.Show({BDText:"will close by 3 second", HDText:"The Automator",color:"0xFFD23E",BDFontSize:"10"})

	Notify.Show({BDText:"will close by 3 second",HDText:"The Automator",color:"0xFFD23E",HDFont:"Impact",HDFontColor:"Black",HDFontSize:"14",BDFont:"Consolas",BDFontColor:"0x298939",BDFontSize:"10",})

	Notify.Show({
			HDText:      "The Automator",
			HDFontSize:  "14",
			HDFontColor: "Black",
			HDFont:      "Impact",
			BDText:      "Click to close",
			BDFontSize:  "10",
			BDFontColor: "0x298939",
			BDFont:      "Consolas",
			GenColor:    "0xFFD23E",
			GenDuration: 0
	})


	Notify.Show({
		HDText     : "The Automator",
		HDFontSize : "14",
		HDFont     : "Impact",
		HDFontColor: "Black",
		BDText     : "Click to Callback",
		BDFontSize : "10",
		BDFontColor: "0x298939",
		BDFont     : "Consolas",
		GenDuration: 0
		GenColor    : "0xFFD23E",
		GenCallback:  eventclick,
	})

	eventclick(*)
	{
		msgbox( "it is a call back")
	}

	; user can change default parameters
	Notify.Default := {
		HDText     :"Notice",
		HDFontSize :"28",
		HDFontColor:"Black",
		HDFont     :"Impact",
		BDText     :"",
		BDFontSize :"10",
		BDFontColor:"Yellow",
		BDFont     :"Book Antiqua",
		GenDuration   :5
		GenColor   :"Red",
	}

	Notify.ColorList()  ; List a Supported Color
	sleep 500           ; delay to let botyh sound get played
	Notify.SoundList()  ; List was Supported Sound
	Notify.GenIconList()   ; List for GenIcon
			
	Notify.Show({GenIcon:1}) ; can be used any Shell.dll GenIcon number
	Notify.Show({GenIcon:"Critical"})
	Notify.Show({GenIcon:"Question"})
	Notify.Show({GenIcon:"Exclamation"})
	Notify.Show({GenIcon:"Information"})
	Notify.Show({GenIcon:"Security"})
	Notify.Show({GenIcon:"C:\Windows\Web\Wallpaper\Windows\img0.jpg",GenIconSize:70,BDText:"Windows 10 Wallpaper"})
	Notify.Show({GenIcon:"res\The-Automator.png",GenIconSize:100,BDText:"Notify text",HDText:"The-Automator"})
	Notify.Show({GenIcon:"res\The-Automator.ico",BDText:"Notify text",HDText:"The-Automator"})
	Link example where BDtext should be ""
	Notify.Show({Link:'test <a href="https://mail.google.com/mail/u/0/?tab=rm&ogbl#label/xeo%40the-automator.com" >testing</a>'}) ; can be used any Shell.dll GenIcon number

*/
Class Notify
{
	Static Default :=
	{
		HDText        : "Rufaydium",
		HDFontSize    : "18",
		HDFontColor   : "Black",
		HDFont        : "Trebuchet MS",
		BDText        : "",
		BDFontSize    : "14",
		BDFontColor   : "3f3d5c",
		BDFont        : "Arial",
		GenColor      : "d7f9fa",
		GenDuration   : 3,
		GenSound	  : "Ding",
		GenIcon		  : (SplitPath(A_LineFile  "\..\..\res\Rufaydium.ico",,&DIR), DIR "\Rufaydium.ico"),
		GenIconSize	  : 25,
	}
	Static wavList := "Sound List:`nName" ; `t`t Path"
	Static wav := Notify.GetSoundFiles()

	static Show(Input)
	{
		Switch(Type(Input))
		{
			Case "String":
				this.HDText     := Notify.Default.HDText
				this.HDSize     := Notify.Default.HDFontSize
				this.HDColor    := Notify.Default.HDFontColor
				this.HDFont     := Notify.Default.HDFont
				this.Text       := input
				this.BDSize     := Notify.Default.BDFontSize
				this.BDColor    := Notify.Default.BDFontColor
				this.BDFont     := Notify.Default.BDFont
				this.Duration   := Notify.Default.GenDuration
				this.Color      := Notify.Default.GenColor
				this.Sound      := Notify.Default.GenSound
				this.GenIcon       := Notify.Default.GenIcon
				this.GenIconSize   := Notify.Default.GenIconSize
				this.Link   	:= ""
				this.Callback   := 0
			Case "Object":
				this.HDText     := input.HasOwnProp("HDText")      ? input.HDText      : Notify.Default.HDText
				this.HDSize     := input.HasOwnProp("HDFontSize")  ? input.HDFontSize  : Notify.Default.HDFontSize
				this.HDColor    := input.HasOwnProp("HDFontColor") ? input.HDFontColor : Notify.Default.HDFontColor
				this.HDFont     := input.HasOwnProp("HDFont")      ? input.HDFont      : Notify.Default.HDFont
				this.BDSize     := input.HasOwnProp("BDFontSize")  ? input.BDFontSize  : Notify.Default.BDFontSize
				this.BDColor    := input.HasOwnProp("BDFontColor") ? input.BDFontColor : Notify.Default.BDFontColor
				this.BDFont     := input.HasOwnProp("BDFont")      ? input.BDFont      : Notify.Default.BDFont
				this.Color      := input.HasOwnProp("GenColor")    ? input.GenColor    : Notify.Default.GenColor
				this.Duration   := input.HasOwnProp("GenDuration") ? input.GenDuration : Notify.Default.GenDuration
				this.Sound      := input.HasOwnProp("GenSound")    ? input.GenSound    : Notify.Default.GenSound
				this.GenIcon     := input.HasOwnProp("GenIcon")      ? input.GenIcon      : Notify.Default.GenIcon
				this.GenIconSize := input.HasOwnProp("GenIconSize")  ? input.GenIconSize  : Notify.Default.GenIconSize
				this.Link       := input.HasOwnProp("Link")        ? input.Link        : ""
				this.Callback   := input.HasOwnProp("GenCallback") ? input.GenCallback : 0
				this.Text       := input.HasOwnProp("BDText")      ? input.BDText      : ""
		}

		Notify.Play(this.Sound)
		this.Notice := MultiGui(this)
		if this.Duration != 0
			this.Close()
		return this
	}

	Static Close()
	{
		fn := ObjBindMethod(this, "animation", this.Notice)
		Settimer fn, -(this.Duration * 1000)
	}

	static animation(Notice) => Notice.close()

	static Play(Sound) 
	{
		if FileExist(Sound)
			return Soundplay(Sound)
		try SoundFile := Notify.wav[Sound]
		catch 
			return
		if FileExist(SoundFile)
			Soundplay(SoundFile)
		return 
	}

	Static GetSoundFiles()
	{
		wav := map()
		loop files, "C:\Windows\Media\*.wav"
		{
			name := RegExReplace(A_LoopFileName,"Windows |notify |Hardware |.wav")
			if InStr(name," ")
				continue
			this.wavList .= "`n"  name  ;(InStr(name,"Alarm") ? "`t" : StrLen(name) < 8 ? "`t`t":"`t" ) ": " A_LoopFileName
			wav[name] := A_LoopFileFullPath
		}

		loop files, A_ScriptDir "\res\*.wav"
		{
			name := StrReplace(A_LoopFileName,".wav")
			this.wavList .= "`n"  name ;(StrLen(name) < 8 ? "`t`t":"`t" ) ": " A_LoopFileName
			wav[name] := A_LoopFileFullPath
		}
		return wav
	}


	; method to list all supported Alert Sounds
	Static SoundList() => this.Show({HDText:"GenSound list`nSupported by Notify",BDText:this.wavList,GenDuration:0,GenSound:"Insert"})
	; method to List all Color
	Static ColorList()
	{
		Colors :="
		(
			Black,
			Silver,
			Gray,
			White,
			Maroon,
			Red,
			Purple,
			Fuchsia,
			Green,
			Lime,
			Olive,
			Yellow,
			Navy,
			Blue,
			Teal,
			Aqua
		)"
		this.Show({HDText:"HD BD and Gen Colors`nSupported by Notify",BDText:Colors,GenDuration:0,GenSound:"Remove"})
	}
	; method to list all GenIcons
	Static GenIconList()
	{
		GenIconHelp := "`nGenIcon: can be Integer or Image Path`nOr can also be Following:`nCritical,Question,Exclamation,Information,Security`n`nGenIconSize: is number where x and Y will be same" 
		Notify.Show({
			HDText:"GenIcon List`nGenIcons number or address should be passed",
			BDFontSize:16,
			GenDuration:10,
			GenIcon:96,
			GenIconSize:50,
			Link:'Click this Link for <a href="https://renenyffenegger.ch/development/Windows/PowerShell/examples/WinAPI/ExtractGenIconEx/shell32.html">GenIcon List</a>`n' GenIconHelp
		})
	}
}

Class MultiGui
{
	static Guis := array()
	Static Taskbar := MultiGui.GetTaskBarPos()
	Static LastPOs := {x:0,y:0,w:0,h:0}
	Static ShellDll := A_WinDir "\System32\shell32.dll"
	Static user32Dll := A_WinDir "\system32\user32.dll"
	Static Warning := Map(
							"Exclamation",2,
							"Question",3,
							"Critical",4,
							"Information",5,
							"Security",7
						)
	__new(info)
	{
		MyGui := Gui("-Caption +AlwaysOnTop +Owner +LastFound")
		MyGui.MarginX := 5
		MyGui.MarginY := 5
		MyGui.BackColor := info.Color
		if (Type(Info.GenIcon) = "Integer")
			GenIcon := MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize " Icon" Info.GenIcon, MultiGui.ShellDll)
		else if FileExist(Info.GenIcon)
			GenIcon := MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize,Info.GenIcon )
		else if Info.GenIcon && InStr("Critical,Question,Exclamation,Information,Security",Info.GenIcon)
			GenIcon := MyGui.AddPicture("w" Info.GenIconSize " h" Info.GenIconSize " Icon" MultiGui.Warning[Info.GenIcon], MultiGui.user32Dll)

		MyGui.SetFont("c" info.HDColor " s" info.HDSize , info.HDFont )
		HD := MyGui.Add("Text","x+m", info.HDText)
		MyGui.SetFont("c" info.BDColor " s" info.BDSize , info.BDFont )
		if info.Link
			Notice := MyGui.AddLink(, info.Link)
		else if info.Text
			Notice := MyGui.AddText("y+m",info.Text ) ;"xp yp+" this.Header.Font.Size +9.5, this.Body.Text)
		MyGui.Show("Hide")
		This.MyGui := MyGui
		WinGetPos(&x,&y,&w,&h,MyGui)
		clickArea := MyGui.Add("Text", "x0 y0 w" . W . " h" . H . " BackgroundTrans")
		if info.Callback
		{
			clickArea.OnEvent("Click",     info.Callback )
		}
		if Info.Duration = 0
		{
			clickArea.OnEvent("Click",     ObjBindMethod(this,"Close",MyGui) )
		}

		MultiGui.Guis.Push(MyGui)
		
		if MultiGui.Guis.Length > 1 ;IsSet(LastNote)
		{
			Switch MultiGui.Taskbar.Docked
			{
				Case "B":
					if( (MultiGui.LastPOs.y - h) > 0)
						POS := "x" A_ScreenWidth - w " y" MultiGui.LastPOs.y - h -1
					else
						POS := "x" MultiGui.LastPOs.x - w " y" A_ScreenHeight - MultiGui.TaskBar.h - h
				Case "R":
					if( (MultiGui.LastPOs.y - h) > 0)
						POS := "x" MultiGui.LastPOs.x " y" MultiGui.LastPOs.y - h - 1
					else
						POS := "x" MultiGui.LastPOs.x - w " y" A_ScreenHeight - h
			}
		}
		else
		{
			Switch MultiGui.Taskbar.Docked
			{
				Case "B":
					POS := "x" A_ScreenWidth - w " y" A_ScreenHeight - MultiGui.TaskBar.h - h
				Case "R":
					POS := "x" A_ScreenWidth - w - MultiGui.TaskBar.w " y" A_ScreenHeight - h
				default:
					POS := "x" A_ScreenWidth - w " y" A_ScreenHeight - h
			}
		}

		MyGui.Show(POS " NoActivate")
		WinGetPos(&x,&y,&w,&h,MyGui)
		MultiGui.LastPOs := {x:x,y:y,w:w,h:h}
	}

	Close(*)
	{
		delete := 0
		for i, Gui in MultiGui.Guis
		{
			if this.MyGui.Hwnd = Gui.Hwnd
			{
				MultiGui.Guis.RemoveAt(i)
				MyGui := Gui
				try WinGetPos(&x,&y,&w,&h,MultiGui.Guis[i-1])
				catch
					try WinGetPos(&x,&y,&w,&h,MultiGui.Guis[i])
				delete := 1
			}
		}
		if Delete = 0
			return
		WinGetPos(&ix,&iy,&w,&h,MyGui)
		loop 50
		{
			If (!Mod(A_index, 18))
			{
				WinSetTransColor("Blue " 255 - A_index * 5,MyGui)
				MyGui.Move(iX += 10, iY)
				sleep 50
			}
		}

		this.MyGui.Destroy()
		if IsSet(x)
			MultiGui.LastPOs := {x:x,y:y,w:w,h:h}
		else
			MultiGui.LastPOs := {x:0,0:0,w:0,h:0}
	}

	Static GetTaskBarPos()
	{
		WinGetPos(&x,&y,&w,&h, "ahk_class Shell_TrayWnd")
		if x = 0 && y = 0 && w = A_ScreenWidth
			Docked := "T"
		else if x = 0 && y = 0 && h = A_ScreenHeight
			Docked := "L"
		else if x = 0 &&  y > 0 && w = A_ScreenWidth
			Docked := "B"
		else if x > 0 && y = 0 && h = A_ScreenHeight
			Docked := "R"
		return {x:x,y:y,w:w,h:h,Docked:Docked}
	}
}