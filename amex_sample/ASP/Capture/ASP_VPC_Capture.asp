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

'  This program assumes that a URL has been sent to this example with the
'  required fields. The example then processes the command and displays the
'  receipt or error to a HTML page in the users web browser.

'  @author Dialect Payment Solutions Pty Ltd Group 

'  ----------------------------------------------------------------------------

' Force explicit declaration of all variables
Option Explicit

' Turn off default error checking, as any errors are explicitly handled
On Error Resume Next

' *******************************************
' START OF MAIN PROGRAM
' *******************************************

' The Page POSTS the transaction to the Virtual Payment Client and retrieves
' the response

' Define Constants
' ----------------
' Stop the page being cached on the web server
Response.Expires = 0

' *******************************************
' Define Variables
' *******************************************

' Create a 2 dimensional array to hold the form variables so we can sort them
Dim postData
Dim count
Dim item

' These fields are not returned in receipt for an error condition
Dim transactionNo, merchTxnRef
transactionNo     = Request("vpc_TransNo")
merchTxnRef       = Request("vpc_MerchTxnRef")

' Add each of the appropriate form variables to the data.
count = 1
postData = ""
For Each item In Request.Form

    ' Do not include the Virtual Payment Client URL, the Submit button 
    ' from the form post, or any empty form fields, as we do not want to send 
    ' these fields to the Virtual Payment Client. 
    ' Also construct the VPC URL QueryString while looping through the Form data.
    If Request(item) <> "" And item <> "SubButL" _
       And item <> "virtualPaymentClientURL" _
       And item <> "title" Then

        ' Add the data to the VPC URL QueryString
        postData = postData & Server.URLEncode(CStr(item)) & "=" & Server.URLEncode(CStr(Request(item))) & "&"

        ' Increment the count to the next array location
        count = count + 1

    End If
Next
' Remove the trailing ampersand on the data
postData = Mid(postData,1,Len(postData)-1)

If Err Then
    message = "Error creating POST data: " & Err.number & " - " & Err.Description
    Err.Clear
End If

Dim xmlHTTP
Dim txt
Set xmlHTTP = Server.CreateObject("Msxml2.ServerXMLHTTP.3.0")

' Perform Error checking to make sure the MSXML2 object has been created
Dim message
message = ""
If Err Then
    message = "Error creating MSXML Object: " & Err.number & " - " & Err.Description
    Err.Clear
Else

    ' When testing you may wish to disable SSL certificate checking.
    ' To disable SSL certififcate validation, uncomment the following line.
    xmlHTTP.setOption 2, 13056

    'Open connection to Virtual Payment Client
    xmlHTTP.open "POST", Request("virtualPaymentClientURL"), False
    ' Perform error checking to make sure the connection has been opened
    If Err Then
        message = "Error getting connection to Server: " & Err.number & " - " & Err.Description
        Err.Clear
    Else
        'Set headers
        xmlHTTP.setRequestHeader "Content-Type","application/x-www-form-urlencoded"
        xmlHTTP.setRequestHeader "Content-Length", Len(postData)

        'Send request string
        xmlhttp.Send postData

        ' Test to make sure that the request was sent
        If Not xmlHTTP.status = 200 And Len(message) = 0 Then
            message = "Error communicating with Server: " & xmlHTTP.status & " - " & xmlHTTP.statusText
        ElseIf Err And Len(message) = 0 Then
            message = "Error using Microsoft MSXML Object: " & Err.number & " - " & Err.Description
            Err.clear
        End If

        'Get response text
        txt = xmlhttp.responseText
    End If
End If

' Create the dictionary to hold the response data
Dim respParams
Set respParams = splitResponse(txt)

If Err And Len(message) = 0 Then
    message = "Error reading response: " & Err.number & " - " & Err.Description
    Err.clear
End If

' *******************
' END OF MAIN PROGRAM
' *******************

' FINISH TRANSACTION - Output the VPC Response Data
' =====================================================
' For the purposes of demonstration, we simply display the Result fields on a
' web page.

' Miscellaneous Data
Dim title
title     = Request("title")

' Extract the available receipt fields from the VPC Response
' If not present then set the value to "No Value Returned" using the 
' null2unknown Function
    
Dim amount, batchNo, command, version, cardType, orderInfo, receiptNo, _
    merchantID, authorizeID, acqResponseCode, txnResponseCode

' Standard Receipt Data
amount          = null2unknown(respParams("vpc_Amount"))
batchNo         = null2unknown(respParams("vpc_BatchNo"))
command         = null2unknown(respParams("vpc_Command"))
version         = null2unknown(respParams("vpc_Version"))
cardType        = null2unknown(respParams("vpc_Card"))
receiptNo       = null2unknown(respParams("vpc_ReceiptNo"))
merchantID      = null2unknown(respParams("vpc_Merchant"))
authorizeID     = null2unknown(respParams("vpc_AuthorizeId"))
transactionNr   = null2unknown(respParams("vpc_TransactionNo"))
acqResponseCode = null2unknown(respParams("vpc_AcqResponseCode"))
txnResponseCode = null2unknown(respParams("vpc_TxnResponseCode"))
' Don't overwrite an existing error message
If Len(message) = 0 Then 
    message = null2unknown(respParams("vpc_Message"))
End If

Dim shopTransNo, authorisedAmount, capturedAmount, refundedAmount, ticketNumber
' AMA Transaction Data
shopTransNo     = null2unknown(respParams("vpc_ShopTransactionNo"))
authorisedAmount= null2unknown(respParams("vpc_AuthorisedAmount"))
capturedAmount  = null2unknown(respParams("vpc_CapturedAmount"))
refundedAmount  = null2unknown(respParams("vpc_RefundedAmount"))
ticketNumber    = null2unknown(respParams("vpc_TicketNumber"))

' Show "Error" in title if there is an error condition
Dim errorTitle
errorTitle = ""
' Show this page as an error page if vpc_TxnResponseCode is not "0"
If txnResponseCode = "" Or txnResponseCode = "7" Or txnResponseCode = "No Value Returned" Then 
    errorTitle = "Error "
End If
    
' FINISH TRANSACTION - Process the VPC Response Data
' =====================================================
' For the purposes of demonstration, we simply display the Result fields on
' a web page.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
    <head>
        <title><%=title%> - <%=errorTitle%>Response Page</title>
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
        <table width="75%" align="center" cellpadding="5" border="0" ID="Table2">
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Capture Transaction Fields</strong></p></td>
            </tr>
            <tr>
                <td align="right" width="50%"><strong><i>VPC API Version: </i></strong></td>
                <td width="50%"><%=version%></td>
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
                <td align="right"><strong><i>Shopping Transaction Number: </i></strong></td>
                <td><%=transactionNo%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Amount: </i></strong></td>
                <td><%=amount%></td>
            </tr>
            <tr>
                <td colspan="2" align="center">
                    <font color="#0074C4">Fields above are the primary request values.<br />
                    <HR />
                    Fields below are the response fields for a Standard Transaction.<br /></font>
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
    If txnResponseCode <> "" And txnResponseCode <> "7" And txnResponseCode <> "No Value Returned" Then 
%>
            <tr>
                <td align="right"><strong><i>Receipt Number: </i></strong></td>
                <td><%=receiptNo%></td>
            </tr>
            <tr class='shade'>
                <td align="right"><strong><i>Capture Transaction Number: </i></strong></td>
                <td><%=transactionNr%></td>
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
                    <HR />
                    Fields below are additional fields for extra functionality.</font><br />
                </td>
            </tr>
            <tr class='title'>
                <td colspan="2" height="25"><p><strong>&nbsp;Financial Transaction Fields</strong></p></td>
            </tr>
            <tr>
                <td align='right'><strong><i>Shopping Transaction Number: </i></strong></td>
                <td><%=shopTransNo%></td>
            </tr>
            <tr class='shade'>
                <td align='right'><strong><i>Authorised Amount: </i></strong></td>
                <td><%=authorisedAmount%></td>
            </tr>
            <tr>                
                <td align='right'><strong><i>Captured Amount: </i></strong></td>
                <td><%=capturedAmount%></td>
            </tr>
            <tr class='shade'>
                <td align='right'><strong><i>Refunded Amount: </i></strong></td>
                <td><%=refundedAmount%></td>
            </tr>
            <tr>                  
                <td align='right'><strong><i>Ticket Number: </i></strong></td>
                <td><%=ticketNumber%></td>
            </tr>
            <tr>
                <td colspan="2"><HR /></td>
            </tr>
<% End If %>
        </table>
        <center><p><a href='<%=Request.ServerVariables("HTTP_REFERER")%>'>New Transaction</a></p></center>
    </body>
</html>
<%    
  
'  -----------------------------------------------------------------------------

' This function uses the Response String retrieved from the Digital
' Receipt and returns a collection of the the key value pairs
'
' @param queryString containing the Response String
'
' @return Dictionary of key value pairs
'
Function splitResponse(data)

    Dim params
    Dim pairs
    Dim pair
    Dim equalsIndex
    Dim name
    Dim value

    Set params = CreateObject("Scripting.Dictionary")
    
    ' Check if there was a response
    If Len(data) > 0 Then
        ' Check if there are any paramenters in the response
        If InStr(data, "=") > 0 Then
            ' Get the parameters out of the response
            pairs = Split(data, "&")
            For Each pair In pairs
                ' If there is a key/value pair in this item then store it
                equalsIndex = InStr(pair, "=")
                If equalsIndex > 1 And Len(pair) > equalsIndex Then
                    name = Left(pair, equalsIndex - 1)
                    value = Right(pair, Len(pair) - equalsIndex)
                    params.add name, URLDecode(value)
                End If
            Next
        Else
            ' There were no parameters so create an error
            params.Add "vpc_Message", "The data contained in the response was invalid or corrupt, the data is: <pre>" & data & "</pre>"
        End If
    Else
        ' There was no data so create an error
        params.Add "vpc_Message", "There was no data contained in the response"
    End If
    Set splitResponse = params
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
%>
