Class RunDriver
{
    static visibility := "unknown until change"
    __New(Driver,Port)
    {
		SplitPath A_LineFile ,,&DIR
		if A_IsCompiled
			This.Dir := NormalizePath(A_ScriptDir "\Bin")
		else
			This.Dir := NormalizePath(DIR "\..\Bin")

        This.Driver := Driver
		This.Port := Port
		This.url := "http://127.0.0.1:" Port
        This.Target :=  this.Dir "\" This.Driver ; " '--port=" This.Port "'"

		if !FileExist(This.Target)
		{
			if Port = 9520
			{
				throw "unabel to find " This.Target ",`nPlace Custom driver executable into the Bin folder`nRufaydium Supports AutoDownload for following WebDrivers:`nChromedriver.exe`nMsedgedriver.exe`ngeckodriver.exe`noperadriver.exe"
			}

			if Msgbox("Rufaydium unable to locate " this.Driver " at " this.Target " Pres Yes to download " this.Driver
						, "Rufaydium:" this.Driver "not Found","y/n Icon!" ) = "Yes"
			{
				this.GetDriver()
			}
			else
				Throw "Rufaydium needs " this.driver "to work"
		}
        PID := this.GetDriverbyPort(this.Port)
		if PID
		{
			this.PID := PID
			Notify.Show("Accessed running " This.Driver)
            return this
		}
        this.Launch()
        this.visibility := 0

		NormalizePath(path) {
			cc := DllCall("GetFullPathName", "str", path, "uint", 0, "ptr", 0, "ptr", 0, "uint")
			buf := Buffer(cc*2)
			DllCall("GetFullPathName", "str", path, "uint", cc, "ptr", buf, "ptr", 0)
			return StrGet(buf)
		}
    }

    exit()
	{
		ProcessClose(this.PID)
		Notify.show(This.Driver " closed")
	}  
	exist() => ProcessExist(this.pid)
    Delete()
    {
        ProcessClose this.PID
        FileDelete this.Target
    }

    Launch()
    {
        Run this.Target " --port=" This.Port "" ,, "Hide", &PID
        ProcessWait(PID)
        this.PID := PID
		Notify.show(This.Driver " Started!")
    }

    visible
	{
		get => this.visibility

		set
		{
			if(value = 1) ;and !this.visible
			{
				WinShow "ahk_pid " this.pid
                this.visibility := 1
			}
			else
			{
				WinHide "ahk_pid " this.pid
                this.visibility := 0
			}
		}
	}

    GetDriverbyPort(Port)
	{
		for process in ComObjGet("winmgmts:").ExecQuery("SELECT * FROM Win32_Process WHERE Name = '" this.Driver "'")
		{
			RegExMatch(process.CommandLine, "(--port)=(\d+)",&p)
			if (Port != p[2])
			 	continue
			else
				return Process.processId
		}
	}

	GetDriver(Version:="STABLE",bit:="32")
	{
		switch this.Driver
		{
			case "chromedriver.exe" :
				; this.zip := "chromedriver_win32.zip"
				; if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",&BrowserVersion)
				; 	uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_"  BrowserVersion[2]
				; else
				; 	uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE" ;, BrowserVersion[1] := "unknown"
				; this.DriverVersion := this.GetVersion(uri)
				; this.DriverUrl := "https://chromedriver.storage.googleapis.com/" this.DriverVersion "/" this.zip
				this.zip := "chromedriver-win32.zip"
				if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",&BrowserVersion)
				{
					uri := "https://googlechromelabs.github.io/chrome-for-testing/known-good-versions-with-downloads.json"
					for k, obj in json.parse(this.GetVersion(uri))["versions"]
					{
						if instr(obj["version"],BrowserVersion[2])
						{
							for i, download in obj["downloads"]["chromedriver"]
							{
								if download["platform"] = "win32"
								{
									this.DriverUrl := download["url"]
									this.DriverVersion := obj['version']
									break
								}
							}
							break
						}
					}
				}
				else
				{
					uri := "https://googlechromelabs.github.io/chrome-for-testing/last-known-good-versions.json"
					this.DriverVersion := json.parse(this.GetVersion(uri))["channels"]["Stable"]["version"]
					this.DriverUrl := "https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/" this.DriverVersion "/win32/chromedriver-win32.zip"
				}


			case "BraveDriver.exe" :
				this.zip := "chromedriver_win32.zip"
				if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",&BrowserVersion) ; iam clueless for response when loading another binary which does not matches chrome driver
					uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_"  BrowserVersion[2]
				else
					uri := "https://chromedriver.storage.googleapis.com/LATEST_RELEASE", BrowserVersion[1] := "unknown"
				this.DriverVersion := this.GetVersion(uri)
				this.DriverUrl := "https://chromedriver.storage.googleapis.com/" this.DriverVersion "/" this.zip
			case "msedgedriver.exe" :
				if A_Is64bitOS
					this.zip := "edgedriver_win64.zip"
				else
					this.zip := "edgedriver_win32.zip"
				if RegExMatch(Version,"version ([\d.]+).*\n.*browser version is (\d+)",&BrowserVersion)
					uri := "https://msedgedriver.azureedge.net/LATEST_" "RELEASE_" BrowserVersion[2]
				else if(Version != "STABLE")
					uri := "https://msedgedriver.azureedge.net/LATEST_RELEASE_" Version
				else
					uri := "https://msedgedriver.azureedge.net/LATEST_" Version ;, BrowserVersion[1] := "unknown"
				this.DriverVersion := this.GetVersion(uri) ; Thanks RaptorX fixing Issues GetEdgeDrive
				this.DriverUrl := "https://msedgedriver.azureedge.net/" this.DriverVersion "/" this.zip
			case "geckodriver.exe" :
				; haven't received any error msg from previous driver tell about driver version
				; therefor unable to figure out which driver to version to download as v0.028 support latest Firefox
				; this will be uri in case driver suggest version for firefox
				; uri := "https://api.github.com/repos/mozilla/geckodriver/releases/tags/v0.31.0"
				; till that just delete geckodriver.exe if you thing its old Rufaydium will download latest
				uri := "https://api.github.com/repos/mozilla/geckodriver/releases/latest"
				for i, asset in json.parse(this.GetVersion(uri))["assets"]
				{
					if instr(asset["name"],"win64.zip") and A_Is64bitOS
					{
						this.DriverUrl := asset["browser_download_url"]
						this.zip := asset["name"]
					}
					else if instr(asset["name"],"win32.zip")
					{
						this.DriverUrl := asset["browser_download_url"]
						this.zip := asset["name"]
					}
				}
				this.DriverVersion := Version
			case "operadriver.exe" :
				if RegExMatch(Version,"Chrome version ([\d.]+).*\n.*browser version is (\d+.\d+.\d+)",&BrowserVersion)
				{
					uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases"
					for i, asset in json.parse(this.GetVersion(uri))["assets"]
					{
						if instr(asset["name"],BrowserVersion[1])
						{
							uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases/tags/" asset["tag_name"]
						}
					}
				}
				else
					uri := "https://api.github.com/repos/operasoftware/operachromiumdriver/releases/latest" ;, ;BrowserVersion[1] := "unknown"

				for i, asset in json.parse(this.GetVersion(uri))["assets"]
				{
					if instr(asset["name"],"win64.zip") and A_Is64bitOS
					{
						this.DriverUrl := asset["browser_download_url"]
						this.zip := asset["name"]
					}
					else if instr(asset["name"],"win32.zip")
					{
						this.DriverUrl := asset["browser_download_url"]
						this.zip := asset["name"]
					}
				}
				this.DriverVersion := Version
		}

		if InStr(this.DriverVersion, "NoSuchKey"){
			throw "Driver Version not found"
		}
		ProcessClose this.GetDriverbyPort(this.Port)
		if FileExist(this.target)
			filedelete this.target
		this.zip := this.dir "\" this.zip
		return this.DownloadnExtract()
	}

	GetVersion(uri)
	{
		if(this.Driver = "msedgedriver.exe")
		{
			WebRequest := ComObject("WinHttp.WinHttpRequest.5.1")
			WebRequest.Open("GET", uri, false)
			WebRequest.Send()
			
			for char in WebRequest.Responsebody
				text .= Chr(char)

			return txt := RegExReplace(text, '[^\d.]+')
		}
		WebRequest := ComObject("Msxml2.XMLHTTP")
		WebRequest.open("GET", uri, False)
		WebRequest.SetRequestHeader("Content-Type","application/json")
		WebRequest.Send()
		return WebRequest.responseText
	}

	DownloadnExtract()
	{
		Notify.show("Downloading " this.zip )
		DirCreate this.Dir
		Download this.DriverUrl,  this.zip
		Notify.show("Extracting: " this.zip "`n" this.Dir "\" This.Driver )
		AppObj := ComObject("Shell.Application")
		FolderObj := AppObj.NameSpace(this.zip)
		FileObj := FolderObj.ParseName(this.Driver)
		if !isobject(FileObj)
			For Item in FolderObj.Items
			{
				FileObj := FolderObj.ParseName(Item.Name "\" this.Driver)
				if isobject(FileObj)
					break
			}
		AppObj.Namespace(this.Dir "\").CopyHere(FileObj, 4|16)
		FileDelete this.zip
			return this.Dir "\" this.Driver
	}
}