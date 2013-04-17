<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--

/* -----------------------------------------------------------------------------

 Version 3.1

------------------ Disclaimer --------------------------------------------------

Copyright 2004 Dialect Solutions Holdings.  All rights reserved.

This document is provided by Dialect Holdings on the basis that you will treat
it as confidential.

No part of this document may be reproduced or copied in any form by any means
without the written permission of Dialect Holdings.  Unless otherwise expressly
agreed in writing, the information contained in this document is subject to
change without notice and Dialect Holdings assumes no responsibility for any
alteration to, or any error or other deficiency, in this document.

All intellectual property rights in the Document and in all extracts and things
derived from any part of the Document are owned by Dialect and will be assigned
to Dialect on their creation. You will protect all the intellectual property
rights relating to the Document in a manner that is equal to the protection
you provide your own intellectual property.  You will notify Dialect
immediately, and in writing where you become aware of a breach of Dialect's
intellectual property rights in relation to the Document.

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

Dialect does not indemnify you or any third party in relation to the content or
any use of the content as contemplated in these terms and conditions.

Mention of any product not owned by Dialect does not constitute an endorsement
of that product.

This document is governed by the laws of New South Wales, Australia and is
intended to be legally binding.

-------------------------------------------------------------------------------
 
This example assumes that a form has been sent to this example with the
required fields. The example then processes the command and displays the
receipt or error to a HTML page in the users web browser.

*****
NOTE:
*****
 
  For jdk1.2, 1.3
  * Must have jsse.jar, jcert.jar and jnet.jar in your classpath
  * Best approach is to make them installed extensions - 
    i.e. put them in the jre/lib/ext directory.

  For jdk1.4 (jsse is already part of default installation - should run fine)

--------------------------------------------------------------------------------

 @author Dialect Payment Solutions Pty Ltd Group 

------------------------------------------------------------------------------*/

--%>
<%@ page import="com.sun.net.ssl.*,
                 java.io.*,
                 java.net.*,
                 java.util.*,
                 java.security.MessageDigest,
                 java.security.cert.X509Certificate,
                 javax.net.ssl.SSLSocket,
                 javax.net.ssl.SSLSocketFactory,
                 com.sun.net.ssl.SSLContext,
                 com.sun.net.ssl.X509TrustManager"%>

<%! // Define Static Constants
    // ***********************
    public static X509TrustManager s_x509TrustManager = null;
    public static SSLSocketFactory s_sslSocketFactory = null;
    
    static {
            s_x509TrustManager = new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() { return new X509Certificate[] {}; } 
            public boolean isClientTrusted(X509Certificate[] chain) { return true; } 
            public boolean isServerTrusted(X509Certificate[] chain) { return true; } 
        };

        java.security.Security.addProvider(new com.sun.net.ssl.internal.ssl.Provider());
        try {
            SSLContext context = SSLContext.getInstance("TLS");
            context.init(null, new X509TrustManager[] { s_x509TrustManager }, null);
            s_sslSocketFactory = context.getSocketFactory();
        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException(e.getMessage());
        }
    }

//  ----------------------------------------------------------------------------

   /**
    * This method is for performing a Form POST operation from input data parameters.
    *
    * @param vpc_Host  - is a String containing the vpc URL
    * @param data      - is a String containing the post data key value pairs
    * @param useProxy  - is a boolean indicating if a Proxy Server is involved in the transfer
    * @param proxyHost - is a String containing the IP address of the Proxy to send the data to
    * @param proxyPort - is an integer containing the port number of the Proxy socket listener
    * @return          - is body data of the POST data response    
    */
    public static String doPost(String vpc_Host, String data,  
                  boolean useProxy, String proxyHost, int proxyPort) throws IOException {

        InputStream is;
        OutputStream os;
        int vpc_Port = 443; 
        String fileName = "";
        boolean useSSL = false;
        
        // determine if SSL encryption is being used
        if (vpc_Host.substring(0,8).equalsIgnoreCase("HTTPS://")) {
            useSSL= true;
            // remove 'HTTPS://' from host URL
            vpc_Host = vpc_Host.substring(8);
            // get the filename from the last section of vpc_URL
            fileName = vpc_Host.substring(vpc_Host.lastIndexOf("/"));
            // get the IP address of the VPC machine
            vpc_Host = vpc_Host.substring(0,vpc_Host.lastIndexOf("/"));
        }
        
        // use the next block of code if using a proxy server
        if (useProxy) {
            Socket s = new Socket(proxyHost, proxyPort);
            os = s.getOutputStream();
            is = s.getInputStream();
            // use next block of code if using SSL encryption
            if (useSSL) {
                String msg = "CONNECT " + vpc_Host + ":" + vpc_Port + " HTTP/1.0\r\n" + "User-Agent: HTTP Client\r\n\r\n";
                os.write(msg.getBytes());
                byte[] buf = new byte[4096];
                int len = is.read(buf);
                String res = new String(buf, 0, len);

                // check if a successful HTTP connection
                if (res.indexOf("200") < 0) {
                    throw new IOException("Proxy would now allow connection - " + res);
                }
                
                // write output to VPC
                SSLSocket ssl = (SSLSocket)s_sslSocketFactory.createSocket(s, vpc_Host, vpc_Port, true);
                ssl.startHandshake();
                os = ssl.getOutputStream();
                // get response data from VPC
                is = ssl.getInputStream();
            // use the next block of code if NOT using SSL encryption
            } else {
                fileName = vpc_Host;
            }
        // use the next block of code if NOT using a proxy server
        } else {
            // use next block of code if using SSL encryption
            if (useSSL) {
                Socket s = s_sslSocketFactory.createSocket(vpc_Host, vpc_Port);
                os = s.getOutputStream();
                is = s.getInputStream();
            // use next block of code if NOT using SSL encryption
            } else {
                Socket s = new Socket(vpc_Host, vpc_Port);
                os = s.getOutputStream();
                is = s.getInputStream();
            }
        }
        
        String req = "POST " + fileName + " HTTP/1.0\r\n"
                             + "User-Agent: HTTP Client\r\n"
                             + "Content-Type: application/x-www-form-urlencoded\r\n"
                             + "Content-Length: " + data.length() + "\r\n\r\n"
                             + data;

        os.write(req.getBytes());
        String res = new String(readAll(is));

        // check if a successful connection
        if (res.indexOf("200") < 0) {
            throw new IOException("Connection Refused - " + res);
        }
        
        if (res.indexOf("404 Not Found") > 0) {
            throw new IOException("File Not Found Error - " + res);
        }
        
        int resIndex = res.indexOf("\r\n\r\n");
        String body = res.substring(resIndex + 4, res.length());
        return body;
    }       

//  ----------------------------------------------------------------------------

   /**
    * This method is for creating a byte array from input stream data.
    *
    * @param is - the input stream containing the data
    * @return is the byte array of the input stream data    
    */
    private static byte[] readAll(InputStream is) throws IOException {
        
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        byte[] buf = new byte[1024];
        
        while (true) {
            int len = is.read(buf);
            if (len < 0) {
                break;
            }
            baos.write(buf, 0, len);
        }
        return baos.toByteArray();
    }

//  ----------------------------------------------------------------------------

   /**
    * This method is for creating a URL POST data string.
    *
    * @param fields is the input parameters from the order page
    * @return is the output String containing POST data key value pairs    
    */
    private String createPostDataFromMap(Map fields) {
        StringBuffer buf = new StringBuffer();

        String ampersand = "";

        // append all fields in a data string
        for (Iterator i = fields.keySet().iterator(); i.hasNext(); ) {
            
            String key = (String)i.next();
            String value = (String)fields.get(key);
            
            if ((value != null) && (value.length() > 0)) {
                // append the parameters
                buf.append(ampersand);
                buf.append(URLEncoder.encode(key));
                buf.append('=');
                buf.append(URLEncoder.encode(value));
            }
            ampersand = "&";
        }

        // return string 
        return buf.toString();    
    }

//  ----------------------------------------------------------------------------
   
   /**
    * This method is for creating a URL POST data string.
    *
    * @param queryString is the input String from POST data response
    * @return is a Hashmap of Post data response inputs    
    */
    private Map createMapFromResponse(String queryString) {
        Map map = new HashMap();
        StringTokenizer st = new StringTokenizer(queryString, "&");
        while (st.hasMoreTokens()) {
            String token = st.nextToken();
            int i = token.indexOf('=');
            if (i > 0) {
                try {
                    String key = token.substring(0, i);
                    String value = URLDecoder.decode(token.substring(i + 1, token.length()));
                    map.put(key, value);
                } catch (Exception ex) {
                    // Do Nothing and keep looping through data
                }
            }
        }
        return map;
    }
//  ----------------------------------------------------------------------------

   /*
    * This method takes a data String and returns a predefined value if empty
    * If data Sting is null, returns string "No Value Returned", else returns input
    *
    * @param in String containing the data String
    * @return String containing the output String
    */
    private static String null2unknown(String in, Map responseFields) {
      if (in == null || in.length() == 0 || (String)responseFields.get(in) == null) {
            return "No Value Returned";
        } else {
            return (String)responseFields.get(in);
        }
    } // null2unknown()
    
//  ----------------------------------------------------------------------------
    
   /*
    * This function uses the returned status code retrieved from the Digital
    * Response and returns an appropriate description for the code
    *
    * @param vResponseCode String containing the vpc_TxnResponseCode
    * @return description String containing the appropriate description
    */ 
    String getResponseDescription(String vResponseCode) {

        String result = "";

        // check if a single digit response code
        if (vResponseCode.length() > 0) {
        
            // Java cannot switch on a string so turn everything to a char
            char input = vResponseCode.charAt(0);

            switch (input){
                case '0' : result = "Transaction Successful"; break;
                case '1' : result = "Unknown Error"; break;
                case '2' : result = "Bank Declined Transaction"; break;
                case '3' : result = "No Reply from Bank"; break;
                case '4' : result = "Expired Card"; break;
                case '5' : result = "Insufficient Funds"; break;
                case '6' : result = "Error Communicating with Bank"; break;
                case '7' : result = "Payment Server System Error"; break;
                case '8' : result = "Transaction Type Not Supported"; break;
                case '9' : result = "Bank declined transaction (Do not contact Bank)"; break;
                case 'A' : result = "Transaction Aborted"; break;
                case 'C' : result = "Transaction Cancelled"; break;
                case 'D' : result = "Deferred transaction has been received and is awaiting processing"; break;
                case 'F' : result = "3D Secure Authentication failed"; break;
                case 'I' : result = "Card Security Code verification failed"; break;
                case 'L' : result = "Shopping Transaction Locked (Please try the transaction again later)"; break;
                case 'N' : result = "Cardholder is not enrolled in Authentication Scheme"; break;
                case 'P' : result = "Transaction has been received by the Payment Adaptor and is being processed"; break;
                case 'R' : result = "Transaction was not processed - Reached limit of retry attempts allowed"; break;
                case 'S' : result = "Duplicate SessionID (OrderInfo)"; break;
                case 'T' : result = "Address Verification Failed"; break;
                case 'U' : result = "Card Security Code Failed"; break;
                case 'V' : result = "Address Verification and Card Security Code Failed"; break;
                case '?' : result = "Transaction status is unknown"; break;
                default  : result = "Unable to be determined";
            }
            
            return result;
        } else {
            return "No Value Returned";
        }
    } // getResponseDescription()

//  ----------------------------------------------------------------------------

%><%// *******************************************
    // START OF MAIN PROGRAM
    // *******************************************

    // Define Variables
    // If using a proxy server you must set the following variables
    // If NOT using a proxy server then set the 'useProxy' to false
    boolean useProxy = true;
    String proxyHost = "192.168.21.13";
    int proxyPort = 80;

	// These fields are not returned in receipt for an error condition
	String transactionNo = request.getParameter("vpc_TransNo");
	String merchTxnRef   = request.getParameter("vpc_MerchTxnRef");

    // retrieve all the parameters into a hash map
    Map requestFields = new HashMap();
    for (Enumeration enum = request.getParameterNames(); enum.hasMoreElements();) {
        String fieldName = (String) enum.nextElement();
        String fieldValue = request.getParameter(fieldName);
        if ((fieldValue != null) && (fieldValue.length() > 0)) {
            requestFields.put(fieldName, fieldValue);
        }
    }
    
    // no need to send the vpcURL, Title and Submit Button to the vpc
    String vpcURL = (String) requestFields.remove("virtualPaymentClientURL");
    String title  = (String) requestFields.remove("Title");
    requestFields.remove("SubButL");
    
    // Retrieve the order page URL from the incoming order page. This is only  
    // here to give the user the easy ability to go back to the Order page. 
    // This would not be required in a production system.
    String againLink = request.getHeader("Referer");

    // create the post data string to send
    String postData = createPostDataFromMap(requestFields);

    String resQS = "";
    String message = "";

    try {
        // create a URL connection to the Virtual Payment Client
        resQS = doPost(vpcURL, postData, useProxy, proxyHost, proxyPort);

    } catch (Exception ex) {
        // The response is an error message so generate an Error Page
        message = ex.toString();
    } //try-catch

    // create a hash map for the response data
    Map responseFields = createMapFromResponse(resQS);

    // Extract the available receipt fields from the VPC Response
    // If not present then let the value be equal to 'No Value returned'
    // Not all data fields will return values for all transactions.

    // don't overwrite message if any error messages detected
    if (message.length() == 0) {
        message            = null2unknown("vpc_Message", responseFields);
    }

    // Standard Receipt Data
    String amount          = null2unknown("vpc_Amount", responseFields);
    String locale          = null2unknown("vpc_Locale", responseFields);
    String batchNo         = null2unknown("vpc_BatchNo", responseFields);
    String command         = null2unknown("vpc_Command", responseFields);
    String version         = null2unknown("vpc_Version", responseFields);
    String cardType        = null2unknown("vpc_Card", responseFields);
    String orderInfo       = null2unknown("vpc_OrderInfo", responseFields);
    String receiptNo       = null2unknown("vpc_ReceiptNo", responseFields);
    String merchantID      = null2unknown("vpc_Merchant", responseFields);
    String authorizeID     = null2unknown("vpc_AuthorizeId", responseFields);
    String transactionNr   = null2unknown("vpc_TransactionNo", responseFields);
    String acqResponseCode = null2unknown("vpc_AcqResponseCode", responseFields);
    String txnResponseCode = null2unknown("vpc_TxnResponseCode", responseFields);

    // Capture Data
    String shopTransNo     = null2unknown("vpc_ShopTransactionNo", responseFields);
    String authorisedAmount= null2unknown("vpc_AuthorisedAmount", responseFields);
    String capturedAmount  = null2unknown("vpc_CapturedAmount", responseFields);
    String refundedAmount  = null2unknown("vpc_RefundedAmount", responseFields);
    String ticketNumber    = null2unknown("vpc_TicketNo", responseFields);
    

    String error = "";
    // Show this page as an error page if error condition
    if (txnResponseCode.equals("7") || txnResponseCode.equals("No Value Returned")) {
        error = "Error ";
    }
        
    // FINISH TRANSACTION - Process the VPC Response Data
    // =====================================================
    // For the purposes of demonstration, we simply display the Result fields on a
    // web page.
%>  <!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
    <html>
    <head><title><%=title%> - VPC Response <%=error%>Page</title>
        <meta http-equiv='Content-Type' content='text/html, charset=iso-8859-1'>
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
    
    <center><h1><%=title%> - <%=error%>Response Page</H1></center>
    
    <table width="75%" align='center' cellpadding='5' border='0'>
      
        <tr class='title'>
            <td colspan="2" height="25"><p><b>&nbsp;Standard Transaction Fields</b></p></td>
        </tr>
        <tr>
            <td align='right' width='50%'><b><i>VPC API Version: </i></b></td>
            <td width='50%'><%=version%></td>
        </tr>
        <tr class='shade'>                  
            <td align='right'><b><i>Command: </i></b></td>
            <td><%=command%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Merchant Transaction Reference: </i></b></td>
            <td><%=merchTxnRef%></td>
        </tr>
        <tr class='shade'>
            <td align='right'><b><i>Merchant ID: </i></b></td>
            <td><%=merchantID%></td>
        </tr>
		<tr>
			<td align="right"><strong><i>Shopping Transaction Number: </i></strong></td>
			<td><%=transactionNo%></td>
		</tr>
        <tr class='shade'>
            <td align='right'><b><i>Capture Amount: </i></b></td>
            <td><%=amount%></td>
        </tr>
      
        <tr>
            <td colspan='2' align='center'><font color='#0074C4'>Fields above are the primary request values.<br/><hr/>
                Fields below are the response fields for a standard transaction.<br/></font></td>
        </tr>

      
        <tr class='shade'>                  
            <td align='right'><b><i>VPC Transaction Response Code: </i></b></td>
            <td><%=txnResponseCode%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Transaction Response Code Description: </i></b></td>
            <td><%=getResponseDescription(txnResponseCode)%></td>
        </tr>
        <tr class='shade'>                  
            <td align='right'><b><i>Message: </i></b></td>
            <td><%=message%></td>
        </tr>

<% // only display the following fields if not an error condition
if (!txnResponseCode.equals("7") && !txnResponseCode.equals("No Value Returned")) { %>

        <tr>
            <td align='right'><b><i>Receipt Number: </i></b></td>
            <td><%=receiptNo%></td>
        </tr>
        <tr class='shade'>                  
            <td align='right'><b><i>Capture Transaction Number: </i></b></td>
            <td><%=transactionNr%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Acquirer Response Code: </i></b></td>
            <td><%=acqResponseCode%></td>
        </tr>
        <tr class='shade'>                  
            <td align='right'><b><i>Bank Authorization ID: </i></b></td>
            <td><%=authorizeID%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Batch Number: </i></b></td>
            <td><%=batchNo%></td>
        </tr>
        <tr class='shade'>                  
            <td align='right'><b><i>Card Type: </i></b></td>
            <td><%=cardType%></td>
        </tr>
      
        <tr>
            <td colspan='2' align='center'><font color='#0074C4'>Fields above are for a standard transaction<br/><hr/>
                Fields below are additional fields for extra functionality.</font><br/></td>
        </tr>

        <tr class='title'>
            <td colspan="2" height="25"><p><b>&nbsp;Financial Transaction Fields</b></p></td>
        </tr>
      
        <tr>
            <td align='right'><b><i>Shopping Transaction Number: </i></b></td>
            <td><%=shopTransNo%></td>
        </tr>
        <tr class='shade'>
            <td align='right'><b><i>Authorised Amount: </i></b></td>
            <td><%=authorisedAmount%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Captured Amount: </i></b></td>
            <td><%=capturedAmount%></td>
        </tr>
        <tr class='shade'>
            <td align='right'><b><i>Refunded Amount: </i></b></td>
            <td><%=refundedAmount%></td>
        </tr>
        <tr>
            <td align='right'><b><i>Ticket Number: </i></b></td>
            <td><%=ticketNumber%></td>
        </tr>
<% } %>
    </table><br/>
    
    <center><P><A HREF='<%=againLink%>'>New Transaction</A></P></center>
    
    </body>
    </html>
