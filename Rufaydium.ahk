; Rufaydium V2 Beta for AHK V2
; By Xeo786
#Requires AutoHotkey v2+
#Include ".\Lib\WDM.ahk"
#Include ".\Lib\Capabilities.ahk"
#Include ".\Lib\Cjson.ahk"
#Include ".\Lib\Session.ahk"
#include ".\Lib\Elements.ahk"
#include ".\Lib\Action.ahk"
#include ".\Lib\Base64.ahk"
#include ".\Lib\WebSocket.ahk"
#include ".\Lib\WS.ahk"
#include ".\Lib\Notify.ahk"

Class Rufaydium
{
    static WebRequest := ComObject('WinHttp.WinHttpRequest.5.1')

    __New(instance:="Chrome",TrayIcon:=1)
    {
        Switch instance, false
		{
			case "Chrome", "chromedriver":
				driver := "chromedriver.exe", port := 9515, Browser := "chrome.exe"
				this.capabilities := ChromeCapabilities("chrome","goog:chromeOptions")
			case "Edge", "MsEdge", "Edge", "msedgedriver" :
				this.capabilities := EdgeCapabilities("msedge","ms:edgeOptions")
				driver := "msedgedriver.exe", Port := 9516, Browser := "msedge.exe"
			case "FireFox", "geckodriver" :
				this.capabilities := FireFoxCapabilities("firefox","moz:firefoxOptions")
				driver := "geckodriver.exe", Port := 9517, Browser := "firefox.exe"
			case "Opera", "operadriver" :
				this.capabilities := OperaCapabilities("opera","goog:chromeOptions")
				driver := "operadriver.exe", Port := 9518, Browser := "opera.exe"
			case "Brave", "BraveDriver" :
				this.capabilities := BraveCapabilities("chrome","goog:chromeOptions")
				driver := "chromedriver.exe", Port := 9519, Browser := "brave.exe"
				FileGetShortcut A_AppDataCommon "\Microsoft\Windows\Start Menu\Programs\Brave.lnk", &OutTarget, &outdir
				this.capabilities.Setbinary(outdir "\Brave.exe")
			default:
				; Download EventFiring WebDriver [ EventFiring Driver() supports majority of browsers ]
				this.capabilities := capabilities.Simple
				driver := instance, port := 9520
		}
		This.Driver := RunDriver(driver, port)
		this.Browser := Browser
		if TrayIcon and !A_IsCompiled
			Rufaydium.SetTrayIcon()
    }

	SetTimeouts(ResolveTimeout:=3000,ConnectTimeout:=3000,SendTimeout:=3000,ReceiveTimeout:=3000)
	{
		Rufaydium.WebRequest.SetTimeouts(ResolveTimeout,ConnectTimeout,SendTimeout,ReceiveTimeout)
	}

	Send(url,Method,Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		r := Json.parse(Rufaydium.Request(url,Method,Payload,WaitForResponse))["value"] ; Thanks to GeekDude for his awesome cJson.ahk
		if r.has("error")
			if (r["error"] = "chrome not reachable") ; incase someone close browser manually but session is not closed for driver
				this.quit() ; so we close session for driver at cost of one time response wait lag
		if r
			return r
	}

	static Request(url,Method,p:=0,w:=1)
	{
		Rufaydium.WebRequest.Open(Method, url, false)
		Rufaydium.WebRequest.SetRequestHeader("Content-Type","application/json")
		if p
		{
			p := RegExReplace(json.stringify(p),"\\\\uE(\d+)","\uE$1")  ; fixing Keys turn '\\uE000' into '\uE000'
			Rufaydium.WebRequest.Send(p)
		}
		else
			Rufaydium.WebRequest.Send()
		if w
			Rufaydium.WebRequest.WaitForResponse()
		return Rufaydium.WebRequest.responseText
	}

	static GetTabPids(DriverPID,BrowserName) 
	{
		pids := []
		for proc in ComObjGet("winmgmts:").ExecQuery("Select * from Win32_Process WHERE Name = '" BrowserName "'")
			if ( proc.ParentProcessId = DriverPID)
				pids.Push(proc.processid)
		return pids
	}

	NewSession(Callback:=0,Binary:="")
	{
		if Binary
			this.capabilities.Setbinary(Binary)
		r := this.Send( this.Driver.Url "/session","POST",this.capabilities.cap,1) ; r = reponse
		if r.has("error")
		{
			if RegExMatch(r['message'],"version ([\d.]+).*\n.*version is (\d+.\d+.\d+)")
			if	MsgBox(r['message'] "`n`nPlease press Yes to download latest driver","Rufaydium WebDriver Support",52) = "Yes"
			{
				this.driver.exit()
				i := this.driver.GetDriver(r['message'])
				if !FileExist(i)
				{
					Msgbox("Unable to download driver`nRufaydium exiting.","Rufaydium WebDriver Support")
					ExitApp
				}
				This.Driver.Launch()
				return This.NewSession()
			}
			msgbox( r["error"] "`n`n" r["message"],"Rufaydium WebDriver Support Error",48)
			return r
		}
		if this.Driver.Driver = "geckodriver.exe"
		{
			debuggerAddress := r["capabilities"]["moz:debuggerAddress"]
			IniWrite debuggerAddress, this.driver.dir "/FFSessions.ini", this.Driver.Driver, r["sessionId"]
		}
		else
			debuggerAddress := StrReplace(r["capabilities"][this.capabilities.options]["debuggerAddress"],"localhost","127.0.0.1")
		if r["capabilities"].has("webSocketUrl")
			websocketurl := r["capabilities"]["webSocketUrl"]
		else
			websocketurl := 0
		return Session(this.Driver.Url "/session/" r["sessionId"], debuggerAddress, this.Browser, websocketurl,this.Driver.pid,Callback)
	}

	; get all Sessions Details
	Sessions() => this.send(this.Driver.Url "/sessions","GET")

	; get all Sessions for Rufaydium
	getSessions()
	{
		if !this.capabilities.options
			return []
		i := 0
		Sessionarray := []
		if this.Driver.Driver = "geckodriver.exe"
		{
			Sessionlist := IniRead(this.Driver.dir "/FFSessions.ini",this.Driver.Driver)
			for k, SessionLine in StrSplit(SessionList,"`n")
			{
				if !RegExMatch(SessionLine, "(.*)=(.*)", &Se)
				{
					IniDelete this.driver.dir "/ActiveSessions.ini", This.Driver.Driver, se
					continue
				}

				if r :=  this.Send(this.Driver.Url "/session/" Se[1] "/url","GET")
				&& r.has("error")
					IniDelete this.driver.dir "/ActiveSessions.ini", This.Driver.Driver, se[1]
				else
				{
					Sessionarray.Push(
						Session(
							this.Driver.Url "/session/" Se[1],
							Se[2],
							this.Browser,,
							this.Driver.pid
						)
					)
				}
			}
			return Sessionarray
		}

		windows := []
		for k, Se in this.Sessions()
		{
			debuggeraddress := StrReplace(Se["capabilities"][this.capabilities.options]["debuggerAddress"],"localhost","127.0.0.1")
			windows.Push(
				Session(
					this.Driver.Url "/session/" Se["id"],
					debuggeraddress,
					this.Browser,
					(Se["capabilities"].has("websocketurl") ? Se["capabilities"]["websocketurl"] : ""),
					this.Driver.pid
					)
				)
		}
		return windows
	}

	; Get existing Session by number 'i' and Tab 't'
	getSession(instance:=0,tabnumber:=0)
	{
		if instance
		{
			S := this.getSessions()
			if S.has(instance)
			{
				S := S[instance]
				if tabnumber
					{
						try S.SwitchTabs(tabnumber)
					}
					else
						S.ActiveTab()
					return S
			}
		}
	}

	; get Existing Session by URL, it will look into all sessions and return with first match
	getSessionByUrl(url)
	{
		for k, w in this.getSessions()
		{
			w.SwitchbyURL(url)
			RUrl := w.url
			if isobject(RUrl)
				if RUrl.has("error")
					return

			if instr(w.url,url)
				return w
		}
	}

	; get Existing Session by Title, will look for title in all sessions and return with first match
	getSessionByTitle(Title)
	{
		for k, s in this.getSessions()
		{
			s.SwitchbyTitle(Title)
			if instr(s.title,Title)
				return s
		}
	}

	; Get all session Quit one by one
	QuitAllSessions()
	{
		for k, s in this.getSessions()
			s.Quit()
	}

	Static SetTrayIcon() => TraySetIcon( A_LineFile  "\..\res\Rufaydium.ico")

	; Exit Driver
	Exit() => this.Driver.Exit()

}