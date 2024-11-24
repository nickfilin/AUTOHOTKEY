Class Actions
{
    Parameters(Pointer)  => this.Act["parameters"] := map("pointerType",Pointer)
    perform()            => this.Act
    Clear()              => this.Act["actions"] := []
    insert(i)            => this.Act["actions"].Push(i)
    Pause(duration:=100) => this.insert(map("type", "pause","duration",duration))
    cancel()             => this.insert(map("type","pointerCancel"))
}

Class Keyboard extends Actions
{
    __new()
    {
        this.Act := map()
        this.Act["actions"] := []
        this.Act["id"] := "keyboard"
        this.Act["type"] := "key"
    }

    SendKey(keys)
    {
        for n, k in StrSplit(keys)
        {
            this.keyDown(k)
            this.keyUp(k)
        }
    }

    keyUp(key)   => this.insert(map("type","keyUp",  "value",Key))
    keyDown(key) => this.insert(map("type","keyDown","value",Key))
}

Class Mouse extends Actions
{
    Static LButton := 0
	Static MButton := 1
	Static RButton := 2
    __new(pointerType:="mouse") ; pointerType should be "mouse", "pen", or "touch"
    {
        this.Act := map()
        this.Act["actions"] := []
        this.Act["id"]      := "mouse"
        this.Act["type"]    := "pointer"
        this.Parameters(pointerType) 
    }

    click(button:=0,x:=0,y:=0,duration:=500)
    {
        this.move(x,y,0)
        this.press(button,duration)
        this.Pause(500)
        this.release(button,duration)
    }

    Press(button:=0)    => this.insert(map("type","pointerDown","button",button))
    Release(button:=0)  => this.insert(map("type","pointerUp"  ,"button",button))

    Move(x:=0,y:=0,duration:=10,width:=0,height:=0,pressure:=0,tangentialPressure:=0,tiltX:=0,tiltY:= 0,twist:=0,altitudeAngle:=0,azimuthAngle:=0,origin:="viewport")
    {
        this.insert(
                    map(
                        "type", "pointerMove",
                        "duration", duration,
                        "x", x,
                        "y", y,
                        "origin", origin,
                        "width",width,
                        "height",height,
                        "pressure",pressure,
                        "tangentialPressure",tangentialPressure,
                        "tiltX",tiltX,
                        "tiltY",tiltY, 
                        "twist",twist,
                        "altitudeAngle",altitudeAngle,
                        "azimuthAngle",azimuthAngle
                        )
                    )
    }
}

Class Scroll extends Actions
{
    __new(pointerType:="mouse") ; pointerType should be "mouse", "pen", or "touch"
    {
        this.Act := map()
        this.Act["actions"] := []
        this.Act["id"] := "Scroll1"
        this.Act["type"] := "wheel"
    }

    ScrollUP(s:=50)    => this.Scroll(0,-(s))
    ScrollDown(s:=50)  => this.Scroll(0,s)
    ScrollLeft(s:=50)  => this.Scroll(-(s),0)
    ScrollRight(s:=50) => this.Scroll(s,0)

    Scroll( deltaX:=0, deltaY:=0, x:=0, y:=0, duration:=0,origin:="viewport") 
    {

        this.insert(        
            map(
            "type", "scroll",
            "duration", duration,
            "x", x, "y", y,
            "deltaX", deltaX,
            "deltaY", deltaY,
            "origin", origin
            )
        )    
    }
}