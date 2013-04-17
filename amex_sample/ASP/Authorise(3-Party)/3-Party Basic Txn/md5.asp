<%

' Version 3.1

' ---------------- Disclaimer --------------------------------------------------

' Copyright 2004 Dialect Solutions Holdings.  All rights reserved.

' This document is provided by Dialect Holdings on the basis that you will treat
' it as confidential.

' No part of this document may be reproduced or copied in any form by any means
' without the written permission of Dialect Holdings.  Unless otherwise
' expressly agreed in writing, the information contained in this document is
' subject to change without notice and Dialect Holdings assumes no
' responsibility for any alteration to, or any error or other deficiency, in
' this document.

' All intellectual property rights in the Document and in all extracts and
' things derived from any part of the Document are owned by Dialect and will be
' assigned to Dialect on their creation. You will protect all the intellectual
' property rights relating to the Document in a manner that is equal to the
' protection you provide your own intellectual property.  You will notify
' Dialect immediately, and in writing where you become aware of a breach of
' Dialect's intellectual property rights in relation to the Document.

' The names "Dialect", "QSI Payments" and all similar words are trademarks of
' Dialect Holdings and you must not use that name or any similar name.

' Dialect may at its sole discretion terminate the rights granted in this
' document with immediate effect by notifying you in writing and you will
' thereupon return (or destroy and certify that destruction to Dialect) all
' copies and extracts of the Document in its possession or control.

' Dialect does not warrant the accuracy or completeness of the Document or its
' content or its usefulness to you or your merchant customers.   To the extent
' permitted by law, all conditions and warranties implied by law (whether as to
' fitness for any particular purpose or otherwise) are excluded.  Where the
' exclusion is not effective, Dialect limits its liability to $100 or the
' resupply of the Document (at Dialect's option).

' Data used in examples and sample data files are intended to be fictional and
' any resemblance to real persons or companies is entirely coincidental.

' Dialect does not indemnify you or any third party in relation to the content
' or any use of the content as contemplated in these terms and conditions.

' Mention of any product not owned by Dialect does not constitute an endorsement
' of that product.

' This document is governed by the laws of New South Wales, Australia and is
' intended to be legally binding.

' ------------------------------------------------------------------------------

' Following is a copy of the disclaimer / license agreement provided by RSA:

' Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All rights
' reserved.

' License to copy and use this software is granted provided that it is 
' identified as the "RSA Data Security, Inc. MD5 Message-Digest Algorithm" in 
' all material mentioning or referencing this software or this function.

' License is also granted to make and use derivative works provided that such 
' works are identified as "derived from the RSA Data Security, Inc. MD5 
' Message-Digest Algorithm" in all material mentioning or referencing the 
' derived work.

' RSA Data Security, Inc. makes no representations concerning either the 
' merchantability of this software or the suitability of this software for any 
' particular purpose. It is provided "as is" without express or implied warranty 
' of any kind.

' These notices must be retained in any copies of any part of this documentation 
' and/or software.

' ------------------------------------------------------------------------------
 
'  @author Dialect Payment Solutions Pty Ltd Group 

'  ----------------------------------------------------------------------------

' tables used for left and right shifting.  Pre-compute to save time
Private MASK(31)
MASK(0)  = CLng(&H00000001&)
MASK(1)  = CLng(&H00000003&)
MASK(2)  = CLng(&H00000007&)
MASK(3)  = CLng(&H0000000F&)
MASK(4)  = CLng(&H0000001F&)
MASK(5)  = CLng(&H0000003F&)
MASK(6)  = CLng(&H0000007F&)
MASK(7)  = CLng(&H000000FF&)
MASK(8)  = CLng(&H000001FF&)
MASK(9)  = CLng(&H000003FF&)
MASK(10) = CLng(&H000007FF&)
MASK(11) = CLng(&H00000FFF&)
MASK(12) = CLng(&H00001FFF&)
MASK(13) = CLng(&H00003FFF&)
MASK(14) = CLng(&H00007FFF&)
MASK(15) = CLng(&H0000FFFF&)
MASK(16) = CLng(&H0001FFFF&)
MASK(17) = CLng(&H0003FFFF&)
MASK(18) = CLng(&H0007FFFF&)
MASK(19) = CLng(&H000FFFFF&)
MASK(20) = CLng(&H001FFFFF&)
MASK(21) = CLng(&H003FFFFF&)
MASK(22) = CLng(&H007FFFFF&)
MASK(23) = CLng(&H00FFFFFF&)
MASK(24) = CLng(&H01FFFFFF&)
MASK(25) = CLng(&H03FFFFFF&)
MASK(26) = CLng(&H07FFFFFF&)
MASK(27) = CLng(&H0FFFFFFF&)
MASK(28) = CLng(&H1FFFFFFF&)
MASK(29) = CLng(&H3FFFFFFF&)
MASK(30) = CLng(&H7FFFFFFF&)
MASK(31) = CLng(&HFFFFFFFF&)


' powers of 2
Private EXP2(31)
EXP2(0)  = CLng(&H00000001&)
EXP2(1)  = CLng(&H00000002&)
EXP2(2)  = CLng(&H00000004&)
EXP2(3)  = CLng(&H00000008&)
EXP2(4)  = CLng(&H00000010&)
EXP2(5)  = CLng(&H00000020&)
EXP2(6)  = CLng(&H00000040&)
EXP2(7)  = CLng(&H00000080&)
EXP2(8)  = CLng(&H00000100&)
EXP2(9)  = CLng(&H00000200&)
EXP2(10) = CLng(&H00000400&)
EXP2(11) = CLng(&H00000800&)
EXP2(12) = CLng(&H00001000&)
EXP2(13) = CLng(&H00002000&)
EXP2(14) = CLng(&H00004000&)
EXP2(15) = CLng(&H00008000&)
EXP2(16) = CLng(&H00010000&)
EXP2(17) = CLng(&H00020000&)
EXP2(18) = CLng(&H00040000&)
EXP2(19) = CLng(&H00080000&)
EXP2(20) = CLng(&H00100000&)
EXP2(21) = CLng(&H00200000&)
EXP2(22) = CLng(&H00400000&)
EXP2(23) = CLng(&H00800000&)
EXP2(24) = CLng(&H01000000&)
EXP2(25) = CLng(&H02000000&)
EXP2(26) = CLng(&H04000000&)
EXP2(27) = CLng(&H08000000&)
EXP2(28) = CLng(&H10000000&)
EXP2(29) = CLng(&H20000000&)
EXP2(30) = CLng(&H40000000&)
EXP2(31) = CLng(&H80000000&)

Private Const S11 = 7
Private Const S12 = 12
Private Const S13 = 17
Private Const S14 = 22
Private Const S21 = 5
Private Const S22 = 9
Private Const S23 = 14
Private Const S24 = 20
Private Const S31 = 4
Private Const S32 = 11
Private Const S33 = 16
Private Const S34 = 23
Private Const S41 = 6
Private Const S42 = 10
Private Const S43 = 15
Private Const S44 = 21

'F, G, H and I are basic MD5 functions.
Private Function F(x, y, z)
    F = (x And y) Or ((Not x) And z)
End Function

Private Function G(x, y, z)
    G = (x And z) Or (y And (Not z))
End Function

Private Function H(x, y, z)
    H = (x Xor y Xor z)
End Function

Private Function I(x, y, z)
    I = (y Xor (x Or (Not z)))
End Function

Private Function LeftShift(x, n)
    ' if bit 1 of result will be set, then have to take away most significant bit before
    ' multiplication and then add it back at end
    If (x And EXP2(31 - n)) Then
        LeftShift = ((x And MASK(30 - n)) * EXP2(n)) Or EXP2(31)
    Else
        LeftShift = ((x And MASK(31 - n)) * EXP2(n))
    End If
End Function

Private Function RightShift(x, n)
    ' if bit 1 is set, then we need to get rid of it, then add it at end
    If (x And EXP2(31)) Then
        RightShift = (((x And MASK(30)) \ EXP2(n)) Or EXP2(31 - n))
    Else
        RightShift = x \ EXP2(n)
    End If
End Function

Private Function RotateLeft(x, n)
    RotateLeft = LeftShift(x, n) Or RightShift(x, (32 - n))
End Function


Private Function AddUnsignedWord(x, y)
    Dim x30
    Dim y30
    Dim x31
    Dim y31
    Dim sum
 
    x31 = x And EXP2(31)
    y31 = y And EXP2(31)
    x30 = x And EXP2(30)
    y30 = y And EXP2(30)
 
    sum = (x And MASK(29)) + (y And MASK(29))
 
    If x30 And y30 Then
        sum = sum Xor EXP2(31) Xor x31 Xor y31
    ElseIf x30 Or y30 Then
        If sum And EXP2(30) Then
            sum = sum Xor EXP2(31) Xor EXP2(30) Xor x31 Xor y31
        Else
            sum = sum Xor EXP2(30) Xor x31 Xor y31
        End If
    Else
        sum = sum Xor x31 Xor y31
    End If
 
    AddUnsignedWord = sum
End Function


' FF, GG, HH, and II transformations for rounds 1, 2, 3, and 4.
' Rotation is separate from addition to prevent recomputation.
Private Sub FF(a, b, c, d, x, s, ac)
	a = AddUnsignedWord(a, AddUnsignedWord(F(b, c, d), AddUnsignedWord(x, ac)))
	a = RotateLeft(a, s)
	a = AddUnsignedWord(a, b)
End Sub

Private Sub GG(a, b, c, d, x, s, ac)
	a = AddUnsignedWord(a, AddUnsignedWord(G(b, c, d), AddUnsignedWord(x, ac)))
	a = RotateLeft(a, s)
	a = AddUnsignedWord(a, b)
End Sub

Private Sub HH(a, b, c, d, x, s, ac)
	a = AddUnsignedWord(a, AddUnsignedWord(H(b, c, d), AddUnsignedWord(x, ac)))
	a = RotateLeft(a, s)
	a = AddUnsignedWord(a, b)
End Sub

Private Sub II(a, b, c, d, x, s, ac)
	a = AddUnsignedWord(a, AddUnsignedWord(I(b, c, d), AddUnsignedWord(x, ac)))
	a = RotateLeft(a, s)
	a = AddUnsignedWord(a, b)
End Sub


Private Function GetPaddedInputAsWordArray(input)
    Dim inputLen
    Dim newLenInWords
    Dim paddedInput()
    Dim bytePos
    Dim byteCount
    Dim wordCount
    
    inputLen = Len(input)

    ' work out how many words will be in the padded input    
    newLenInWords = (((inputLen + 8) \ 64) + 1) * 16

    ReDim paddedInput(newLenInWords - 1)
    
    bytePos = 0
    byteCount = 0

    For byteCount = 0 to inputLen - 1
        wordCount = byteCount \ 4
        bytePos = (byteCount Mod 4) * 8
        paddedInput(wordCount) = paddedInput(wordCount) Or LeftShift(Asc(Mid(input, byteCount + 1, 1)), bytePos)
    Next

    wordCount = byteCount \ 4
    bytePos = (byteCount Mod 4) * 8

    ' add 1 bit then zeros
    paddedInput(wordCount) = paddedInput(wordCount) Or LeftShift(&H80, bytePos)

    ' put inputLen in revers order into last 2 words
    paddedInput(newLenInWords - 2) = LeftShift(inputLen, 3)
    paddedInput(newLenInWords - 1) = RightShift(inputLen, 29)
    
    GetPaddedInputAsWordArray = paddedInput
End Function


Private Function ReverseWordToHex(input)
    Dim i
    Dim b

    For i = 0 To 3
        b = RightShift(input, i * 8) And MASK(7)
        ReverseWordToHex = ReverseWordToHex & Right("0" & Hex(b), 2)
    Next
End Function


Public Function MD5(input)

    Dim x
    Dim k
    Dim a
    Dim b
    Dim c
    Dim d
    Dim olda
    Dim oldb
    Dim oldc
    Dim oldd
    
    x = GetPaddedInputAsWordArray(input)

    a = &H67452301
    b = &HEFCDAB89
    c = &H98BADCFE
    d = &H10325476

    ' do MD5Transform for every byte of input
    For k = 0 To UBound(x) Step 16
        olda = a
        oldb = b
        oldc = c
        oldd = d
    
        FF a, b, c, d, x(k +  0), S11, &HD76AA478
        FF d, a, b, c, x(k +  1), S12, &HE8C7B756
        FF c, d, a, b, x(k +  2), S13, &H242070DB
        FF b, c, d, a, x(k +  3), S14, &HC1BDCEEE
        FF a, b, c, d, x(k +  4), S11, &HF57C0FAF
        FF d, a, b, c, x(k +  5), S12, &H4787C62A
        FF c, d, a, b, x(k +  6), S13, &HA8304613
        FF b, c, d, a, x(k +  7), S14, &HFD469501
        FF a, b, c, d, x(k +  8), S11, &H698098D8
        FF d, a, b, c, x(k +  9), S12, &H8B44F7AF
        FF c, d, a, b, x(k + 10), S13, &HFFFF5BB1
        FF b, c, d, a, x(k + 11), S14, &H895CD7BE
        FF a, b, c, d, x(k + 12), S11, &H6B901122
        FF d, a, b, c, x(k + 13), S12, &HFD987193
        FF c, d, a, b, x(k + 14), S13, &HA679438E
        FF b, c, d, a, x(k + 15), S14, &H49B40821
    
        GG a, b, c, d, x(k +  1), S21, &HF61E2562
        GG d, a, b, c, x(k +  6), S22, &HC040B340
        GG c, d, a, b, x(k + 11), S23, &H265E5A51
        GG b, c, d, a, x(k +  0), S24, &HE9B6C7AA
        GG a, b, c, d, x(k +  5), S21, &HD62F105D
        GG d, a, b, c, x(k + 10), S22, &H2441453
        GG c, d, a, b, x(k + 15), S23, &HD8A1E681
        GG b, c, d, a, x(k +  4), S24, &HE7D3FBC8
        GG a, b, c, d, x(k +  9), S21, &H21E1CDE6
        GG d, a, b, c, x(k + 14), S22, &HC33707D6
        GG c, d, a, b, x(k +  3), S23, &HF4D50D87
        GG b, c, d, a, x(k +  8), S24, &H455A14ED
        GG a, b, c, d, x(k + 13), S21, &HA9E3E905
        GG d, a, b, c, x(k +  2), S22, &HFCEFA3F8
        GG c, d, a, b, x(k +  7), S23, &H676F02D9
        GG b, c, d, a, x(k + 12), S24, &H8D2A4C8A
            
        HH a, b, c, d, x(k +  5), S31, &HFFFA3942
        HH d, a, b, c, x(k +  8), S32, &H8771F681
        HH c, d, a, b, x(k + 11), S33, &H6D9D6122
        HH b, c, d, a, x(k + 14), S34, &HFDE5380C
        HH a, b, c, d, x(k +  1), S31, &HA4BEEA44
        HH d, a, b, c, x(k +  4), S32, &H4BDECFA9
        HH c, d, a, b, x(k +  7), S33, &HF6BB4B60
        HH b, c, d, a, x(k + 10), S34, &HBEBFBC70
        HH a, b, c, d, x(k + 13), S31, &H289B7EC6
        HH d, a, b, c, x(k +  0), S32, &HEAA127FA
        HH c, d, a, b, x(k +  3), S33, &HD4EF3085
        HH b, c, d, a, x(k +  6), S34, &H4881D05
        HH a, b, c, d, x(k +  9), S31, &HD9D4D039
        HH d, a, b, c, x(k + 12), S32, &HE6DB99E5
        HH c, d, a, b, x(k + 15), S33, &H1FA27CF8
        HH b, c, d, a, x(k +  2), S34, &HC4AC5665
    
        II a, b, c, d, x(k +  0), S41, &HF4292244
        II d, a, b, c, x(k +  7), S42, &H432AFF97
        II c, d, a, b, x(k + 14), S43, &HAB9423A7
        II b, c, d, a, x(k +  5), S44, &HFC93A039
        II a, b, c, d, x(k + 12), S41, &H655B59C3
        II d, a, b, c, x(k +  3), S42, &H8F0CCC92
        II c, d, a, b, x(k + 10), S43, &HFFEFF47D
        II b, c, d, a, x(k +  1), S44, &H85845DD1
        II a, b, c, d, x(k +  8), S41, &H6FA87E4F
        II d, a, b, c, x(k + 15), S42, &HFE2CE6E0
        II c, d, a, b, x(k +  6), S43, &HA3014314
        II b, c, d, a, x(k + 13), S44, &H4E0811A1
        II a, b, c, d, x(k +  4), S41, &HF7537E82
        II d, a, b, c, x(k + 11), S42, &HBD3AF235
        II c, d, a, b, x(k +  2), S43, &H2AD7D2BB
        II b, c, d, a, x(k +  9), S44, &HEB86D391
    
        a = AddUnsignedWord(a, olda)
        b = AddUnsignedWord(b, oldb)
        c = AddUnsignedWord(c, oldc)
        d = AddUnsignedWord(d, oldd)
    Next
    
    MD5 = UCase(ReverseWordToHex(a) & ReverseWordToHex(b) & ReverseWordToHex(c) & ReverseWordToHex(d))

End Function

%>