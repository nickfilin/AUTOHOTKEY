Class Session
{
	name := Address := debuggerAddress := currentTab := websocketurl := pid := Hwnd := ""
    __New(address, debuggerAddress, name, websocketurl:=0,PID:=0,callback:=0)
    {
		this.name := name
		this.Address := Address
		this.debuggerAddress := debuggerAddress
		this.currentTab := this.Send("window","GET")
		pids := Rufaydium.GetTabPids(PID,name)
		this.pid := Session.GetSessionPID(pids,this.Send("title","GET"))
		if this.pid
			this.Hwnd := WinGetID( "ahk_pid " this.pid)
		else
			this.pid := pids[1]
		if websocketurl
			this.websocketurl := websocketurl

		; We are testing websockets can be enabled from there manually
		;this.WS := WS("ws://" this.debuggerAddress "/devtools/page/" this.currentTab, callback)
		Notify.show("Session Created")
        return this
    }

	static GetSessionPID(pids,Title)
	{
		if !Title
			return 0
		for pid in Pids
		{
			t := WinGetTitle("ahk_pid " pid)
			if t = "Restore pages?"
				t := closeRestorePage(t,pid)		
			if instr(t,Title)
				return pid
		}

		closeRestorePage(t,pid)
		{
			msgPID := WinGetID(t)
			ProcessClose(msgPID)
			ProcessWaitClose(msgPID)
			return WinGetTitle("ahk_pid " pid)
		}
	}

	exist() => ProcessExist(this.pid)
    ; To quit Session
	Quit() => this.Send(this.address ,"DELETE")

    ; To close tab or window
	close()
	{
		Tabs := this.Send("window","DELETE")
		if Tabs || Tabs.has("error")
			return
		if tabs.Length > 0
			this.SwitchTab(this.currentTab := tabs[tabs.Length])
	}

    Send(url,Method,Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		try r := Json.parse(Rufaydium.Request(url,Method,Payload,WaitForResponse))["value"] ; Thanks to GeekDude for his awesome cJson.ahk
		if !r
			return r
		t := ComObjType(r)
		if t
		{
			v := ComObjValue(r)
			switch v
			{
				case 65535:
					return true
				case 0:
					switch t
					{
						case 11: return false
						case 1: return "null"
					}
			}
		}
		if isobject(r)
			if r.has("error")
			{		
				if (r["error"] = "chrome not reachable") ; incase someone close browser manually but session is not closed for driver
					this.quit() ; so we close session for driver at cost of one time response wait lag
				if (r["error"] = "no such window") 
					return
			}
		if r
			return r
	}

	Detail() 			=> Json.parse(Rufaydium.Request("http://" this.debuggerAddress "/json/list","GET"))
	GetTabs() 			=> this.Send("window/handles","GET")
	SwitchTab(Tabid)	=> this.Send("window","POST",map("handle",this.currentTab := Tabid))
	SwitchTabs(n)		=> this.SwitchTab(This.currentTab := this.GetTabs()[n])
	ActiveTab()  		=> this.SwitchTab(this.Detail()[1]['id'])
	NewTab()			=> this.send("window/new","POST",map("type","tab"))["handle"]
	NewWindow()			=> this.send("window/new","POST",map("type","window"))["handle"]
	Minimize()			=> this.Send("window/minimize","POST",Map())
	Maximize()			=> this.Send("window/maximize","POST",Map())
	FullScreen()		=> this.Send("window/fullscreen","POST",Map())
	GetRect()			=> this.Send("window/rect","GET")
	SetRect(x,y,w,h)	=> this.Send("window/rect","POST",map("x",x ?? 1,"y",y ?? 1,"width",w ?? 0,"height",h ?? 0))
	refresh()			=> this.send("refresh","POST",map())

	SwitchbyTitle(Title)
	{
		handles := this.GetTabs()
		try pages := this.Detail() ; if Browser closed by user this will closed the session
		if !isset(pages)
			return []
		phandle := This.currentTab
		for k , handle in handles
		{
			for i, t in pages ;Targets.targetInfos
			{
				if instr(Handle,t["id"])
				{
					if !t.Has("title")
					{
						this.SwitchTab(handle)
						if instr(this.title,Title)
							return
						else
							continue
					}
					else if instr(t["title"], Title)
					{
						This.currentTab := handle
						this.SwitchTab(This.currentTab )
						return
					}
				}
			}
		}
		if pHandle
			this.SwitchTab(handle)
	}

	; Switch tab/window by URL
	SwitchbyURL(url:="")
	{
		handles := this.GetTabs()
		try pages := this.Detail() ; if Browser closed by user this will closed the session
		if !isset(pages)
			return []
		for k , handle in handles
		{
			for i, t in pages
			{
				if instr(Handle,t["id"])
				{
					if instr(t["url"], url)
					{
						This.currentTab := Handle
						this.SwitchTab(This.currentTab )
						return
					}
				}
			}
		}
	}

	url
	{
		get => this.Send("url","GET")
		set => this.Send("url","POST",map("url", Session.EnsureHTTPS(Value)))
	}

	static EnsureHTTPS(str) ; not working for "url=chrome://extensions/"
	{
		if !(str ~= "https?:\/\/")
			str := "https://" str

		return regexreplace(str, "https?", "https")
	}

	; to navigate to 1 or multiple urls Navigate(url1,url2,url3)
	Navigate(urls*)
	{
		for url in urls
			if a_index = 1
				this.url := url
			else
				this.CDPCall("Target.createTarget",map("url", Session.EnsureHTTPS(url)))
	}

	CreateTabs(urls*)
	{
		for url in urls
			this.CDPCall("Target.createTarget",map("url", Session.EnsureHTTPS(url)))
	}

	readyState
	{
		get => this.ExecuteSync("return document.readyState")
	}

	HTML
	{
		get => this.Send("source","GET",0,1)
	}

	Title
	{
		get => this.Send("title","GET")
	}

	Cookies ;[CookieMAP]
	{
		get => this.Send("cookie","GET")
		;set => this.Send("cookie","POST",CookieMAP)
	}

	GetCookie(Name) => this.Send("cookie/" Name,"GET")

	FramesLength() => this.ExecuteSync("return window.length")

	Frame(i) => this.Send("frame","POST",map("id",i))

	TopFrame()
	{
		loop this.frameDepth
			this.ParentFrame()
	}

	ParentFrame() => this.Send("frame/parent","POST",map())

	GetFrame(parantFrame:=0) ; under construction
	{
		static frameDepth := 0
		frames := array()
		if parantFrame
			frameDepth := 0
		++frameDepth
		loop this.FramesLength()
		{

			result := this.Frame(a_index-1)
			if result and result.has("error")
				continue
			Name := this.ExecuteSync('return window.name')
			title := this.ExecuteSync('return document.title')
			url := this.ExecuteSync('return document.location.href')
			frames.push(map('name',name,'title',title,'url',url))
			if this.FramesLength() != 0
			 	this.GetFrame(frames)
			this.ParentFrame()
		}
		if parantFrame
			return parantFrame.push(frames)
		else
			return Map("parentFrame", frames)
	}

	FramebyName(name) ; under construction
	{
		loop this.FramesLength()
		{
			this.Frame(a_index)
			windowname := this.ExecuteSync('return window.name')
			if windowname = name
				return
			this.FramebyName(name)
			this.ParentFrame()
		}
	}

	FramebyTitle(Title) ; under construction
	{
		loop this.FramesLength()
		{
			this.Frame(a_index)
			FTitle := this.ExecuteSync('return document.title')
			if FTitle = Title
				return
			this.FramebyName(Title)
			this.ParentFrame()
		}
	}

	Alert(Action,Text:=0)
	{
		switch Action
		{
			case "accept": i := "/alert/accept", m := "POST"
			case "dismiss": i := "/alert/dismiss", m := "POST"
			case "GET": i := "/alert/text", m := "GET"
			case "Send": i := "/alert/text", m := "POST"
		}

		if Text
			return this.Send(this.address i,m,map("text",Text))
		else
			return this.Send(this.address i,m)
	}

	ExecuteSync(Script,Args*) 	=> this.Send("execute/sync", "POST", map("script",Script,"args",[Args*]),1)
	ExecuteAsync(Script,Args*) 	=> this.Send("execute/async","POST", map("script",Script,"args",[Args*]),1)

	; element setting gettings
	ActiveElement()
	{
		for i, elementid in this.Send("element/active","GET")
			return Element(this.address "/element/" elementid,i)
	}

	shadow()
	{
		for i,  elementid in this.Send("shadow","GET")
		{
			return ShadowElement(this.address "/element/" elementid)
		}
	}

	findelement(u,v)
	{
		r := this.Send("element","POST",map("using",u,"value",v),1)
		for i, elementid in r
		{
			if instr(elementid,"no such")
				return 0
			return Element(this.address "/element/" elementid,i)
		}
	}

	findelements(u,v)
	{
		e := Map()
		for k, elements in this.Send("elements","POST",map("using",u,"value",v),1)
		{
			for i, elementid in elements
				e[k-1] := Element(this.address "/element/" elementid, i)
		}

		if e.Count > 0
			return e
		return 0
	}

	querySelector(path)					=> this.findelement( Session.by.selector,Path)
	querySelectorAll(path)				=> this.findelements(Session.by.selector,Path)
	getElementbyid(id) 					=> this.findelement( Session.by.selector,"#" id)
	getElementsbyid(id) 				=> this.findelements(Session.by.selector,"#" id)
	getElementsbyClassName(Class)		=> this.findelements(Session.by.selector,"[class='" Class "']")
	getElementsbyTagName(Name)			=> this.findelements(Session.by.TagName ,Name)
	getElementsbyName(Name)				=> this.findelements(Session.by.selector,"[Name='" Name "']")
	getElementsbyXpath(xPath)			=> this.findelements(Session.by.xPath   ,xPath)
	getElementbyLinkText(Text)			=> this.findelement( Session.by.linktext,Text)
	getElementsbyLinkText(Text)			=> this.findelements(Session.by.linktext,Text)
	getElementbypLinkText(PartialText)	=> this.findelement( Session.by.Plinktext,PartialText)
	getElementsbypLinkText(PartialText)	=> this.findelements(Session.by.Plinktext,PartialText)

	; end getting element methods
	CDPCall(Method, Params:="")	=> this.Send("goog/cdp/execute","POST",map("cmd",Method,"params", Params ?? map()))
	Screenshot()				=> this.Send("screenshot","GET")

	CaptureScreenShot(Location:=0)
	{
		if !Location
			Location := FileSelect("s", , "Save as Image","Image (*.bmp; *.png)")
		if FileExist(Location)
			FileDelete Location
		FileObj := FileOpen(location,"w")
		FileObj.RawWrite(Base64.Decode(this.Screenshot(),"Raw"))
		FileObj.Close()
		Notify.show("ScreenShot Captured:`n" Location )
	}

	CaptureFullSizeScreenShot(location:=0)
	{
		if !Location
			Location := FileSelect("s", , "Save as Image","Image (*.bmp; *.png)")
		if FileExist(Location)
			FileDelete Location
		FileObj := FileOpen(location, "w")
		this.CDPCall("Emulation.setDeviceMetricsOverride", map("width",this.Getrect()["width"],
															"height",this.ExecuteSync("return document.documentElement.scrollHeight")+0,
															"deviceScaleFactor",1,
															"mobile",json.false))
		FileObj.RawWrite(Base64.Decode(this.Screenshot(),"Raw"))
		this.CDPCall("Emulation.setDeviceMetricsOverride")
		FileObj.Close()
	}

	;;;; Actions Handlings;;;;;

	click(i:=Mouse.LButton)
	{
		MouseEvent := Mouse()
		MouseEvent.Release(i)
		MouseEvent.Pause(100)
		MouseEvent.Release(i)
		return this.Actions(MouseEvent)
	}

	DoubleClick(i:=Mouse.LBUTTON)
	{
		MouseEvent := Mouse()
		; click 1
		MouseEvent.Release(i)
		MouseEvent.Pause(100)
		MouseEvent.Release(i)
		; delay
		MouseEvent.Pause(500)
		; click 2
		MouseEvent.Release(i)
		MouseEvent.Pause(100)
		MouseEvent.Release(i)
		return this.Actions(MouseEvent)
	}

	MBDown(i:=Mouse.LBUTTON)
	{
		MouseEvent := Mouse()
		MouseEvent.Press(i)
		return this.Actions(MouseEvent)
	}

	MBup(i:=Mouse.LBUTTON)
	{
		MouseEvent := Mouse()
		MouseEvent.Release(i)
		return this.Actions(MouseEvent)
	}

	Move(x,y)
	{
		MouseEvent := Mouse()
		MouseEvent.move(x,y,0)
		return this.Actions(MouseEvent)
	}

	ScrollUP(s:=50)
	{
		WheelEvent := Scroll()
		WheelEvent.ScrollUP(s)
		return this.Actions(WheelEvent)
	}

	ScrollDown(s:=50)
	{
		WheelEvent := Scroll()
		WheelEvent.ScrollDown(s)
		return this.Actions(WheelEvent)
	}

	ScrollLeft(s:=50)
	{
		WheelEvent := Scroll()
		WheelEvent.ScrollLeft(s)
		return this.Actions(WheelEvent)
	}

	ScrollRight(s:=50)
	{
		WheelEvent := Scroll()
		WheelEvent.ScrollRight(s)
		return this.Actions(WheelEvent)
	}

	SendKey(Chars)
	{
		KeyboardEvent := Keyboard()
		KeyboardEvent.SendKey(Chars)
		return this.Actions(KeyboardEvent)
	}

	Actions(Interactions*)
	{
		if isObject(Interactions)
		{
			ActionArray := []
			for i, interaction in Interactions
			{
				ActionArray.push(interaction.perform())
				;Interaction.clear()
				Interaction := ""
			}
			return this.Send("actions","POST",map("actions",ActionArray))
		}
		else
			return this.Send("actions","DELETE")
	}

	Class by
	{
		static selector := "css selector"
		static Linktext := "link text"
		static Plinktext := "partial link text"
		static TagName := "tag name"
		static XPath	:= "xpath"
	}
}


