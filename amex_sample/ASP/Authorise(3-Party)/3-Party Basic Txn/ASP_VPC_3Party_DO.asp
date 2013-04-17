<%@ LANGUAGE=vbscript %>
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
 
'  This program assumes that a URL has been sent to this example with the
'  required fields. The example then processes the command and displays a 
'  HTML page that will redirect the user with a HTML form POST to the Virtual 
'  Payment Client (VPC)  if card details are included in the data, otherwise
'  we can use a standard redirect with a HTML GET (Querystring encoded variables).

'  @author Dialect Payment Solutions Pty Ltd Group 

'  ----------------------------------------------------------------------------

' Force explicit declaration of all variables
Option Explicit

' Turn off default error checking, as any errors are explicitly handled
On Error Resume Next

' Include the MD5 code that will be used to create the secure hash if required
%>
<!--#include file="md5.asp"-->
<%
' *******************************************
' START OF MAIN PROGRAM
' *******************************************

' The Page redirects the cardholder to the Virtual Payment Client (VPC)

' Define Constants
' ----------------
' This is secret for encoding the MD5 hash
' This secret will vary from merchant to merchant
' To not create a secure hash, let SECURE_SECRET be an empty string - ""
' Const SECURE_SECRET = "Your-Secure-Secret"
Const SECURE_SECRET = "974D57EA24BD3D64F412616A8EB24121"

' Stop the page being cached on the web server
Response.Expires = 0

' *******************************************
' Define Variables
' *******************************************

Dim message
Dim count
Dim item
Dim seperator
Dim redirectURL

' Create a 2 dimensional Array that we will use if we need a Secure Hash
If Len(SECURE_SECRET) > 0 Then
    Dim MyArray
    ReDim MyArray(Request.Form.Count,1)
End If

' Create the URL that will send the data to the Virtual Payment Client
redirectURL = Request("virtualPaymentClientURL")

' Add each of the appropriate form variables to the data.
seperator = "?"
count = 1
For Each item In Request.Form

    ' Do not include the Virtual Payment Client URL, the Submit button 
    ' from the form post, or any empty form fields, as we do not want to send 
    ' these fields to the Virtual Payment Client. 
    ' Also construct the VPC URL QueryString while looping through the Form data.
    If Request(item) <> "" And item <> "SubButL" And item <> "virtualPaymentClientURL" Then

        ' Add the item to the array if we need a Secure Hash
        If Len(SECURE_SECRET) > 0 Then
            MyArray (count,0) = CStr(item)
            MyArray (count,1) = CStr(Request(item))
        End If
        ' Add the data to the VPC URL QueryString
        redirectURL = redirectURL & seperator & Server.URLEncode(CStr(item)) & "=" & Server.URLEncode(CStr(Request(item)))
        seperator = "&"

        ' Increment the count to the next array location
        count = count + 1

    End If
Next

' NOTE: The againLink is the URL of the HTML Order Page that generated this
' request so that it can be used for another transaction. 
' This demonstrates how a user field (such as an application Session ID) could
' be added.
' Add the againLink to the VPC URL QueryString
redirectURL = redirectURL & seperator & "AgainLink=" & Server.URLEncode(CStr(Request.ServerVariables("HTTP_REFERER")))

If Err Then
    message = "Error creating request data: " & Err.Source & " - " & Err.number & " - " & Err.Description
    Response.Redirect Request("vpc_ReturnURL") & "?vpc_Message=" & message
    Response.End
End If

' If there is no Secure Secret then there is no need to create the Secure Hash
If Len(SECURE_SECRET) > 0 Then

    ' Add the againLink to the Array if we need a Secure Hash
    MyArray (count,0) = "AgainLink"
    MyArray (count,1) = CStr(Request.ServerVariables("HTTP_REFERER"))

    ' Create MD5 Message-Digest Algorithm hash and add it to the data to be sent
    redirectURL = redirectURL & seperator & "vpc_SecureHash=" & doSecureHash

    If Err Then
        message = "Error creating Secure Hash: " & Err.Source & " - " & Err.number & " - " & Err.Description
        Response.Redirect Request("vpc_ReturnURL") & "?vpc_Message=" & message
        Response.End
    End If

End If

' FINISH TRANSACTION - Send the cardholder to the VPC
' ===================================================
' For the purposes of demonstration, we perform a standard URL redirect. 
Response.Redirect redirectURL
Response.End

' *******************
' END OF MAIN PROGRAM
' *******************

'  -----------------------------------------------------------------------------

Function doSecureHash()

    Dim md5HashData
    Dim index
    
    ' sort the array only if we are creating the MD5 hash
    MyArray = sortArray(MyArray)

    ' start the MD5 input
    md5HashData = SECURE_SECRET
    
    ' loop though the array and add each parameter value to the MD5 input
    index = 0
    count = 0
    For index = 0 to UBound(MyArray)
        If (Len(MyArray(index,1)) > 0) Then
            md5HashData = md5HashData & MyArray(index,1)
            count = count + 1
        End If
    Next
    ' increment the count to the next array location
    count = count + 1
    doSecureHash = MD5(md5HashData)

End Function

'  -----------------------------------------------------------------------------

' This function takes an array and sorts it
'
' @param MyArray is the array to be sorted
Function SortArray(MyArray)

    Dim keepChecking
    Dim loopCounter
    Dim firstKey
    Dim secondKey
    Dim firstValue
    Dim secondValue
    
    keepChecking = TRUE
    loopCounter = 0
    
    Do Until keepChecking = FALSE
        keepChecking = FALSE
        For loopCounter = 0 To (UBound(MyArray)-1)
            If MyArray(loopCounter,0) > MyArray((loopCounter+1),0) Then
                ' transpose the key
                firstKey = MyArray(loopCounter,0)
                secondKey = MyArray((loopCounter+1),0)
                MyArray(loopCounter,0) = secondKey
                MyArray((loopCounter+1),0) = firstKey
                ' transpose the key's value
                firstValue = MyArray(loopCounter,1)
                secondValue = MyArray((loopCounter+1),1)
                MyArray(loopCounter,1) = secondValue
                MyArray((loopCounter+1),1) = firstValue
                keepChecking = TRUE
            End If
        Next
    Loop
    SortArray = MyArray
End Function

'  -----------------------------------------------------------------------------
%>