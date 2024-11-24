#Requires AutoHotkey v2.0
; cJson beta for v2 by geek. Please consider donating at https://ko-fi.com/g33kd

class JSON
{
	static version := "1.6.0-git-dev"

	static BoolsAsInts {
		get => this.lib.bBoolsAsInts
		set => this.lib.bBoolsAsInts := value
	}

	static NullsAsStrings {
		get => this.lib.bNullsAsStrings
		set => this.lib.bNullsAsStrings := value
	}

	static EscapeUnicode {
		get => this.lib.bEscapeUnicode
		set => this.lib.bEscapeUnicode := value
	}

	static fnCastString := Format.Bind('{}')

	static __New() {
		this.lib := this._LoadLib()

		; Populate globals
		this.lib.objTrue := ObjPtr(this.True)
		this.lib.objFalse := ObjPtr(this.False)
		this.lib.objNull := ObjPtr(this.Null)

		this.lib.fnGetMap := ObjPtr(Map)
		this.lib.fnGetArray := ObjPtr(Array)

		this.lib.fnCastString := ObjPtr(this.fnCastString)
	}

	static _LoadLib() {
		return this.MyC
		; ; MCL.CompilerSuffix .= " -O3" ; Gotta go fast
		; A_Clipboard := MCL.StandaloneAHKFromC('#include "dumps.c"`n#include "loads.c"')
		; ExitApp
		; return MCL.FromC('#include "dumps.c"`n#include "loads.c"')
	}

	static Stringify(obj, pretty := 0)
	{
		if !IsObject(obj)
			throw Error("Input must be object")
		size := 0
		this.lib.dumps(ObjPtr(obj), 0, &size, !!pretty, 0)
		buf := Buffer(size*5 + 2, 0)
		bufbuf := Buffer(A_PtrSize)
		NumPut("Ptr", buf.Ptr, bufbuf)
		this.lib.dumps(ObjPtr(obj), bufbuf, &size, !!pretty, 0)
		return StrGet(buf, "UTF-16")
	}

	static Parse(json) {
		_json := " " json ; Prefix with a space to provide room for BSTR prefixes
		pJson := Buffer(A_PtrSize)
		NumPut("Ptr", StrPtr(_json), pJson)

		pResult := Buffer(24)

		if r := this.lib.loads(pJson, pResult)
		{
			throw Error("Failed to parse JSON (" r ")", -1
			, Format("Unexpected character at position {}: '{}'"
			, (NumGet(pJson, 'UPtr') - StrPtr(_json)) // 2, Chr(NumGet(NumGet(pJson, 'UPtr'), 'Short'))))
		}

		result := ComValue(0x400C, pResult.Ptr)[] ; VT_BYREF | VT_VARIANT
		if IsObject(result)
			ObjRelease(ObjPtr(result))
		return result
	}

	static True {
		get {
			static _ := {value: true, name: 'true'}
			return _
		}
	}

	static False {
		get {
			static _ := {value: false, name: 'false'}
			return _
		}
	}

	static Null {
		get {
			static _ := {value: '', name: 'null'}
			return _
		}
	}

	
class MyC {
	static code := Buffer(6960), exports := [5344, 5360, 5376, 0, 5392, 5408, 5424, 3296, 5440, 5456, 5472], codeB64 := ""
. "a7gAQVdBVkFVQVQAVVdWU0iB7GgAAgAASI0FiBYBADCJ00SJTCRcQEiJzUSKbAEchAgkkAAAXIsBTIlAxkiNlCSMATSJQFQkKEG5AQEUjYAVHhUA"
. "AEyNA04Qx0QkIAAMAP9QBCiLA1aD+v91LgUASj4AumYPvgKEIMAPhGIEADiF2wB0D0iLC0yNQQACTIkDZokB6wAC/wZI/8Lr2SBFMeS5BgA6RTEA"
. "yUUxwESJ4EgQjbwkmAAQTI20hCSwAXTHhCTAAWbZAADzqwIrAL/uAIcBKaLIAqGEJKACFoQCOQcBDwE5AEzzq0iLRbUADIwCFGYAJQEQCAARQEwk"
. "MEiJ6QEh4L0EMrgEMoQ3AngAcUCBCQUBBDgBBEyJdCQo4wF8AQ//UDCAMQVfgDVYjQVggEsECMCBQ+j3hEsCMgA2+ItPAbIBCYRTuwBIgLYwBjsE"
. "qwEcEAA474FfASSAX6RHhIIbCSSCVA3AEyjABQALTI0dtQ4UyR8AJIEGTImcJP4YwAHCI4QhgR+BE4Mf20UlwBVdwBVmg4NoA3XKCkAC0EEKdV4B"
. "BQE9MwMFAlp1TgEFAR4DdUoQQAIwAQVBvMCqAKR1OQCU7RMHlBFBsOEalOsGQbwBEEA8QDpCQEVAQYP8AgM6TFuEBcGYGIATQbQAgRWLEEAoD4WB"
. "SEyJREQkKMBDTYnwgB8o3hJERMAIg8LGvtAAR4EOdYW+Q0gqZwFQVyqDJzDvAA8DvwIpQW2MAgVCZBBaSnxBrkxHW+nFgnQ9Vv8AKYFv6IJt6YTs"
. "iZNAWCEcifcCeTHSgDi/IQQiXYYYhA+jRiJmlGMQ3aAFQKEwxD8BIANBSWABLiBgAUEDYQQ4ZARMib604gbEBnVoQBhhDwPFi89gKKQWQEeAKP4R"
. "Q0dhNEgJdFvjKXQbdyndBYUmSeA1idpIiawZogHoT6AxoAYPhLACBwEqA0iNUAJIAIkTZscAIgDpFp5hAkAKGwBDAUiLIBMZwIPgIHJKAgCDwHtI"
. "iQtmiUICwQuAfCRcIZ+uUWASD4WpxkpYYBMxYO1FD7b1QidBSrhjQALhN7wkcGVOwwGIXcsBoMsBwQbGAYQCC0jdwE9wgQEBCYEBeIEBIjIVgAFg"
. "gQHQJANo6bc7wSjgGB1KI8Ai4yZ144jpSv8AAAbr7GEqFaENAwAZBWBWvCTAEUE0D4SboAGF7Q/EhIQjVg+EUQEB6SUSLGEgqhBgRITtDwSFTsAD"
. "QY1EJP9Ag/gBD4aSoAGLUWMVZoP4gAsBIDtI8GOEJHihCCAzwUaBjxPhACM06LXAKf/FSEKLQRuLfCRoQ2BI0IuMJEgBK9KhTeEk9AxAAQeowhGg"
. "l6SgASrgDEAPKIxiBCEEwU11oQlwwVHgBFwi2kQHmJHgAA8QlEIHDylEbNXgA1gEB2ABB9gIBwIs3IsBxAkiXQBXKPhZYikwEZQkSIAFAFmJxwKF"
. "gICI/v//SJiE6TMgLP8G6behAaVgNRp1NesuADXvgSykhJtgBesfoQUwtQUY/8c7wKrADQ+PbQEhC40VCg8AAOs64GAI2WAeQUkhMnUlXVEEEQww"
. "wjNQGmBQAumC1hE+g/gUdUivAm+kAoAcoQIEHPSABqIizUsig6s1wtOCfw5CBQk8dS0vPC88AAvxBetOxZADTpMDCHUqISFoB7ItICjrYS8UKRQE"
. "IRR4SA+/tDQEKKVBYyjo7jTzC68O0QMvkQGgB5gBIjqSL4QU/WEWUASBQgFAAiAA6QIQASSLBnAC/8ARAkXCgIkG6e78///SFGYN0QdhMOkEYAKx"
. "EA8GhQMTYwFIOw27C6myEmsNsG4npWPhAARXvxKmY2ADZGMDOWoDqqtvA2wDPWMDCGoDc28DR2kDgBkxJkWJ8TMU/wLAcEcg6KL1///E6TiTDgh1"
. "GCUNhBoShBAc6RqBBY0Vn8IM0hwFD4Xx9lMRNXF4b/IPEPVCxGCANyjjZGVBaQ1DCqOUgQMxQD1xAAVmReECEWmSOYsB/3OUoASjR5VvAQVPabVw"
. "kQHA8g8RhCQIAzzxSAiUJPBBNIsUAmZAhdIPhEn7nxKJghGSEoPAAuvPjym3jykUIXQSrLARUQMUPTRk3vpBW+nXYACnPAkMdRAFMVAO/1AQ64oU"
. "0hcOVQH/FXtwEh/XWAQDkhUOA1EB/xVKL4EVhFczAjVvupABdTXV0QlzP3J9NHJaPw85DzYjMg8gAiwvAkxMfZUlMAdJMAfr5EAD3f8SBgAYgcQR"
. "y1teXwBdQVxBXUFeQThfw5AKAJbNYZtJuIQAJhMeZscCFIAfAMtIidZIx0IIAWMhE2aLCmaD+RAgD4f7Mq7ASNMA6KgBdAlIg8IJcRfr3cABWw+F"
. "u78RaEAqYGnzxuABIijQEYMsiRNgK6ElgFO1vRMEAIAoJ1QkaEjBxOUJNCdMjaQzyQ8nWceySIsgghJTVFDYjVgFgQl0fjOcTIB2YKhIiwcQA1zD"
. "afkVLSMX2NAjZosIwQ13FABIiepI0+qA4kWSDcCQDQPr4JABXQgPhLyREYXJD4QCs3IE8kiJ2ei7U4BjgGqFk+IfBzM5TNSJZPGvtMILi2EJQAf9"
. "ADSoRNKxADHXBNNhAX81BYUAMPwOZoM+CXWgHkiLTggkKRIXCyYdFAv3DHbiUAAsD0yEMeAwIByDyPBGOjBdD4XyEHWEG2bHhAYJ4Ax+COkCQAEh"
. "4AIiD4UXgu5CAoMgAsBaA0iJRghgAhAIAOnkkm75ew/chQ6QD38ecB74oQV9HnK/fx7B538efx54Hqxjcx62DQ+GWODxkAB9WA+E7ZEAsRnkIwEi"
. "mA+EVpAA8A7pB1ENgIXJdPNMjUDyM0CD+VwPhQ2CSUgCArECdSZmx0L+GiIgDMDSDnERiwNMAI1C/hu3AGaLCGaD+SJ1QL/p5gAAAACgXAB1CGbH"
. "Qv5cABTr0gBoLwNoLwDrCsQANGIDNAgA67aFADRmAzQMAOuoABpCbgMaCgDrmgAaciEDGg0A64wAGnR1AgsBGgkA6Xv//0L/ACB1D4VDABJIQIPA"
. "BEG5BAB4SAyJAwEhAIGLQv5MAIsDweAEZolCAP5mQYsIRI1RANBmQYP6CXcFoEQB0OskAA+/AQ8ABXcGjUQIyesKEwAQnwIQD4fu/gT//wAUqUmD"
. "wAIBAT9MiQNB/8l1CKrpCgF3iUr+6QIBAXaLVghMicEBAH0CSCnRiUr8CGZBx4NB6eECAAAAjUHQZoP4CRBBD5bAAFUtD5QAwEEIwA+EuAFBgE7H"
. "BhQAugAEABBIx0YIAAMASIuAA2aDOC11C4ImWIPK/4AigQmLgKX4CDB1DoYTgwMC6xA2g+gxAAsID4cCRQBUSIsLSA+/EAFEjUiBb/kJdwAXTGtO"
. "CApIg4DBAkiJC0mNgHZASIlGCOvXgzEuhHQUAiwIg+HfgEsgRXRW6fACLMACBEG5AkmJA/JIDwQqRoC8BgUA8g8IEUYIADFmiwGDBOgwAWh3wEVr"
. "yYQKmIEv8g8qwIAxAPJBDyrJ8g9eQMHyD1hGCEIM6wbMAjKAY4M+FHUQhw8UQSCBRXQJRTHBR5grdQdEDMAGMckAPgGEGw+HYP3//0xVQCBBhyAP"
. "QCBJACCYAEyJCwHB6+FFBDHJwVUARDnJdAAIa8AKQf/B6wLzQCfI8g8QRgggRYTAdAbBJ+sEmPIPWUApQCCLDgAdAhQAVg+vVghIiTBWCOktABCC"
. "IgUPbIX8wAKAD8KACwQ06QbpwW3BoFNIjQ0kIQCbZg++AQAWGEgAixNI/8FmOwJQD4W2/AGjwkAxEyDr4IA9xoEkdBJNgD0DAnqBA+nGwcfHJAYJ"
. "gHwNJoCJ6auRA8xmdU0AFtADEhZqXQsWbQIWDwYWQYbrSnBFFbBAB+tYwdIPRIUkAQ6NDX+TFQaFixU2wytIiwWtACatgBMIAIPAchZFFmYACAhI"
. "iU6AbwH/UAgQMcDp1MKL+kjTAOqA4gEPhJn7E4JxoTjpfWABTIniAEiJ2ei/+P//YIXAD4WXwQMlPyCUdxgoB3wnB+vcoAPQOg+FaUYC8oAIAAMU"
. "6HfkCE/iCJQkoAGgD0mJ8EiJ6egmzAAWRwt2K6AALA9EhHCidBODyICFOhh9dSlkHcMZiW4ITOk5AQSlEHTUJRC1EEiBxLCAC1teX4BdQVzDkJCQ"
. "ISP/CQD9AR8AHwAfAB8AHwAfAD8fAB8AHwAfAB8ABwAwMQAyMzQ1Njc4OUBBQkNERUagQwAAYQBzAE0AZQCAdABoAG8AZKAEACJVbmtub3duAF9P"
. "YmplY3RfoAAAUAB1oARoYAMCUyIFAABPAHcAKm7gAnJgBnBgAwAAil8gAEVgAnUAbaABwA0KAAkAIgUIJgoAVHlwZV8AdHIAdWUAZmFsc2UgAG51"
. "bGzHA1ZhHGx14APoDQsAU0iBBuzBW0SyiwFMicMgSImUJLihAY1UICRUTI2EgwGJVAAkKDHSSImMJGEhVsdEJFThB+AAIOHhAP9QKIsgqoMDoKQ1"
. "YQdYIK5IAASiDmaJQEQkcEiLQ4CzhAwkiAACYX5EJHhIFovkCwAFYCLPiYQk7pCiDwEGQARYoBKhCCBvW6YQ8ABAwgKAADiFADCTBQkRev9QEFw7"
. "CYBuZItLc0QQkNA2sQ5bA4E2BABXVlNIg+yQMEG7E4ABuwozEFBIhcBmcAQuUT/SAEyNTCQGeTRBFLsUwAG/MQZImYkE/kSQQvf7KdZmAEOJdFn+"
. "Sf/LATADdeaD6QJIYwLBsANEBi0A6xhESJljAoPCMHACFAJZZALoSGPJSAEIyUwB0GcBZoXAAHQdTYXSdA9JAIsSTI1KAk2JYApmiQLrgICwcsGI"
. "AuvbQBSDxDAgQiNhC9EKIEiJcATSdIARSIsCSI1IkEQACmbHACIA6ymJMAPrJIBrInUxAQJqJgMCBNABXKATUAJAxAIiUAXDAmYgTJAICNTpUmAf"
. "QYMAAkTr6WADXHUcYQPvtW8DAvCVx6GAEwLNHwKgAmIA66UQAgwTAoKrHwICZgDrgxACKAp1HxECiR8CAm4IAOleEpf4DXUjMUACD4RgklWOAnIA"
. "1Ok1gwIJhAI3jwKBAhB0AOkMkAGAPbIA+v//AHQLjUgC4CBbXncR6zyNREiBoAAhdgZQBB8Udy0xCRcfBAJ1AATrBBESD7cL6E4dgXW8sZDAAvBr"
. "CkyNiEkCTAEbAemlYAE58BfpneQB3hkTHcQgBeknkOAcGDHATI0MHbNhbKAmCEmJyghmwekgB+IPZkcAD74UE2ZFiRQIQUj/UCD4BHXhKrgQdgDx"
. "BRXgB2ZFQIsUQUyNWTAIGhBmRIkRNAboAXMC3VIjGMM="
	static __New() {
		if (64 != A_PtrSize * 8)
			throw Error("$Name does not support " (A_PtrSize * 8) " bit AHK, please run using 64 bit AHK")
		; MCL standalone loader https://github.com/G33kDude/MCLib.ahk
		; Copyright (c) 2023 G33kDude, CloakerSmoker (CC-BY-4.0)
		; https://creativecommons.org/licenses/by/4.0/
		if !DllCall("Crypt32\CryptStringToBinary", "Str", this.codeB64, "UInt", 0, "UInt", 1, "Ptr", buf := Buffer(3980), "UInt*", buf.Size, "Ptr", 0, "Ptr", 0, "UInt")
			throw Error("Failed to convert MCL b64 to binary")
		if (r := DllCall("ntdll\RtlDecompressBuffer", "UShort", 0x102, "Ptr", this.code, "UInt", 6960, "Ptr", buf, "UInt", buf.Size, "UInt*", &DecompressedSize := 0, "UInt"))
			throw Error("Error calling RtlDecompressBuffer",, Format("0x{:08x}", r))
		for import, offset in Map(['OleAut32', 'SysFreeString'], 5744) {
			if !(hDll := DllCall("GetModuleHandle", "Str", import[1], "Ptr"))
				throw Error("Could not load dll " import[1] ": " OsError().Message)
			if !(pFunction := DllCall("GetProcAddress", "Ptr", hDll, "AStr", import[2], "Ptr"))
				throw Error("Could not find function " import[2] " from " import[1] ".dll: " OsError().Message)
			NumPut("Ptr", pFunction, this.code, offset)
		}
		if !DllCall("VirtualProtect", "Ptr", this.code, "Ptr", this.code.Size, "UInt", 0x40, "UInt*", &old := 0, "UInt")
			throw Error("Failed to mark MCL memory as executable")
	}
	static bBoolsAsInts {
		get => NumGet(this.code.Ptr + 5344, "Int")
		set => NumPut("Int", value, this.code.Ptr + 5344)
	}
	static bEscapeUnicode {
		get => NumGet(this.code.Ptr + 5360, "Int")
		set => NumPut("Int", value, this.code.Ptr + 5360)
	}
	static bNullsAsStrings {
		get => NumGet(this.code.Ptr + 5376, "Int")
		set => NumPut("Int", value, this.code.Ptr + 5376)
	}
	static dumps(pObjIn, ppszString, pcchString, bPretty, iLevel) =>
		DllCall(this.code.Ptr + 0, "Ptr", pObjIn, "Ptr", ppszString, "IntP", pcchString, "Int", bPretty, "Int", iLevel, "CDecl Ptr")
	static fnCastString {
		get => NumGet(this.code.Ptr + 5392, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5392)
	}
	static fnGetArray {
		get => NumGet(this.code.Ptr + 5408, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5408)
	}
	static fnGetMap {
		get => NumGet(this.code.Ptr + 5424, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5424)
	}
	static loads(ppJson, pResult) =>
		DllCall(this.code.Ptr + 3296, "Ptr", ppJson, "Ptr", pResult, "CDecl Int")
	static objFalse {
		get => NumGet(this.code.Ptr + 5440, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5440)
	}
	static objNull {
		get => NumGet(this.code.Ptr + 5456, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5456)
	}
	static objTrue {
		get => NumGet(this.code.Ptr + 5472, "Ptr")
		set => NumPut("Ptr", value, this.code.Ptr + 5472)
	}
}

}

; #Include %A_LineFile%\..\Lib\MCL.ahk\MCL.ahk