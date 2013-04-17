<%@ Page Language="C#" DEBUG=false %>

<!DOCTYPE HTML PUBLIC '-'W3C'DTD HTML 4.01 Transitional'EN'>
<html>
<head>

<script runat="server">
/*
Version 3.1

---------------- Disclaimer --------------------------------------------------

Copyright 2004 Dialect Solutions Holdings.  All rights reserved.

This document is provided by Dialect Holdings on the basis that you will treat
it as confidential.

No part of this document may be reproduced or copied in any form by any means
without the written permission of Dialect Holdings.  Unless otherwise
expressly agreed in writing, the information contained in this document is
subject to change without notice and Dialect Holdings assumes no
responsibility for any alteration to, or any error or other deficiency, in
this document.

All intellectual property rights in the Document and in all extracts and
things derived from any part of the Document are owned by Dialect and will be
assigned to Dialect on their creation. You will protect all the intellectual
property rights relating to the Document in a manner that is equal to the
protection you provide your own intellectual property.  You will notify
Dialect immediately, and in writing where you become aware of a breach of
Dialect's intellectual property rights in relation to the Document.

The names "Dialect", "QSI Payments" and all similar words are trademarks of
Dialect Holdings and you must not use that name or any similar name.

Dialect may at its sole discretion terminate the rights granted in this
document with immediate effect by notifying you in writing and you will
thereupon return (or destroy and certify that destruction to Dialect) all
copies and extracts of the Document in its possession or control.

Dialect does not warrant the accuracy or completeness of the Document or its
content or its usefulness to you or your merchant customers.   To the extent
permitted by law, all conditions and warranties implied by law (whether as to
fitness for any particular purpose or otherwise) are excluded.  Where the
exclusion is not effective, Dialect limits its liability to $100 or the
resupply of the Document (at Dialect's option).

Data used in examples and sample data files are intended to be fictional and
any resemblance to real persons or companies is entirely coincidental.

Dialect does not indemnify you or any third party in relation to the content
or any use of the content as contemplated in these terms and conditions.

Mention of any product not owned by Dialect does not constitute an endorsement
of that product.

This document is governed by the laws of New South Wales, Australia and is
intended to be legally binding.

Author: Dialect Solutions Group Pty Ltd

------------------------------------------------------------------------------*/

/*
<summary>ASP.NET C# 3-Party example for the Virtual Payment Client</summary>
<remarks>

<para>
This example assumes that a HTTP Form POST has been sent to this example with
the required fields. The example then creates a payment request that is sent to
the Payment Server via a cardholder's browser redirect.
</para>

<para>
Before it redirects, the payment request creates an MD5 security signature to 
ensure that if any data changes occur during transmission, they are picked up by 
the Payment Server. If the data is changed, the MD5 signature will compute 
incorrectly at the Payment Server and the transaction will not complete.
</para>

<para>
To instantiate the MD5 signature check, the MD5 seed must be first saved in the 
SECURE_SECRET value which is first parameter in the PageLoad() class. The 
SECURE_SECRET value can be found in Merchant Administration/Setup page on the 
Payment Server. Without this seed the MD5 signature will not be created.
</para>

<para>
TRANSACTION DATA SHOULD NOT BE PASSED THROUGH THE ORDER PAGE AS HIDDEN FIELDS. 
It is very easy for the cardholder to use the browser 'View/Source' function 
to see, and change the data while in transit. SIMILARLY CLIENT SIDE SESSION 
COOKIES ALSO SHOULD NOT BE USED TO STORE TRANSACTION DATA.
</para>

<para>
To avoid this issue you can add sensitive data direct from a database query or a 
session variable stored server side on this page. In fact no transaction data 
should be passed in from the order page at all.
</para>

<para>
You can simply retreive the transaction data from the server and add the data 
directly to the SortedList transactionData as key value pairs as per the 
AgainLink and Title vales shown below. 
</para>

<para>
If used in this way there is no need to retrieve any form data or loop 
through the <c>Page.Request.Form</c> collection as done in this example.
</para>

</remarks>
*/

// _____________________________________________________________________________

// Declare the global variables
private string debugData = "";

//______________________________________________________________________________

private class VPCStringComparer: IComparer 
{
    /*
     <summary>Customised Compare Class</summary>
     <remarks>
     <para>
     The Virtual Payment Client need to use an Ordinal comparison to Sort on 
     the field names to create the MD5 Signature for validation of the message. 
     This class provides a Compare method that is used to allow the sorted list 
     to be ordered using an Ordinal comparison.
     </para>
     </remarks>
     */

    public int Compare(Object a, Object b) 
    {
        /*
         <summary>Compare method using Ordinal comparison</summary>
         <param name="a">The first string in the comparison.</param>
         <param name="b">The second string in the comparison.</param>
         <returns>An int containing the result of the comparison.</returns>
         */

        // Return if we are comparing the same object or one of the 
        // objects is null, since we don't need to go any further.
        if (a == b) return 0;
        if (a == null) return -1;
        if (b == null) return 1;

        // Ensure we have string to compare
        string sa = a as string;
        string sb = b as string;

        // Get the CompareInfo object to use for comparing
        System.Globalization.CompareInfo myComparer = System.Globalization.CompareInfo.GetCompareInfo("en-US");
        if (sa != null && sb != null)
        {
            // Compare using an Ordinal Comparison.
            return myComparer.Compare(sa, sb, System.Globalization.CompareOptions.Ordinal);
        }
        throw new ArgumentException("a and b should be strings.");
    }
}

//______________________________________________________________________________

private string CreateMD5Signature (string RawData)
{
    /*
     <summary>Creates a MD5 Signature</summary>
     <param name="RawData">The string used to create the MD5 signautre.</param>
     <returns>A string containing the MD5 signature.</returns>
     */
    
    System.Security.Cryptography.MD5 hasher = System.Security.Cryptography.MD5CryptoServiceProvider.Create();
    byte[] HashValue = hasher.ComputeHash(Encoding.ASCII.GetBytes(RawData));

    string strHex = "";
    foreach(byte b in HashValue) 
    {
        strHex += b.ToString("x2");
    }
    return strHex.ToUpper();
}

// _____________________________________________________________________________

private void Page_Load(object sender, System.EventArgs e)
{
   /*
    <summary>Performs a VPC request transaction from an incoming HTTP POST</summary>
    <remarks>
     
    <para>
    If the vpc_TicketNo field is optional and if not used then leave it out of 
    the SortedList.
    </para>

    <para>
    To correctly calculate the MD5 Hash signature the SortedList must be
    specified to sort by an Ordinal comparison - see VPCStringComparer() class
    above. If not done this way the SortedList will sort Case Insensitive and 
    not calculate the MD5 signature correctly.
    </para>

    <para>
    The queryString information can be then used in a browser redirect operation
    to send the information to the Payment Server for processing.
    </para>

    <code>
    Page.Response.Redirect(queryString);
    </code>

    <para>
    To find out what is included in your queryString data you can enable DEBUG 
    and run a test transaction. The postData string will then be output to the 
    screen. This debug code allows the user to see all the data associated with 
    the transaction. DEBUG should be disabled or removed entirely in production 
    code.
    </para>

    <para>
    To enable DEBUG, change the ASP directive at the top of this file.
    <para>

    <code>   <%@ Page Language="C#" DEBUG=false %>   </code>
    <para>                    to                     </para>
    <code>   <%@ Page Language="C#" DEBUG=true %>    </code>

    <para>
    The actual functionality of this example resides in lines which creates a 
    SortedList and redirects it to the Payment Server.
    </para>

    <para>
    The rest of the example is only parsing incoming data, and creating 
    HTML markup to display the receipt nicely for the example.
    </para>
    </remarks>
    */

   /*
    *******************************************
    * Define Variables
    *******************************************
    */

    // This is secret for encoding the MD5 hash
    // This secret will vary from merchant to merchant
    // To not create a secure hash, let SECURE_SECRET be an empty string - ""
    // SECURE_SECRET can be found in Merchant Administration/Setup page
    string SECURE_SECRET = "";

    Panel_Debug.Visible = false;
    Panel_StackTrace.Visible = false;

    // define message string for errors
    string message = "No Messages";
    
    // error exists flag
    bool errorExists = false;

    // transaction response code
    string txnResponseCode = "";

    try
    {
       /*
        *************************
        * START OF MAIN PROGRAM *
        *************************
        */

        // NOTE: We use our own overloaded IComparer interface to ensure we do 
        // an Ordinal sort of the data.
        System.Collections.SortedList transactionData = new System.Collections.SortedList(new VPCStringComparer());

        // create start of QueryString data
        string queryString = Page.Request.Form["virtualPaymentClientURL"];
        
        // Collect debug information
        # if DEBUG
            debugData += "<u>Data from Order Page</u><br/>";
        # endif

        // Transaction data should not be passed in in this manner for a 
        // production system - see notes above.
        // loop through all the data in the Page.Request.Form
        foreach (string item in Page.Request.Form) {
            
            // Collect debug information
            # if DEBUG 
                debugData += item +"="+ Page.Request.Form[item] +"<br/>";
            # endif
            
           /* Only include those fields required for a transaction
            * Extract the Form POST data and ignore the Virtual Payment Client
            * URL,  the ReturnURL, the Submit button and any empty form fields, 
            * as we do not want to send these fields on, or in the case of the
            * vpc_ReturnURL modify it before sending. 
            */
            if ((Page.Request.Form[item] != "") && 
                (item != "virtualPaymentClientURL") && 
                (item != "SubButL") && 
                (item != "Title")) 
            {
                transactionData.Add (item, Page.Request.Form[item]);
            }
        }

       /* The AgainLink is for the receipt/error page to do another transaction.
        * The title is only used to display on the receipt/error page
        *
        * Note: These parameters are ONLY used for this example and is NOT 
        * required for production code. 
        *
        * However, it does show how extra session variables can be added to the 
        * transaction request so they will be returned in the receipt.
        *
        * Transaction data should not be passed in as hidden fields but be
        * addedhere as key value pairs, e.g.
        * transactionData.Add("vpc_Merchant", merchantValue); 
        * transactionData.Add("vpc_Amount", amountValue);
        * etc.
        */
        
        // add the AgainLink & Title fields
        transactionData.Add ("AgainLink", Page.Request.ServerVariables["HTTP_REFERER"]);
        transactionData.Add ("Title", Page.Request.Form["Title"]);  

        // Collect debug information
        # if DEBUG
            debugData += "<br/><u>Data from Transaction Sorted List</u><br/>";
        # endif

        string rawHashData = SECURE_SECRET;
        string seperator = "?";

        // Loop through all the data in the SortedList transaction data
        foreach (System.Collections.DictionaryEntry item in transactionData) {

            // Collect debug information
            # if DEBUG 
                debugData += item.Key.ToString() +"="+ item.Value.ToString() +"<br/>";
            # endif
            
            // build the query string, URL Encoding all keys and their values
            queryString += seperator + System.Web.HttpUtility.UrlEncode(item.Key.ToString()) + "=" + System.Web.HttpUtility.UrlEncode(item.Value.ToString());
            seperator = "&";

            // Collect the data required for the MD5 sugnature if required
            if (SECURE_SECRET.Length > 0)
            {
                rawHashData += item.Value.ToString();
            }
        }

        // Create the MD5 signature if required
        string signature = "";
        if (SECURE_SECRET.Length > 0)
        {
			// create the signature and add it to the query string
            signature = CreateMD5Signature(rawHashData);
            queryString += seperator + "vpc_SecureHash=" + signature;
            
            // Collect debug information
            # if DEBUG 
                debugData += "<br/><u>Hash Data Input</u>: " + rawHashData + "<br/><br/><u>Signature Created</u>: "+signature+"<br/>";
            # endif
        }

        // Collect debug information
        # if DEBUG
            debugData += "<br/><u>Final QueryString Data String</u>: " + queryString + "<br/><br/><a href=\'" + queryString + "'>Click here to proceed.</a><br/>";
        # else
            // Transmit the DO to the Payment Server via a browser redirect
            Page.Response.Redirect(queryString);
        # endif
       
        
    }
    catch (Exception ex)
    {
       message = "(51) Exception encountered. " + ex.Message;
       if (ex.StackTrace.Length > 0)
       {
           Label_StackTrace.Text = ex.ToString();
           Panel_StackTrace.Visible = true;
       }
       errorExists = true;
    }
    
    Label_Message.Text = message;

    // Output debug data to the screen
    # if DEBUG
        debugData += "<br/><br/>End of debug information<br/>";
        Label_Debug.Text    = debugData;
        Panel_Debug.Visible = true;
    # endif

   /*
    **********************
    * END OF MAIN PROGRAM
    **********************
    *
    * FINISH TRANSACTION - Output the VPC Response Data
    * =====================================================
    * For the purposes of demonstration, we simply display the Result fields
    * on a web page.
    */
}
</script>

<title>Example Transaction</title>
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
<style type='text/css'>
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

<asp:Panel id="Panel_Debug" runat=server>
<!-- only display these next fields if debug enabled -->
<table>
    <tr>
        <td><asp:Label id=Label_Debug runat="server"/></td>
    </tr>
    <tr>
        <td><asp:Label id=Label_DigitalOrder runat="server"/></td>
    </tr>
</table>
</asp:Panel>

<asp:Panel id="Panel_StackTrace" runat=server>
<!-- only display these next fields if an stacktrace output exists-->
    <tr>
        <td colspan="2">&nbsp;</td>
    </tr>
    <tr class="title">
        <td colspan="2"><p><strong>&nbsp;Exception Stack Trace</strong></p></td>
    </tr>
    <tr>
        <td colspan="2"><asp:Label id=Label_StackTrace runat="server"/></td>
    </tr>
</asp:Panel>

<table>
    <tr>
        <td align="right"><strong><i>Message: </i></strong></td>
        <td><asp:Label id=Label_Message runat="server"/></td>
    </tr>
</table>


</body>
</html>
