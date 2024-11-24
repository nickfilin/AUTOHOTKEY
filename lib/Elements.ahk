Class Element
{
    __new(Address,element)
    {
		this.defineprop( 'address', { get : (this) => address, set : (this, value) => address := value})
        this.defineprop( 'element', { get : (this) => element, set : (this, value) => element := value})
    }

	__set( n,a,v) => this.Execute(("arguments[0]." n (a.Length > 0 ? "[" RegExReplace(json.stringify(map("obj", a)),'\{"obj":\[(.*)\]\}',"$1") "]":"") " = " (IsNumber(v) ? v : "'" v "'")))
    __get( n,a)	  => this.Execute("return arguments[0]." n . (a.Length > 0 ? "[" RegExReplace(json.stringify(map("obj", a)),'\{"obj":\[(.*)\]\}',"$1") "]":"") )
	__call(n,a)   => this.Execute("return arguments[0]." n "(" RegExReplace(json.stringify(map("obj", a)),'\{"obj":\[(.*)\]\}',"$1") ")" )

    Rect()                      => this.Send("rect","GET")
	enabled()                   => this.Send("enabled","GET")
	Selected()                  => this.Send("selected","GET")
	Displayed()                 => this.Send("displayed","POST",map())
	submit()                    => this.Send("submit","POST",map())
	SendKey(text)               => this.Send("value","POST", map("text", text))
    click(slient:=1)            => slient ? this.Execute("arguments[0].click()") : this.Send("click","POST",map())
    Move()                      => this.Send("moveto","POST",map("element_id",this.id))
    Clear()                     => this.Execute("arguments[0].value = ''")
    GetAttribute(Name)          => this.Send("attribute/" Name,"GET")
    GetProperty(Name)           => this.Send("property/" Name,"GET")
    GetCSS(Name)                => this.Send("css/" Name,"GET")
    ComputedRole()              => this.Send("computedrole","GET")
    ComputedLable()             => this.Send("computedlabel","GET") 
    Screenshot()     			=> this.Send("screenshot","GET")

	CaptureScreenShot(location:=0)
	{
		if !Location
			Location := FileSelect("s", , "Save as Image","Image (*.bmp; *.png)")
		if FileExist(Location)
			FileDelete Location
		FileObj := FileOpen(location, "w")
		FileObj.RawWrite(Base64.Decode(this.Screenshot(),"Raw"))
		FileObj.Close()
	}

	Send(url,Method,Payload:= 0,WaitForResponse:=1)
	{
		if !instr(url,"HTTP")
			url := this.address "/" url
		if !Payload and (Method = "POST")
			Payload := Json.null
		try r := Json.parse(Rufaydium.Request(url,Method,Payload,WaitForResponse))["value"] ; Thanks to GeekDude for his awesome cJson.ahk
		if !r
			return
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
		if r
			return r
	}

	Execute(script)
	{
		script := strreplace(script,"'[","[")
		script := strreplace(script,"]'","]")
		script := strreplace(script,"_",".")
		Origin := this.Address
		RegExMatch(Origin, "(.*)\/element\/(.*)$", &i)
		this.address := i[1]
		r := this.Send("execute/sync", "POST", map("script",Script,"args",[map(This.Element,i[2])]),1)
		this.address := Origin
		return r
	}

	findelement(u,v)
	{
		r := this.Send("element","POST",map("using",u,"value",v),1)
		for i, elementid in r
		{
			if instr(elementid,"no such")
				return 0
			address := RegExReplace(this.address "/element/" elementid,"(\/shadow\/.*)\/element","/element")
			address := RegExReplace(address "/element/" elementid,"(\/element\/.*)\/element","/element")
			return Element(address,i)
		}
	}

	findelements(u,v)
	{
		e := Map()
		for k, elements in this.Send("elements","POST",map("using",u,"value",v),1)
		{
			for i, elementid in elements
			{
				address := RegExReplace(this.address "/element/" elementid,"(\/shadow\/.*)\/element","/element")
				address := RegExReplace(address "/element/" elementid,"(\/element\/.*)\/element","/element")
				e[k-1] := Element(address,i)
			}
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
	getElementbypLinkText(PartialText)	=> this.findelement( Session.by.linktext,PartialText)
	getElementsbypLinkText(PartialText)	=> this.findelements(Session.by.linktext,PartialText)

	parentElement
	{
		get
		{	
			for i, elementid in this.Execute("return arguments[0].parentElement")
			{
				address := RegExReplace(this.address "/element/" elementid,"(\/shadow\/.*)\/element","/element")
				address := RegExReplace(address "/element/" elementid,"(\/element\/.*)\/element","/element")
				return Element(address,i)
			}	
		}
	} 

    children
	{
		get
		{	
			e := Map()
			for k, elements in this.Execute("return arguments[0].children")
			{
				for i, elementid in elements
				{
					address := RegExReplace(this.address "/element/" elementid,"(\/shadow\/.*)\/element","/element")
					address := RegExReplace(address "/element/" elementid,"(\/element\/.*)\/element","/element")
					e[k-1] := Element(address,i)
				}
			}
			if e.Count > 0
				return e
			return 0
		}
	}
}

Class ShadowElement
{
	__new(Address)
	{
		This.Address := Address
	}
}


/*

this.__call(name, args)
this.__get(name, args)
this.__set(name, args, value)

*/
