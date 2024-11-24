class Capabilities
{
    static Simple := map("cap",map("capabilities",map("","")))
    static _ucof := false
    static _hmode := false
    static _incog := false
    static _Bidi := false
    static olduser := []
    static _Uprompt := "dismiss"
    __new(browser,Options,platform:="windows",notify:=false)
    {
        this.options := Options
        this.cap := map(
            "capabilities",map(
                "alwaysMatch",map(
                    this.options,map(
                        "w3c",json.true,
                        "args",[],
                        "excludeSwitches",[],
						"useAutomationExtension",JSON.false
                        ),
                    "webSocketUrl",json.false,
                    "browserName",browser,
                    "unhandledPromptBehavior",Capabilities._Uprompt
                    ),
                "firstMatch",[map()]    
                ),
            "desiredCapabilities", map("browserName", browser)
            )
        if(notify = false)
        {
           this.AddexcludeSwitches("enable-automation")
        }
        this._ucof := false
        this._hmode := false
        this._incog := false
        this._Bidi := false
        this.olduser := []
        this._Uprompt := "dismiss"
        ;return this
    }

    AddexcludeSwitches(excludeSwitch)
    {
       Switches := this.cap["capabilities"]["alwaysMatch"][this.Options]["excludeSwitches"]
       For Value in Switches
            if Value = excludeSwitch
                return
       Switches.push(excludeSwitch)
    }

    addArg(arg) ; args links https://peter.sh/experiments/chromium-command-line-switches/
    {
       if( this.options = "moz:firefoxOptions")
       arg := StrReplace(arg,"--","-")
       args := this.cap["capabilities"]["alwaysMatch"][this.Options]["args"]
       For Value in args
            if Value = arg
                return
       args.push(arg)
    }

    RemoveArg(arg,match:="Exact")
    {
        ;if( this.options = "geckodriver")
        ;    arg := StrReplace(arg,"--","-")
        args := this.cap["capabilities"]["alwaysMatch"][this.Options]["args"]
        For i, Value in args
        {
            if(match = "Exact")
            {
                if(Value = arg)
                    args.RemoveAt(i)
            }
            else
            {
                if instr(Value,arg)
                    args.RemoveAt(i)
            }
        }
    }
    
    BiDi
    {
        Get => this._Bidi
        Set
        {
            if value
            {
                this._Bidi := true
                this.cap["capabilities"]["alwaysMatch"]["webSocketUrl"] := json.true
            }      
            else
            {
                this._Bidi := false
                this.cap["capabilities"]["alwaysMatch"]["webSocketUrl"] := json.false    
            }   
        }
    }

    UserPrompt
    {
        Get => this._Uprompt
        set
        {
            _unset := 0
            switch Value
            {
               Case "dismiss": this._Uprompt := "dismiss"
               Case "accept": this._Uprompt := "accept"
               Case "dismiss and notify": this._Uprompt := "dismiss and notify"
               Case "accept and notify": this._Uprompt := "accept and notify"
               Case "ignore": this._Uprompt := "ignore"
               Default: _unset := 1
            }

            if _unset
            {
                Prompt := "Warning: wrong UserPrompt has been passed.`n"
                . "Use following case-sensitive parameters:`n"
                . chr(34) "dismiss" chr(34) "`n"
                . chr(34) "accept" chr(34) "`n"
                . chr(34) "dismiss, and, notify" chr(34) "`n"
                . chr(34) "accept, and, notify" chr(34) "`n"
                . chr(34) "ignore" chr(34) "`n"
                . "`n`nPress OK to continue"
                msgbox( Prompt, "Rufaydium Capabilities Error", 48)
                return
            }
            this.cap["capabilities"]["alwaysMatch"]["unhandledPromptBehavior"] := this._Uprompt
        }

    }

    HeadlessMode
    {
        get => this._hmode

        set 
        {
            if value
            {
                this.addArg("--headless")
                this._hmode := true
            }
            else
            {
                this._hmode := false
                this.RemoveArg("--headless")
	        }	
        }
        
    }

    
    IncognitoMode
    {
        set 
        {
            if value
            {
                this.olduser.push(this.RemoveArg("--user-data-dir=","in"))
                this.olduser.push(this.RemoveArg("--profile-directory=","in"))
                this.addArg("--incognito")
                this._incog := true
            }
            else
            {
                this._incog := false
                this.RemoveArg("--incognito")
                for i, arg in this.olduser
                    if arg 
                        this.addArg(arg)
                this.olduser := []
	        }	
        }
     
        get => this._incog
    }

    Setbinary(location)
    {
        this.cap["capabilities"]["alwaysMatch"][this.Options]["binary"] := StrReplace(location, "\", "/")
    }


    Resetbinary()
    {
        this.cap["capabilities"]["alwaysMatch"][this.Options].Delete("binary")
    }
}

class ChromeCapabilities extends Capabilities
{
	setUserProfile(profileName:="Profile 1", userDataDir:=0) ; Default is sample profile used everytime to create new profile
	{
        if this.HasProp("IncognitoMode")
        && this.IncognitoMode
				return
		
        if !userDataDir
			userDataDir := StrReplace(A_AppData, "\Roaming") "\Local\Google\Chrome\User Data"

        if profileName ~= '@'
            profileName :=  GetChromeProfiles(profileName,userDataDir)

        userDataDir := StrReplace(userDataDir, "\", "/")
		; removing previous args if any
		this.RemoveArg("--user-data-dir=","in")
		this.RemoveArg("--profile-directory=","in")
		; adding new profile args
		this.addArg("--user-data-dir=" userDataDir)
		this.addArg("--profile-directory=" profileName)

		if fileExist( userDataDir "\" profileName )
            return

        Prompt := "Warning: Following Profile is Directory does not exist`n"
        . chr(34) userDataDir "\" profileName  chr(34) "`n"
        . "`n`nRufaydium is going to create profile directory Manually exitapp"
        . "`nPress OK to continue / Manually exitapp"
        msgbox Prompt,"Rufaydium Capabilities", 48
        DirCreate(userDataDir "\" profileName)
        return

        GetChromeProfiles(email,userDataDir)
        {
            static UserProfiles := Map()

            if UserProfiles['Profiles'].has(email)
                return  UserProfiles["Profiles"][email]

            UserProfiles["Profiles"] := map()
            UserProfiles["userDataDir"] := userDataDir
            Name     := "Default"
            Default  :=  userDataDir "\" name
            default_email := getProfileEmail(Default)
            UserProfiles["Profiles"][default_email] := Name
            Loop Files, userDataDir "\Profile*", "D"
            {
                UserProfiles["Profiles"][getProfileEmail(A_LoopFileFullPath)] := A_LoopFileName
            }
            return UserProfiles["Profiles"][email]

            getProfileEmail(path)
            {
                if RegExMatch( m := FileRead(path "\Preferences","utf-8"),'"email":"(?<email>.*)","full_name',&Profile)
                    return Profile["email"]
            }
        }
	}

    useCrossOriginFrame
    {
        get => this._ucof

        set {
            if value
            {
                this.addArg("--disable-site-isolation-trials")
		        this.addArg("--disable-web-security")
                this._ucof := true
            }
            else
            {
                this._ucof := false
                this.RemoveArg("--disable-site-isolation-trials")
                this.RemoveArg("--disable-web-security")
	        }	
        }
    }
}

;under construction

class FireFoxCapabilities extends Capabilities
{
    __new(browser,Options,platform:="windows",notify:=false)
    {
        ;this.cap := {}
        ;this.cap.capabilities := {}
        ;this.cap.capabilities.alwaysMatch := { this.options :{"prefs":{"dom.ipc.processCount": 8,"javascript.options.showInConsole": json.false()}},"webSocketUrl": json.true}
        this.options := Options
        this.cap := map(
            "capabilities",map(
                "alwaysMatch",map(
                    this.options,map(
                        "prefs",map("dom.ipc.processCount",8,"javascript.options.showInConsole", json.false),
                        ),
                    "webSocketUrl",json.true,
                    "browserName",browser,
                    "platformName",platform
                    ),
                "log",map("level","trace"),
                "env",map()
                )
            )
        ;this.cap.capabilities.log := {}
        ;this.cap.capabilities.log.level := "trace"
        ;this.cap.capabilities.env := {}

        ; ; reg read binary location
        ; this.cap.capabilities.Setbinary("")
        ;this.cap.desiredCapabilities := {}
        ;this.cap.desiredCapabilities.browserName := browser
    }

    DebugPort(Port:=9222)
    {
        ;this.cap.capabilities.alwaysMatch[this.Options].debuggerAddress := "http://127.0.0.1:" Port
        msgbox "debuggerAddress is not support for FireFoxCapabilities"
    }

    addArg(arg) ; idk args list
    {
        arg := StrReplace(arg,"--","-")
        if !this.cap["capabilities"]["alwaysMatch"][this.Options].has("args")
            this.cap["capabilities"]["alwaysMatch"][this.Options]["args"] := map()
        args := this.cap["capabilities"]["alwaysMatch"][this.Options]["args"]
        For Value in args
             if Value = arg
                 return
        args.push(arg)
    }

    RemoveArg(arg,match:="Exact")
    {
        ;if( this.options = "geckodriver")
        ;    arg := StrReplace(arg,"--","-")
        args := this.cap["capabilities"]["alwaysMatch"][this.Options]["args"]
        For i, Value in args
        {
            if(match = "Exact")
            {
                if(Value = arg)
                    args.RemoveAt(i)
            }
            else
            {
                if instr(Value,arg)
                    args.RemoveAt(i)
            }
        }
    }

    setUserProfile(profileName:="Profile1",userDataDir:="") ; user data dir doesn't change often, use the default
	{
        if this.IncognitoMode
            return
        if !userDataDir
            userDataDir := A_AppData "\Mozilla\Firefox\"
        profileini := userDataDir "\Profiles.ini"
        if !fileExist( userDataDir "\Profiles\" profileName )
        {
            Prompt := "Warning: Following Profile is Directory does not exist`n"
            . chr(34) userDataDir "\Profiles\" profileName  chr(34) "`n"
            . "`n`nRufaydium is going to create profile directory Manually exitapp"
            . "`nPress OK to continue / Manually exitapp"
            msgbox Prompt,"Rufaydium Capabilities", 48
            DirCreate(userDataDir "\Profiles\" profileName)
            
            IniWrite "Profiles/" profileName , profileini, profileName, "Path"
            IniWrite profileName , profileini, profileName, "Name"
            IniWrite 1, profileini, profileName, "IsRelative"
        }

        Path := IniRead(profileini,"profilePath", "profileName")
        for i, argtbr in this.cap.capabilities.alwaysMatch[this.Options].args
        {
            if (argtbr = "-profile") or instr(argtbr,"\Mozilla\Firefox\Profiles\")
                this.cap.capabilities.alwaysMatch[this.Options].RemoveAt(i)
        }
        this.addArg("-profile")
        this.addArg(StrReplace(userDataDir "\Profiles\" profileName, "\", "/"))


	}

    Addextensions(crxlocation)
    {
        ; if !IsObject(this.cap.capabilities.alwaysMatch[this.Options].extensions)
        ;     this.cap.capabilities.alwaysMatch[this.Options].extensions := []
        ; crxlocation := StrReplace(crxlocation, "\", "/")
        ; this.cap.capabilities.alwaysMatch[this.Options].extensions.push(crxlocation)
    }
}



class EdgeCapabilities extends ChromeCapabilities
{
    setUserProfile(profileName:="Profile 1", userDataDir:=0) ; default profile is Sample profile
	{
        if this.IncognitoMode
            return
		if !userDataDir
			userDataDir := StrReplace(A_AppData, "\Roaming") "\Local\Microsoft\Edge\User Data"
        userDataDir := StrReplace(userDataDir, "\", "\\")
        ; removing previous args if any
        this.RemoveArg("--user-data-dir=","in")
        this.RemoveArg("--profile-directory=","in")
        ; adding new profile args
        this.addArg("--user-data-dir=" userDataDir)
        this.addArg("--profile-directory=" profileName)
        if !fileExist( userDataDir "\" profileName )
        {
            Prompt := "Warning: Following Profile is Directory does not exist`n"
            . chr(34) userDataDir "\" profileName  chr(34) "`n"
            . "`n`nRufaydium is going to create profile directory Manually exitapp"
            . "`nPress OK to continue / Manually exitapp"
            msgbox( Prompt, "Rufaydium Capabilities", 48)
            DirCreate(userDataDir "\" profileName)
        }
	}

    InPrivate
    {
        get => this.IncognitoMode
        set => 0 ;value ? this.IncognitoMode := true : this.IncognitoMode := false

    }

    IncognitoMode
    {
        get =>  this._incog
        set 
        {
            if value
            {
                this.olduser.push(this.RemoveArg("--user-data-dir=","in"))
                this.olduser.push(this.RemoveArg("--profile-directory=","in"))
                this.addArg("--InPrivate")
                this._incog := true
            }
            else
            {
                this._incog := false
                this.RemoveArg("--incognito")
                for i, arg in this.olduser
                    this.addArg(arg)
                this.olduser := {}
	        }	
        }

    }
}

class BraveCapabilities extends ChromeCapabilities
{
    setUserProfile(profileName:="Default", userDataDir:="")
	{
        if this.IncognitoMode
            return
		if !userDataDir
			userDataDir := StrReplace(A_AppData, "\Roaming") "\Local\BraveSoftware\Brave-Browser\User Data\"
        userDataDir := StrReplace(userDataDir, "\", "/")
        ; removing previous args if any
        this.RemoveArg("--user-data-dir=","in")
        this.RemoveArg("--profile-directory=","in")
        ; adding new profile args
        this.addArg("--user-data-dir=" userDataDir)
        this.addArg("--profile-directory=" profileName)
        if !fileExist( userDataDir "\" profileName )
        {
            Prompt := "Warning: Following Profile is Directory does not exist`n"
            . chr(34) userDataDir "\" profileName  chr(34) "`n"
            . "`n`nRufaydium is going to create profile directory Manually exitapp"
            . "`nPress OK to continue / Manually exitapp"
            msgbox( Prompt, "Rufaydium Capabilities", 48)
            DirCreate(userDataDir "\" profileName)
        }
	}
}


class OperaCapabilities extends ChromeCapabilities
{
        setUserProfile(profileName:="Opera stable", userDataDir:="") ; not sure is "Opera stable" is default profile
	{
        if this.IncognitoMode
            return
		if !userDataDir
			userDataDir := A_AppData "\opera software" ; not sure is (A_AppData "\opera software\Opera stable") is userDataDir
        userDataDir := StrReplace(userDataDir, "\", "/")
        ; removing previous args if any
        this.RemoveArg("--user-data-dir=","in")
        this.RemoveArg("--profile-directory=","in")
        ; adding new profile args
        this.addArg("--user-data-dir=" userDataDir)
        this.addArg("--profile-directory=" profileName)
        if !fileExist( userDataDir "\" profileName )
        {
            Prompt := "Warning: Following Profile is Directory does not exist`n"
            . chr(34) userDataDir "\" profileName  chr(34) "`n"
            . "`n`nRufaydium is going to create profile directory Manually exitapp"
            . "`nPress OK to continue / Manually exitapp"
            msgbox( Prompt, "Rufaydium Capabilities", 48)
            DirCreate(userDataDir "\" profileName)
        }
	}

}