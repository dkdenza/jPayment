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
'  required fields. The example then retrieves these fields and displays the
'  receipt or error to a HTML page in the users web browser.

'  @author Dialect Payment Solutions Pty Ltd Group 

'  ----------------------------------------------------------------------------

' Force explicit declaration of all variables
Option Explicit

' Turn off default error checking, as any errors are explicitly handled
'On Error Resume Next

%>
<!--#include file="md5.asp"-->
<%

' *******************************************
' START OF MAIN PROGRAM
' *******************************************

' The Page does a redirect to the Virtual Payment Client

' Define Constants
' ----------------
' This is secret for encoding the MD5 hash
' This secret will vary from merchant to merchant
' To not create a secure hash, let SECURE_SECRET be an empty string - ""
' Const SECURE_SECRET = "Your-Secure-Secret"
Const SECURE_SECRET = ""

' Stop the page being cached on the web server
Response.Expires = 0

' *******************************************
' Define Variables
' *******************************************
' Local Variables
Dim hashValidated, errorExists, errorTitle

' Miscellaneous Data that was added to the Digital Order
Dim title, againLink

' Standard Receipt Data
Dim amount, locale, batchNo, command, message, version, cardType, orderInfo, receiptNo, _
    merchantID, authorizeID, merchTxnRef, transactionNo, acqResponseCode, txnResponseCode

' CSC Receipt Data
Dim cscResultCode, cscRequestCode, acqCSCRespCode

' AVS Receipt Data
Dim avs_City, avs_Country, avs_Street01, avs_PostCode, avs_StateProv, _
    avsResultCode, avsRequestCode, acqAVSRespCode

' 3-D Secure Data
Dim verType, verStatus, token, verSecurLevel, enrolled, xid, acqECI, authStatus

' Initialise the Local Variables
hashValidated = "<font color='orange'><b>Not Calculated</b></font>"
errorTitle = ""
errorExists = 0

' If we have a SECURE_SECRET then validate the incoming data using the MD5 hash
' included in the incoming data
If Len(SECURE_SECRET) > 0 And Len(Request.QueryString("vpc_SecureHash")) > 0 Then
    ' Find out if the incoming data is in a POST or a GET
    ' Create a 2 dimensional array to hold the form variables so we can sort them
    Dim MyArray
    Dim count
    Dim item
    ReDim MyArray((Request.QueryString.Count),1)

    ' Enter each of the appropriate form variables into the array.
    count = 1
    For Each item In Request.QueryString
        ' Do not include the Virtual Payment Client URL, the Submit button 
        ' from the form post, or any control fields, as we do not want to send 
        ' these fields to the Virtual Payment Client. 
        If Request.QueryString(item) <> "" And item <> "vpc_SecureHash" Then
            ' Add the item to the array
            MyArray (count,0) = item                
            MyArray (count,1) = Request.QueryString(item)
            ' Increment the count to the next array location
            count = count + 1
        End If
    Next

    ' Validate the Secure Hash (remember MD5 hashes are not case sensitive)
    If UCase(Request.QueryString("vpc_SecureHash")) = UCase(doSecureHash) Then
        ' Secure Hash validation succeeded,
        ' add a data field to be displayed later.
        hashValidated = "<font color='#00AA00'><b>CORRECT</b></font>"
    Else
        ' Secure Hash validation failed, add a data field to be displayed
        ' later.
        hashValidated = "<font color='#FF0066'><b>INVALID HASH</b></font>"
        errorExists = 1
    End If
End If

If Err Then
    message = "Error validating Secure Hash: " & Err.Source & " - " & Err.number & " - " & Err.Description
    Response.End
End If

' FINISH TRANSACTION - Output the VPC Response Data
' =====================================================
' For the purposes of demonstration, we simply display the Result fields on a
' web page.

' Extract the available receipt fields from the VPC Response
' If not present then set the value to "No Value Returned" using the 
' null2unknown Function

' Miscellaneous Data that was added to the Digital Order
title     = null2unknown(Request.QueryString("title"))
againLink = null2unknown(Request.QueryString("AgainLink"))

' Standard Receipt Data
amount          = null2unknown(Request.QueryString("vpc_Amount"))
locale          = null2unknown(Request.QueryString("vpc_Locale"))
batchNo         = null2unknown(Request.QueryString("vpc_BatchNo"))
command         = null2unknown(Request.QueryString("vpc_Command"))
version         = null2unknown(Request.QueryString("vpc_Version"))
cardType        = null2unknown(Request.QueryString("vpc_Card"))
orderInfo       = null2unknown(Request.QueryString("vpc_OrderInfo"))
receiptNo       = null2unknown(Request.QueryString("vpc_ReceiptNo"))
merchantID      = null2unknown(Request.QueryString("vpc_Merchant"))
authorizeID     = null2unknown(Request.QueryString("vpc_AuthorizeId"))
merchTxnRef     = null2unknown(Request.QueryString("vpc_MerchTxnRef"))
transactionNo   = null2unknown(Request.QueryString("vpc_TransactionNo"))
acqResponseCode = null2unknown(Request.QueryString("vpc_AcqResponseCode"))
txnResponseCode = null2unknown(Request.QueryString("vpc_TxnResponseCode"))

If Len(message) = 0 then
    message     = null2unknown(Request.QueryString("vpc_Message"))
End If

' CSC Receipt Data
cscResultCode  = null2unknown(Request.QueryString("vpc_CSCResultCode"))
cscRequestCode = null2unknown(Request.QueryString("vpc_CSCRequestCode"))
acqCSCRespCode = null2unknown(Request.QueryString("vpc_AcqCSCRespCode"))

' AVS Receipt Data
avs_City       = null2unknown(Request.QueryString("vpc_AVS_City"))
avs_Country    = null2unknown(Request.QueryString("vpc_AVS_Country"))
avs_Street01   = null2unknown(Request.QueryString("vpc_AVS_Street01"))
avs_PostCode   = null2unknown(Request.QueryString("vpc_AVS_PostCode"))
avs_StateProv  = null2unknown(Request.QueryString("vpc_AVS_StateProv"))
avsResultCode  = null2unknown(Request.QueryString("vpc_AVSResultCode"))
avsRequestCode = null2unknown(Request.QueryString("vpc_AVSRequestCode"))
acqAVSRespCode = null2unknown(Request.QueryString("vpc_AcqAVSRespCode"))

' 3-D Secure Data
verType        = null2unknown(Request.QueryString("vpc_VerType"))
verStatus      = null2unknown(Request.QueryString("vpc_VerStatus"))
token           = null2unknown(Request.QueryString("vpc_VerToken"))
verSecurLevel  = null2unknown(Request.QueryString("vpc_VerSecurityLevel"))
enrolled       = null2unknown(Request.QueryString("vpc_3DSenrolled"))
xid               = null2unknown(Request.QueryString("vpc_3DSXID"))
acqECI           = null2unknown(Request.QueryString("vpc_3DSECI"))
authStatus       = null2unknown(Request.QueryString("vpc_3DSstatus"))

' FINISH TRANSACTION - Process the VPC Response Data
' =====================================================
' For the purposes of demonstration, we simply display the Result fields on
' a web page.

' Show this page as an error page if vpc_TxnResponseCode is equal to  "7"
If txnResponseCode = "7" Or txnResponseCode = "No Value Returned" Or errorExists = 1 Then 
    errorTitle = "Error "
End If
    
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <title>
            <%=title%> - <%=errorTitle%>Response Page</title>
        <meta http-equiv="Content-Type" content="text/html, charset=iso-8859-1">
        <style type="text/css">
            <!--
            h1       { font-family:Arial,sans-serif; font-size:20pt; font-weight:600; margin-bottom:0.1em; color:#08185A;}
            h2       { font-family:Arial,sans-serif; font-size:14pt; font-weight:100; margin-top:0.1em; color:#08185A;}
            h2.co    { font-family:Arial,sans-serif; font-size:24pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#08185A}
            h3       { font-family:Arial,sans-serif; font-size:16pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#08185A}
            h3.co    { font-family:Arial,sans-serif; font-size:16pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#FFFFFF}
            body     { font-family:Verdana,Arial,sans-serif; font-size:10pt; background-color:#FFFFFF; color:#08185A}
            th       { font-family:Verdana,Arial,sans-serif; font-size:8pt; font-weight:bold; background-color:#CED7EF; padding-top:0.5em; padding-bottom:0.5em;  color:#08185A}
            tr       { height:25px; }
            .shade   { height:25px; background-color:#CED7EF }
            .title   { height:25px; background-color:#0074C4 }
            td       { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A }
            td.red   { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#FF0066 }
            td.green { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#008800 }
            p        { font-family:Verdana,Arial,sans-serif; font-size:10pt; color:#FFFFFF }
            p.blue   { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#08185A }
            p.red    { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#FF0066 }
            p.green  { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#008800 }
            div.bl   { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#0074C4 }
            div.red  { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#FF0066 }
            li       { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#FF0066 }
            input    { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:bold }
            select   { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:bold; }
            textarea { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:normal; scrollbar-arrow-color:#08185A; scrollbar-base-color:#CED7EF }
            -->
        </style>
    </head>
    <body>
        <!-- Start Branding Table -->
        <table width="100%" border="2" cellpadding="2" class="title">
            <tr>
                <td class="shade" width="90%"><h2 class="co">&nbsp;Virtual Payment Client Example</h2></td>
                <td class="title" align="center"><h3 class="co">Dialect<br />Solutions</h3></td>
            </tr>
        </table>
        <!-- End Branding Table -->
        <center><h1><%=title%> - <%=errorTitle%>Response Page</h1></center>
        <table width="85%" align="center" cellpadding="5" border="0" ID="Table2">
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Basic Transaction Fields</strong></p></td>
            </tr>
            <tr>
                <td align="right" width="55%"><strong><i>VPC API Version: </i></strong></td>
                <td width="45%"><%=version%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Command: </i></strong></td>
                <td><%=command%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Merchant Transaction Reference: </i></strong></td>
                <td><%=merchTxnRef%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Merchant ID: </i></strong></td>
                <td><%=merchantID%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Order Information: </i></strong></td>
                <td><%=orderInfo%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Amount: </i></strong></td>
                <td><%=amount%></td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <font color="#0074C4">Fields above are the primary request values.<br />
                        <hr />
                        Fields below are the response fields for a Standard Transaction.<br />
                    </font>
                </td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>VPC Transaction Response Code: </i></strong></td>
                <td><%=txnResponseCode%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Transaction Response Code Description: </i></strong></td>
                <td><%=getResponseDescription(txnResponseCode)%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Message: </i></strong></td>
                <td><%=message%></td>
            </tr>
            <% 
    ' Only display the following fields if not an error condition
    If txnResponseCode <> "7" And txnResponseCode <> "No Value Returned" Then 
%>
            <tr>
                <td align="right"><strong><i>Receipt Number: </i></strong></td>
                <td><%=receiptNo%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Transaction Number: </i></strong></td>
                <td><%=transactionNo%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Acquirer Response Code: </i></strong></td>
                <td><%=acqResponseCode%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Bank Authorization ID: </i></strong></td>
                <td><%=authorizeID%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Batch Number: </i></strong></td>
                <td><%=batchNo%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Card Type: </i></strong></td>
                <td><%=cardType%></td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <font color="#0074C4">Fields above are for a Standard Transaction<br />
                        <hr />
                        Fields below are additional fields for extra functionality.<br />
                    </font>
                </td>
            </tr>
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Card Security Code Fields</strong></p></td>
            </tr>
            <tr>
                <td align="right"><strong><i>CSC Request Code: </i></strong></td>
                <td><%=cscRequestCode%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>CSC Acquirer Response Code: </i></strong></td>
                <td><%=acqCSCRespCode%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>CSC QSI Result Code: </i></strong></td>
                <td><%=cscResultCode%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>CSC Result Description: </i></strong></td>
                <td><%=displayCSCResponse(cscResultCode)%></td>
            </tr>
            <tr>
                <td colspan="2"><hr /></td>
            </tr>
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Address Verification Service Fields</strong></p></td>
            </tr>
            <tr>
                <td align="right"><strong><i>AVS Street/Postal Address: </i></strong></td>
                <td><%=avs_Street01%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>AVS City/Town/Suburb: </i></strong></td>
                <td><%=avs_City%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>AVS State/Province: </i></strong></td>
                <td><%=avs_StateProv%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>AVS Postal/Zip Code: </i></strong></td>
                <td><%=avs_PostCode%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>AVS Country Code: </i></strong></td>
                <td><%=avs_Country%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>AVS Request Code: </i></strong></td>
                <td><%=avsRequestCode%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>AVS Acquirer Response Code: </i></strong></td>
                <td><%=acqAVSRespCode%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>AVS QSI Result Code: </i></strong></td>
                <td><%=avsResultCode%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>AVS Result Description: </i></strong></td>
                <td><%=displayAVSResponse(avsResultCode)%></td>
            <tr>
                <td colspan="2"><hr /></td>
            </tr>
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;3-D Secure Fields</strong></p></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Unique 3DS transaction identifier: </i></strong></td>
                <td class="red"><%=xid%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>3DS Authentication Verification Value: </i></strong></td>
                <td class="red"><%=token%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>3DS Electronic Commerce Indicator: </i></strong></td>
                <td class="red"><%=acqECI%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>3DS Authentication Scheme: </i></strong></td>
                <td class="red"><%=verType%></td>
            </tr>
            <tr>
                <td align="right"><strong><i>3DS Security level used in the AUTH message: </i></strong></td>
                <td class="red"><%=verSecurLevel%></td>
            </tr>
            <tr class='shade'>
                <td align="right">
                    <strong><i>3DS CardHolder Enrolled: </strong>
                    <br />
                    <font size="1">Takes values: <strong>Y</strong> - Yes <strong>N</strong> - No</i></font>
                </td>
                <td class="red"><%=enrolled%></td>
            </tr>
            <tr>
                <td align="right">
                    <i><strong>Authenticated Successfully: </strong>
                        <br />
                        <font size="1">
                            Only returned if CardHolder Enrolled = <strong>Y</strong>. Takes values:<br />
                            <strong>Y</strong> - Yes <strong>N</strong> - No <strong>A</strong> - Attempted to Check <strong>U</strong> - Unavailable for Checking
                        </font>
                    </i>
                </td>
                <td class="red"><%=authStatus%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Payment Server 3DS Authentication Status Code: </i></strong></td>
                <td class="green"><%=verStatus%></td>
            </tr>
            <tr>
                <td align="right"><i><strong>3DS Authentication Status Code Description: </strong></i></td>
                <td class="green"><%=get3DSstatusDescription(verStatus)%></td>
            </tr>
            <tr>
                <td colspan="2" align="center" valign="middle"><font color='#FF0066'>The 3-D Secure values shown in red are those values that are important values to store in case of future transaction repudiation.</font></td>
            </tr>
            <tr>
                <td colspan="2" align="center" valign="middle"><font color='#00AA00'>The 3-D Secure values shown in green are for information only and are not required to be stored.</font></td>
            </tr>
<% End If %>
            <tr>
                <td colspan="2"><hr /></td>
            </tr>
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Hash Validation</strong></p></td>
            </tr>
            <tr>
                <td align="right"><strong><i>Hash Validated Correctly: </i></strong></td>
                <td><%=hashValidated%></td>
            </tr>
        </table>
        <center><p><a href='<%=againLink%>'>New Transaction</a></p></center>
    </body>
</html>
<%    

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
    
    doSecureHash = UCase(MD5(md5HashData))

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
     
' This function takes a String and add a value if empty
'
' @param inputData is the String to be tested
' @return String If input is empty returns string - "No Value Returned", Else returns inputData
Function null2unknown(inputData) 
    
    If inputData = "" Then
        null2unknown = "No Value Returned"
    Else
        null2unknown = inputData
    End If

End Function

'  -----------------------------------------------------------------------------

' This function uses the URL Encoded value retrieved from the Digital
' Receipt and returns a decoded string
'
' @param input containing the URLEncoded input value
'
' @return a string of the decoded input
'
Function URLDecode(encodedTxt)

    Dim output
    Dim percentSplit

    If encodedTxt = "" Then
        URLDecode = ""
        Exit Function
    End If

    ' First convert the + to a space
    output = Replace(encodedTxt, "+", " ")

    ' Then convert the %hh to normal code
    percentSplit = Split(output, "%")

    If IsArray(percentSplit) Then
        output = percentSplit(0)
        Dim i
        Dim part
        Dim strHex
        Dim Letter
        For i = Lbound(percentSplit) To UBound(percentSplit) - 1
            part = percentSplit(i + 1)
            strHex = "&H" & Left(part, 2)
            Letter = Chr(strHex)
            output = output & Letter & Right(part, Len(part) -2)
        Next
    End If

    URLDecode = output

End Function

'  -----------------------------------------------------------------------------

' This function uses the Transaction Response code retrieved from the Digital
' Receipt and returns an appropriate description for the QSI Response Code
'
' @param vResponseCode containing the QSI Response Code
'
' @return description containing the appropriate description
'
Function getResponseDescription(txnResponseCode)

    Select Case txnResponseCode
        Case "0"  
            getResponseDescription = "Transaction Successful"
        Case "1"   
            getResponseDescription = "Unknown Error"
        Case "2"   
            getResponseDescription = "Bank Declined Transaction"
        Case "3"   
            getResponseDescription = "No Reply from Bank"
        Case "4"   
            getResponseDescription = "Expired Card"
        Case "5"   
            getResponseDescription = "Insufficient Funds"
        Case "6"   
            getResponseDescription = "Error Communicating with Bank"
        Case "7"   
            getResponseDescription = "Payment Server System Error"
        Case "8"   
            getResponseDescription = "Transaction Type Not Supported"
        Case "9"   
            getResponseDescription = "Bank declined transaction (Do not contact Bank)"
        Case "A"   
            getResponseDescription = "Transaction Aborted"
        Case "C"   
            getResponseDescription = "Transaction Cancelled"
        Case "D"   
            getResponseDescription = "Deferred transaction received and is awaiting processing"
        Case "F"   
            getResponseDescription = "3D Secure Authentication failed"
        Case "I"   
            getResponseDescription = "Card Security Code verification failed"
        Case "L"   
            getResponseDescription = "Shopping Transaction Locked"
        Case "N"   
            getResponseDescription = "Cardholder is not enrolled in Authentication scheme"
        Case "P"   
            getResponseDescription = "Transaction is still being processed"
        Case "R"   
            getResponseDescription = "Transaction not processed - Reached limit of retry attempts allowed"
        Case "S"   
            getResponseDescription = "Duplicate SessionID (OrderInfo)"
        Case "T"   
            getResponseDescription = "Address Verification Failed"
        Case "U"   
            getResponseDescription = "Card Security Code Failed"
        Case "V"   
            getResponseDescription = "Address Verification and Card Security Code Failed"
        Case "?"   
            getResponseDescription = "Transaction status is unknown"
        Case Else  
            getResponseDescription = "Unable to be determined"
    End Select
End Function

'  -----------------------------------------------------------------------------

' This function uses the QSI AVS Result Code retrieved from the Digital
' Receipt and returns an appropriate description for this code.
'
' @param avsResultCode String containing the QSI AVS Result Code
' @return description String containing the appropriate description
'
Function displayAVSResponse(avsResultCode)
    
    If avsResultCode <> "" Then
        Select Case avsResultCode
            Case "Unsupported"   
                displayAVSResponse = "AVS not supported or there was no AVS data provided"
            Case "X"  
                displayAVSResponse = "Exact match - address and 9 digit ZIP/postal code"
            Case "Y"  
                displayAVSResponse = "Exact match - address and 5 digit ZIP/postal code"
            Case "S"  
                displayAVSResponse = "Service not supported or address not verified (international transaction)"
            Case "G"  
                displayAVSResponse = "Issuer does not participate in AVS (international transaction)"
            Case "A"  
                displayAVSResponse = "Address match only"
            Case "W"  
                displayAVSResponse = "9 digit ZIP/postal code matched, Address not Matched"
            Case "Z"  
                displayAVSResponse = "5 digit ZIP/postal code matched, Address not Matched"
            Case "R"  
                displayAVSResponse = "Issuer system is unavailable"
            Case "U"  
                displayAVSResponse = "Address unavailable or not verified"
            Case "E"  
                displayAVSResponse = "Address and ZIP/postal code not provided"
            Case "N"  
                displayAVSResponse = "Address and ZIP/postal code not matched"
            Case "0"  
                displayAVSResponse = "AVS not requested"
            Case Else 
                displayAVSResponse = "Unable to be determined"
        End Select
    Else
        displayAVSResponse = "null response"
    End If
End Function

'  -----------------------------------------------------------------------------

' This function uses the QSI CSC Result Code retrieved from the Digital
' Receipt and returns an appropriate description for this code.
'
' @param cscResultCode String containing the QSI CSC Result Code
' @return description String containing the appropriate description
'
Function displayCSCResponse(cscResultCode)
    
    If cscResultCode <> "" Then
        Select Case cscResultCode
            Case "Unsupported"  
                displayCSCResponse = "CSC not supported or there no CSC data provided"
            Case "M"  
                displayCSCResponse = "Exact code match"
            Case "S"  
                displayCSCResponse = "Merchant indicated that CSC is not present on card"
            Case "P"  
                displayCSCResponse = "Code not processed"
            Case "U"  
                displayCSCResponse = "Card issuer not registered and/or certified"
            Case "N"  
                displayCSCResponse = "Code invalid or not matched"
            Case Else 
                displayCSCResponse = "Unable to be determined"
        End Select
    Else
        displayCSCResponse = "null response"
    End If
End Function

'  -----------------------------------------------------------------------------

' This method uses the verRes status code retrieved from the Digital
' Receipt and returns an appropriate description for the QSI Response Code

' @param statusResponse String containing the 3DS Authentication Status Code
' @return String containing the appropriate description

Function get3DSstatusDescription(statusResponse)
    If statusResponse <> "" Or statusResponse <> "No Value Returned" Then
        get3DSstatusDescription = "3DS not supported or there was no 3DS data provided"
    Else
        Select Case statusResponse
            Case "Y"  
                get3DSstatusDescription = "Cardholder successfully authenticated"
            Case "E"  
                get3DSstatusDescription = "Cardholder not enrolled"
            Case "N"  
                get3DSstatusDescription = "Cardholder not verified"
            Case "U"  
                get3DSstatusDescription = "System Error at the Issuer"
            Case "F"  
                get3DSstatusDescription = "Formatting error in the the 3D Secure request"
            Case "A"  
                get3DSstatusDescription = "3D Secure merchant ID and password authentication Failed"
            Case "D"  
                get3DSstatusDescription = "Error communicating with the Directory Server"
            Case "C"  
                get3DSstatusDescription = "The card type is not supported for authentication"
            Case "S"  
                get3DSstatusDescription = "The Issuers signature on the response could not be validated"
            Case "P"  
                get3DSstatusDescription = "Error parsing input from Issuer"
            Case "I"  
                get3DSstatusDescription = "Internal Payment Server system error"
            Case "T"  
                get3DSstatusDescription = "Timed out while performing authentication"
            Case Else 
                get3DSstatusDescription = "Unable to be determined"
        End Select
    End If
End Function

%>
