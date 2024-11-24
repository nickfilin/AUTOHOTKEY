; Base64 Class
; Based on jNizM Work
; https://github.com/jNizM/ahk-scripts-v2/blob/main/src/Strings/StringToBase64.ahk
; https://github.com/jNizM/ahk-scripts-v2/blob/main/src/Strings/Base64ToString.ahk

;MsgBox Base64.Decode("VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==")   ; => The quick brown fox jumps over the lazy dog
;MsgBox Base64.Encode("The quick brown fox jumps over the lazy dog")   ; => VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==
Class Base64
{
    Static Encode(String, Encoding := "UTF-8")
    {
        static CRYPT_STRING_BASE64 := 0x00000001
        static CRYPT_STRING_NOCRLF := 0x40000000

        Binary := Buffer(StrPut(String, Encoding))
        StrPut(String, Binary, Encoding)
        if !(DllCall("crypt32\CryptBinaryToStringW", "Ptr", Binary, "UInt", Binary.Size - 1, "UInt", (CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF), "Ptr", 0, "UInt*", &Size := 0))
            throw OSError()

        Base64 := Buffer(Size << 1, 0)
        if !(DllCall("crypt32\CryptBinaryToStringW", "Ptr", Binary, "UInt", Binary.Size - 1, "UInt", (CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF), "Ptr", Base64, "UInt*", Size))
            throw OSError()

        return StrGet(Base64)
    }


    Static Decode(Base64, Encoding := 'UTF-8')
    {
        static CRYPT_STRING_BASE64 := 0x00000001
        if !(DllCall("crypt32\CryptStringToBinaryW", "Str", Base64, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", 0, "UInt*", &Size := 0, "Ptr", 0, "Ptr", 0))
            throw OSError()

        Decoded := Buffer(Size)
        if !(DllCall("crypt32\CryptStringToBinaryW", "Str", Base64, "UInt", 0, "UInt", CRYPT_STRING_BASE64, "Ptr", Decoded, "UInt*", Size, "Ptr", 0, "Ptr", 0))
            throw OSError()
        return Encoding = 'RAW' ? Decoded : StrGet(Decoded, "UTF-8")
    }
}
