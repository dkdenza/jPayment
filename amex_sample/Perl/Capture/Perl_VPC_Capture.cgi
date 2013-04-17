#!/usr/bin/perl -w

# Version 3.1

#---------------- Disclaimer ---------------------------------------------------

# Copyright 2004 Dialect Solutions Holdings.  All rights reserved.

# This document is provided by Dialect Solutions Holdings on the basis that you
# will treat it as confidential.

# No part of this document may be reproduced or copied in any form by any means
# without the written permission of Dialect Solutions Holdings.  Unless otherwise
# expressly agreed in writing, the information contained in this document is
# subject to change without notice and Dialect Solutions Holdings assumes no
# responsibility for any alteration to, or any error or other deficiency, in this
# document.

# All intellectual property rights in the Document and in all extracts and things
# derived from any part of the Document are owned by Dialect and will be assigned
# to Dialect on their creation. You will protect all the intellectual property
# rights relating to the Document in a manner that is equal to the protection you
# provide your own intellectual property.  You will notify Dialect immediately,
# and in writing where you become aware of a breach of Dialect's intellectual
# property rights in relation to the Document.

# The names "Dialect", "QSI Payments" and all similar words are trademarks of
# Dialect Solutions Holdings and you must not use that name or any similar name.

# Dialect may at its sole discretion terminate the rights granted in this document
# with immediate effect by notifying you in writing and you will thereupon return
# (or destroy and certify that destruction to Dialect) all copies and extracts of
# the Document in its possession or control.

# Dialect does not warrant the accuracy or completeness of the Document or its
# content or its usefulness to you or your merchant customers. To the extent
# permitted by law, all conditions and warranties implied by law (whether as to
# fitness for any particular purpose or otherwise) are excluded.  Where the
# exclusion is not effective, Dialect limits its liability to AU$100 or the
# resupply of the Document (at Dialect's option).

# Data used in examples and sample data files are intended to be fictional and any
# resemblance to real persons or companies is entirely coincidental.

# Dialect does not indemnify you or any third party in relation to the content or
# any use of the content as contemplated in these terms and conditions.

# Mention of any product not owned by Dialect does not constitute an endorsement
# of that product.

# This document is governed by the laws of New South Wales, Australia and is
# intended to be legally binding.

# ------------------------------------------------------------------------------

# This program assumes that a URL has been sent to this example with the
# required fields. The example then processes the command and displays the
# receipt or error to a HTML page in the users web browser.

# ------------------------------------------------------------------------------

# NOTE:
# =====
# You may have to run Perl Package Manager (PPM) to download and install the 
# crypt=SSLeay package on your Perl web server to run this example.

# @author Dialect Payment Solutions Pty Ltd Group 

# ------------------------------------------------------------------------------

# Initialisation
# ==============
# Use the required Perl Libraries
# -------------------------------
use strict;
use CGI;
use diagnostics;
use LWP::UserAgent;

# Define Variables
# ----------------
my $perl_cgi = new CGI;
my %params   = $perl_cgi->Vars;
my $postData = "";
my $appendAmp = 0;

# Sub Prototypes
# --------------
# Displays the Response for this transaction
sub displayReceipt ($$$$$$$$$$$$$$$$$$$$$$);

# Determines the appropriate description for the transaction response
sub getResponseDescription ($);

# Determines the appropriate description for the AVS response
sub displayAVSResponse($);

# Determines the appropriate description for the CSC response
sub displayCSCResponse($);

# Determines the appropriate description for the Authentication response
sub get3DSstatusDescription($);

# Inserts a value when an empty String is returned in the response
sub null2unknown ($);

# splits a string of data into an array
sub splitResponse($);

# HTTP encodes a data string 
sub urlencode($);

# HTTP decodes a data string
sub urldecode($);

#######################
# START OF MAIN PROGRAM
# =====================
#######################

# tell the program where to output print data
print $perl_cgi->header(-expires=>'0', pragma=>'no-cache', cache=>'no-cache');

# This is the URL link for another transaction
# This shows how a user field (such as an application sessionID) could be added
my $againLink = $ENV{'HTTP_REFERER'};

# get the title and the Virtual Payment Client URL
my $title = $params{'Title'};
my $vpcURL = $params{'virtualPaymentClientURL'};

# These fields are not returned in receipt for an error condition
my $transactionNo = $params{'vpc_TransNo'};
my $merchTxnRef   = $params{'vpc_MerchTxnRef'};

# no need to send these control fields to the Virtual Payment Client
delete($params{'Title'});
delete($params{'SubButL'});
delete($params{'virtualPaymentClientURL'});

# setup internal program variables
my $key = "";
my $ampersand = "";

# create the post data String for sending to the VPC
foreach $key (keys %params) {
    
    # do not include empty fields
    if (length($params{$key}) > 0) {
        
        # URL encode the key & field values for the URL
        my $encKeyValue = urlencode($key);

        my $encFieldValue = urlencode($params{$key});
        $postData .= $ampersand . $encKeyValue . '=' . $encFieldValue;
        $ampersand = "&";
    }
}

# You may have to run Perl Package Manager (PPM) to download and install the 
# crypt-SSLeay package on your Perl web server to run this example.
# We found this one at: http://theoryx5.uwinnipeg.ca/ppmpackages/
# package - Crypt-SSLeay.ppd
my $ua = LWP::UserAgent->new;

# debug - uncomment this to display the debug messaging for this operation.
#$ENV{HTTPS_DEBUG} = 1;

# Set the proxy server if required.
# Use proxy $ENV for SSL 
# You would need to add you own proxy server URL here
$ENV{HTTPS_PROXY} = 'http://192.168.21.13:80';

# Use proxy ua for Non SSL
# $ua->proxy('http' => 'http://192.168.21.13');

# certificate validation
# If you want to validate the Virtual Payment Client certificate you will need 
# to point to where it is installed in your computer.
#$ENV{HTTPS_CA_FILE}   = 'C:/Temp/66vpcdps.cer';

# set up the POST operation to the Virtual Patment Client
my $request = HTTP::Request->new(POST => $vpcURL);
$request->content_type('application/x-www-form-urlencoded');
$request->content($postData);

# retrieve the response from the Virual Payment Client
my $response = $ua->request($request);

# create a hash map to hold the response data
my %respParams;

# prepare a variable to hold any error messages
my $message = "";

# Check the outcome of the response
if ($response->is_success) {
    # if a success then put the output into the hash map
    $response->content;
    %respParams = splitResponse($response->content);
    # retrieve the message
    $message = null2unknown($respParams{'vpc_Message'});
} else {
    # if an error then put the error data into the message field
    $message = $response->error_as_HTML;
}

# Retrieve all possible transaction response data

# Standard Receipt Data
my $amount          = null2unknown($respParams{'vpc_Amount'});
my $locale          = null2unknown($respParams{'vpc_Locale'});
my $batchNo         = null2unknown($respParams{'vpc_BatchNo'});
my $command         = null2unknown($respParams{'vpc_Command'});
my $version         = null2unknown($respParams{'vpc_Version'});
my $cardType        = null2unknown($respParams{'vpc_Card'});
my $orderInfo       = null2unknown($respParams{'vpc_OrderInfo'});
my $receiptNo       = null2unknown($respParams{'vpc_ReceiptNo'});
my $merchantID      = null2unknown($respParams{'vpc_Merchant'});
my $authorizeID     = null2unknown($respParams{'vpc_AuthorizeId'});
   $merchTxnRef     = null2unknown($respParams{'vpc_MerchTxnRef'});
my $transactionNr   = null2unknown($respParams{'vpc_TransactionNo'});
my $acqResponseCode = null2unknown($respParams{'vpc_AcqResponseCode'});
my $txnResponseCode = null2unknown($respParams{'vpc_TxnResponseCode'});

# AMA Transaction Data
my $shopTransNo     = null2unknown($respParams{'vpc_ShopTransactionNo'});
my $authorisedAmount= null2unknown($respParams{'vpc_AuthorisedAmount'});
my $capturedAmount  = null2unknown($respParams{'vpc_CapturedAmount'});
my $refundedAmount  = null2unknown($respParams{'vpc_RefundedAmount'});
my $ticketNumber    = null2unknown($respParams{'vpc_TicketNo'});

# FINISH TRANSACTION - Process the VPC Response Data
# =====================================================
# For the purposes of demonstration, we simply display the Result fields on a
# web page.
displayReceipt ($title,
                $againLink,
                $amount,
                $locale,
                $batchNo,
                $command,
                $message,
                $version,
                $cardType,
                $receiptNo,
                $merchantID,
                $authorizeID,
                $merchTxnRef,
                $transactionNo,
                $transactionNr,
                $acqResponseCode,
                $txnResponseCode,
                $shopTransNo,
                $authorisedAmount,
                $capturedAmount,
                $refundedAmount,
                $ticketNumber);

exit;


#####################
# END OF MAIN PROGRAM
# ===================
#####################


# This method marks up and displays the simple HTML receipt page with the
# results provided by the input paramenters. After displaying the receipt
# processing is stopped.
#
# @param $title - This is the basic title for the Response page
# @param $againLink - This is the URL link back to the order page
# @param $amount VPC Response value 'vpc_Amount'
# @param $locale VPC Response value 'vpc_Locale'
# @param $batchNo VPC Response value 'vpc_BatchNo'
# @param $command VPC Response value 'vpc_Command'
# @param $message VPC Response value 'vpc_Message'
# @param $version VPC Response value 'vpc_Version'
# @param $cardType VPC Response value 'vpc_Card'
# @param $orderInfo VPC Response value 'vpc_OrderInfo'
# @param $receiptNo VPC Response value 'vpc_ReceiptNo'
# @param $merchantID VPC Response value 'vpc_Merchant'
# @param $authorizeID VPC Response value 'vpc_AuthorizeId'
# @param $merchTxnRef VPC Response value 'vpc_MerchTxnRef'
# @param $transactionNo requested Shopping TransactionNo
# @param $transactionNr VPC Response value 'vpc_TransactionNo'
# @param $acqResponseCode VPC Response value 'vpc_AcqResponseCode'
# @param $txnResponseCode VPC Response value 'vpc_TxnResponseCode'
# @param $shopTransNo contains the VPC Response value 'vpc_ShopTransactionNo'
# @param $authorisedAmount contains the VPC Response value 'vpc_AuthorisedAmount'
# @param $capturedAmount contains the VPC Response value 'vpc_CapturedAmount'
# @param $refundedAmount contains the VPC Response value 'vpc_RefundedAmount'
# @param $ticketNumber contains the VPC Response value 'vpc_TicketNo'
#
sub displayReceipt ($$$$$$$$$$$$$$$$$$$$$$) {
    my ($title,
        $againLink,
        $amount,
        $locale,
        $batchNo,
        $command,
        $message,
        $version,
        $cardType,
        $receiptNo,
        $merchantID,
        $authorizeID,
        $merchTxnRef,
        $transactionNo,
        $transactionNr,
        $acqResponseCode,
        $txnResponseCode,
        $shopTransNo,
        $authorisedAmount,
        $capturedAmount,
        $refundedAmount,
        $ticketNumber)    = @_;

    # Define an AMA transaction output for Refund & Capture transactions
    my $amaTransaction = "1";
    if ($shopTransNo eq "No Value Returned") {
        $amaTransaction = "0";
    }
    
    # Show this page as an error page if vpc_TxnResponseCode ne '0'
    my $errorTxt = "";
    if ($txnResponseCode ne "0" or $txnResponseCode eq "No Value Returned") {
        $errorTxt = "Error"
    }
    
    print
    "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>\n",
    "<html>\n",
    "<!-- ---- Copyright -------------------------------------------------------\n",
    " (c)2003 Copyright QSI Payments, Inc. - All Rights Reserved\n",
    " Copyright Statement: http://www.qsipayments.com/copyright/Payment_Client\n",
    "----------------------------------------------------------------------- -->\n",
    "<head><title>", $title, "</title>\n",
    "<meta http-equiv='Content-Type' content='text/html, charset=iso-8859-1'>\n",
    "<style type='text/css'>\n",
    "    <!--\n",
    "    h1       { font-family:Arial,sans-serif; font-size:20pt; font-weight:600; margin-bottom:0.1em; color:#08185A;}\n",
    "    h2       { font-family:Arial,sans-serif; font-size:14pt; font-weight:100; margin-top:0.1em; color:#08185A;}\n",
    "    h2.co    { font-family:Arial,sans-serif; font-size:24pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#08185A}\n",
    "    h3       { font-family:Arial,sans-serif; font-size:16pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#08185A}\n",
    "    h3.co    { font-family:Arial,sans-serif; font-size:16pt; font-weight:100; margin-top:0.1em; margin-bottom:0.1em; color:#FFFFFF}\n",
    "    body     { font-family:Verdana,Arial,sans-serif; font-size:10pt; background-color:#FFFFFF; color:#08185A}\n",
    "    th       { font-family:Verdana,Arial,sans-serif; font-size:8pt; font-weight:bold; background-color:#CED7EF; padding-top:0.5em; padding-bottom:0.5em;  color:#08185A}\n",
    "    tr       { height:25px; }\n",
    "    .shade   { height:25px; background-color:#CED7EF }\n",
    "    .title   { height:25px; background-color:#0074C4 }\n",
    "    td       { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A }\n",
    "    td.red   { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#FF0066 }\n",
    "    td.green { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#008800 }\n",
    "    p        { font-family:Verdana,Arial,sans-serif; font-size:10pt; color:#FFFFFF }\n",
    "    p.blue   { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#08185A }\n",
    "    p.red    { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#FF0066 }\n",
    "    p.green  { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#008800 }\n",
    "    div.bl   { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#0074C4 }\n",
    "    div.red  { font-family:Verdana,Arial,sans-serif; font-size:7pt;  color:#FF0066 }\n",
    "    li       { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#FF0066 }\n",
    "    input    { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:bold }\n",
    "    select   { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:bold; }\n",
    "    textarea { font-family:Verdana,Arial,sans-serif; font-size:8pt;  color:#08185A; background-color:#CED7EF; font-weight:normal; scrollbar-arrow-color:#08185A; scrollbar-base-color:#CED7EF }\n",
    "    -->\n",
    "</style></head>\n",
    "<body>\n",
    "<!-- Start Branding Table -->\n",
    "    <table width='100%' border='2' cellpadding='2' class='title'>\n",
    "        <tr>\n",
    "            <td class='shade' width='90%'><h2 class='co'>&nbsp;Virtual Payment Client Example</h2></td>\n",
    "            <td class='title' align='center'><h3 class='co'>Dialect<br />Solutions</h3></td>\n",
    "        </tr>\n",
    "    </table>\n",
    "    <!-- End Branding Table -->\n",
    "    <center><h1>", $title, " - $errorTxt Response Page</h1></center>\n",
    "    <table width='75%' align='center' cellpadding='5' border='0'>\n",
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Basic Capture Transaction Fields</strong></p></td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right' width='50%'><strong><i>VPC API Version: </i></strong></td>\n",
    "            <td width='50%'>", $version, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Command: </i></strong></td>\n",
    "            <td>", $command, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Merchant Transaction Reference: </i></strong></td>\n",
    "            <td>", $merchTxnRef, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Merchant ID: </i></strong></td>\n",
    "            <td>", $merchantID, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Shopping Transaction Number: </i></strong></td>\n",
    "            <td>", $transactionNo, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Capture Amount: </i></strong></td>\n",
    "            <td>", $amount, "</td>\n",
    "        </tr>\n",
    "        <tr><td colspan = '2' align='center'><font color='#0074C4'>Fields above are the primary request values.<br/>\n",
    "                <hr/>Fields below are the response fields for a standard transaction.<br /></font>\n",
    "            </td></tr>\n",
      

    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Standard Transaction Response Fields</strong></p></td>\n",
    "        </tr>\n",

    "        <tr>\n",
    "            <td align='right'><strong><i>VPC Transaction Response Code: </i></strong></td>\n",
    "            <td>", $txnResponseCode, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Transaction Response Code Description: </i></strong></td>\n",
    "            <td>", getResponseDescription($txnResponseCode), "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Message: </i></strong></td>\n",
    "            <td>", $message, "</td>\n",
    "        </tr>\n";
    # only display the following fields if not an error condition
    if ($txnResponseCode ne "7" and $txnResponseCode ne "No Value Returned") { 

        print
        "        <tr class='shade'>\n",
        "            <td align='right'><strong><i>Receipt Number: </i></strong></td>\n",
        "            <td>", $receiptNo, "</td>\n",
        "        </tr>\n",
        "        <tr>\n",
        "            <td align='right'><strong><i>Capture Transaction No: </i></strong></td>\n",
        "            <td>", $transactionNr, "</td>\n",
        "        </tr>\n",
        "        <tr class='shade'>\n",
        "            <td align='right'><strong><i>Acquirer Response Code: </i></strong></td>\n",
        "            <td>", $acqResponseCode, "</td>\n",
        "        </tr>\n",
        "        <tr>\n",
        "            <td align='right'><strong><i>Bank Authorization ID: </i></strong></td>\n",
        "            <td>", $authorizeID, "</td>\n",
        "        </tr>\n",
        "        <tr class='shade'>\n",
        "            <td align='right'><strong><i>Batch Number: </i></strong></td>\n",
        "            <td>", $batchNo, "</td>\n",
        "        </tr>\n",
        "        <tr>\n",
        "            <td align='right'><strong><i>Card Type: </i></strong></td>\n",
        "            <td>", $cardType, "</td>\n",
        "        </tr>\n",

        "        <tr>\n",
        "            <td colspan='2' align='center'>\n",
        "                <font color='#0074C4'>Fields above are a standard transaction response<br />\n",
        "                <HR />\n",
        "                Fields below are additional fields for AMA functionality.</font><br />\n",
        "            </td>\n",
        "        </tr>\n",
        "        <tr class='title'>\n",
        "            <td colspan='2' height='25'><p><strong>&nbsp;Financial Transaction Fields</strong></p></td>\n",
        "        </tr>\n",
        "        <tr>\n",
        "            <td align='right'><strong><i>Shopping Transaction Number: </i></strong></td>\n",
        "            <td>", $shopTransNo, "</td>\n",
        "        </tr>\n",
        "        <tr class='shade'>\n",
        "            <td align='right'><strong><i>Authorised Amount: </i></strong></td>\n",
        "            <td>", $authorisedAmount, "</td>\n",
        "        </tr>\n",
        "        <tr>\n",                
        "            <td align='right'><strong><i>Captured Amount: </i></strong></td>\n",
        "            <td>", $capturedAmount, "</td>\n",
        "        </tr>\n",
        "        <tr class='shade'>\n",
        "            <td align='right'><strong><i>Refunded Amount: </i></strong></td>\n",
        "            <td>", $refundedAmount, "</td>\n",
        "        </tr>\n",
        "        <tr>\n",                  
        "            <td align='right'><strong><i>Ticket Number: </i></strong></td>\n",
        "            <td>", $ticketNumber, "</td>\n",
        "        </tr>\n";

    }
    print
    "    </table>\n",
    "    <center><p><a href='", $againLink, "'>New Transaction</a></p></center>\n",
    "</body>\n",
    "</html>\n";
}

#  ----------------------------------------------------------------------------

# This subroutine uses the QSI Response code retrieved from the Digital
# Receipt and returns an appropriate description for the QSI Response Code

# @param $responseCode String containing the QSI Response Code

# @return String containing the appropriate description

sub getResponseDescription ($) {
    my ($responseCode)  = @_;
    my %txnResponse     = (
        0  => "Transaction Successful",
       '?' => "Transaction status is unknown",
        1  => "Unknown Error",
        2  => "Bank Declined Transaction",
        3  => "No Reply from Bank",
        4  => "Expired Card",
        5  => "Insufficient funds",
        6  => "Error Communicating with Bank",
        7  => "Payment Server System Error",
        8  => "Transaction Type Not Supported",
        9  => "Bank declined transaction (Do not contact Bank)",
        A  => "Transaction Aborted",
        C  => "Transaction Cancelled",
        D  => "Deferred transaction has been received and is awaiting processing",
        F  => "3D Secure Authentication failed",
        I  => "Card Security Code verification failed",
        L  => "Shopping Transaction Locked (Please try the transaction again later)",
        N  => "Cardholder is not enrolled in Authentication scheme",
        P  => "Transaction has been received by the Payment Adaptor and is being processed",
        R  => "Transaction was not processed - Reached limit of retry attempts allowed",
        S  => "Duplicate SessionID (OrderInfo)",
        T  => "Address Verification Failed",
        U  => "Card Security Code Failed",
        V  => "Address Verification and Card Security Code Failed");

    if (defined($responseCode) and exists $txnResponse{$responseCode}) {
        return $txnResponse{$responseCode};
    } else {
        return "Unable to be determined";
    }
}

#  ----------------------------------------------------------------------------

# This subroutine uses the AVS Response code retrieved from the Digital
# Receipt and returns an appropriate description for the AVS Response Code
#
# @param $responseCode String containing the AVS Response Code
#
# @return String containing the appropriate description
sub displayAVSResponse ($) {
    my ($resultCode) = @_;
    my %avsResult    = (
        Unsupported => "AVS not supported or there was no AVS data provided",
        X => "Exact match - address and 9 digit ZIP/postal code",
        Y => "Exact match - address and 5 digit ZIP/postal code",
        S => "Service not supported or address not verified (international transaction)",
        G => "Issuer does not participate in AVS (international transaction)",
        A => "Address match only.",
        W => "9 digit ZIP/postal code matched, Address not Matched",
        Z => "5 digit ZIP/postal code matched, Address not Matched",
        R => "Issuer system is unavailable",
        U => "Address unavailable or not verified",
        E => "Address and ZIP/postal code not provided",
        N => "Address and ZIP/postal code not matched",
        0 => "AVS not requested");

    if (defined($resultCode) and exists $avsResult{$resultCode}) {
        return $avsResult{$resultCode};
    } else {
        return "Unable to be determined";
    }
}

#  ----------------------------------------------------------------------------

# This subroutine uses the CSC Response code retrieved from the Digital
# Receipt and returns an appropriate description for the CSC Response Code
#
# @param $responseCode String containing the CSC Response Code
#
# @return String containing the appropriate description
sub displayCSCResponse ($) {
    my ($resultCode) = @_;
    my %cscResult = (
        Unsupported => "CSC not supported or there was no CSC data provided",
        M => "Exact code match",
        S => "Merchant has indicated that CSC is not present on the card (MOTO situation)",
        P => "Code not processed",
        U => "Card issuer is not registered and/or certified",
        N => "Code invalid or not matched");

    if (defined($resultCode) and exists $cscResult{$resultCode}) {
        return $cscResult{$resultCode};
    } else {
        return "Unable to be determined";
    }
}

#  ----------------------------------------------------------------------------

# This subroutine uses the CSC Response code retrieved from the Digital
# Receipt and returns an appropriate description for the CSC Response Code
#
# @param $responseCode String containing the CSC Response Code
#
# @return String containing the appropriate description
sub get3DSstatusDescription ($) {
    my ($statusResponse) = @_;
    my %statusResult = (
        Y => "The cardholder was successfully authenticated.",
        E => "The cardholder is not enrolled.",
        N => "The cardholder was not verified.",
        U => "The cardholder's Issuer was unable to authenticate due to some system error at the Issuer.",
        F => "There was an error in the format of the request from the merchant.",
        A => "Authentication of your Merchant ID and Password to the ACS Directory Failed.",
        D => "Error communicating with the Directory Server.  ",
        C => "The card type is not supported for authentication.",
        S => "The signature on the response received from the Issuer could not be validated.",
        P => "Error parsing input from Issuer.",
        I => "Internal Payment Server system error.");

    if (defined($statusResponse) and exists $statusResult{$statusResponse}) {
        return $statusResult{$statusResponse};
    } else {
        return "Unable to be determined";
    }
}

#  ----------------------------------------------------------------------------

# This subroutine takes a data String and returns a predefined value if empty
# If data Sting is null, returns string "No Value Returned", else returns input

# @param $in String containing the data String

# @return String containing the output String

sub null2unknown($) {
    my ($in)  = @_;
    if (!defined($in)) {
        return "No Value Returned";
    } else {
        return $in;
    }
} # null2unknown()

#  -----------------------------------------------------------------------------

# This subroutine takes a string and splits it into an array

# @param data containing the String to split into key value pairs

# @return array of key value pairs

sub splitResponse($) {
    my ($data) = @_;
    my %respParams = ();

    my @pairsArray = split(/&/, $data);

    foreach my $pair (@pairsArray) {
        (my $name, my $value) = split(/=/, $pair, 2);
        $respParams{urldecode($name)} = urldecode($value);

    }
    return %respParams;
}

#  -----------------------------------------------------------------------------

# This subroutine takes a string and HTTP encodes it for URL transamission

# @param data String containing the String to URL encode

# @return String URL encoded

sub urlencode($) {
    my ($encValue) = @_;
    $encValue =~s/([^a-zA-Z0-9\x20_.-])/uc sprintf("%%%02x",ord($1))/eg;
    $encValue =~s/ /'+'/eg;
    return $encValue;
}

#  -----------------------------------------------------------------------------

# This subroutine takes a string and HTTP decodes it for use

# @param data String containing the URL encoded String

# @return String URL decoded

sub urldecode($) {
    my ($decValue) = @_;
    $decValue =~ tr/+/ /;
    $decValue =~ s/%(\w\w)/sprintf("%c", hex($1))/ge; # convert hex to ascii
    return $decValue;
}

#  -----------------------------------------------------------------------------
