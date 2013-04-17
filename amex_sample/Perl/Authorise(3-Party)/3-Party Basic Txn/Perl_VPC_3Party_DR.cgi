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

#-------------------------------------------------------------------------------

# Following is a copy of the disclaimer / license agreement provided by RSA:

# Copyright (C) 1991-2, RSA Data Security, Inc. Created 1991. All rights
# reserved.

# License to copy and use this software is granted provided that it is 
# identified as the "RSA Data Security, Inc. MD5 Message-Digest Algorithm" in 
# all material mentioning or referencing this software or this function.

# License is also granted to make and use derivative works provided that such 
# works are identified as "derived from the RSA Data Security, Inc. MD5 
# Message-Digest Algorithm" in all material mentioning or referencing the 
# derived work.

# RSA Data Security, Inc. makes no representations concerning either the 
# merchantability of this software or the suitability of this software for any 
# particular purpose. It is provided "as is" without express or implied warranty 
# of any kind.

# These notices must be retained in any copies of any part of this documentation 
# and/or software.

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
use Digest::MD5 qw(md5_hex);
#use diagnostics;

# Define Constants
# ----------------
# This is secret for encoding the MD5 hash
# This secret will vary from merchant to merchant
# To not create a secure hash, let SECURE_SECRET be an empty string - ""
# my $SECURE_SECRET = "secure-hash-secret";
my $SECURE_SECRET = "";

# Define Variables
# ----------------
my $perl_cgi        = new CGI;
my %params          = $perl_cgi->Vars;
my $md5HashData     = "";
my $vpc_Txn_Secure_Hash = "";
my $hash_Validation;

# Sub Prototypes
# --------------
# Displays the Response for this transaction
sub displayReceipt ($$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$);

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


#######################
# START OF MAIN PROGRAM
# =====================
#######################

# If there has been a merchant secret set then sort and loop through all the
# data in the Virtual Payment Client response. While we have the data, we can
# append all the fields that contain values (except the secure hash) so that
# we can create a hash and validate it against the secure hash in the Virtual
# Payment Client response.

# NOTE: If the vpc_TxnResponseCode in not a single character then
# there was a Virtual Payment Client error and we cannot accurately validate
# the incoming data from the secure hash.

# remove the vpc_TxnResponseCode code from the response fields as we do not want
# to include this field in the hash calculation
$vpc_Txn_Secure_Hash = delete($params{'vpc_SecureHash'});

# set a flag to indicate if hash has been validated
my $md5keys = "";
my $hashErrorExists = 0;

if (length($SECURE_SECRET) > 0 and $params{'vpc_TxnResponseCode'} ne "7" and $params{'vpc_TxnResponseCode'} ne "No Value Returned") {

    $md5HashData = $SECURE_SECRET;
    my $key = "";
    # sort all the incoming vpc response fields and leave out any with no value
    foreach $key (sort keys %params) {
        if ($key ne "vpc_Secure_Hash" or length($params{$key}) > 0) {
            $md5HashData .= $params{$key};
            $md5keys .= ($key)
        }
    }
    
    # Validate the Secure Hash (remember MD5 hashes are not case sensitive)
    if (uc $vpc_Txn_Secure_Hash eq uc md5_hex($md5HashData)) {
        # Secure Hash validation succeeded, add a data field to be displayed
        # later.
        $hash_Validation = "<font color='#00AA00'><strong>CORRECT</strong></font>";
    } else {
        # Secure Hash validation failed, add a data field to be displayed
        # later.
        $hash_Validation = "<font color='#FF0066'><strong>INVALID HASH</strong></font>";
        $hashErrorExists = 1;
    }
    # Add the merchant secret to the data so that we will display it
    $params{'Merchant_Secret'} = $SECURE_SECRET;
} else {
    # Secure Hash was not validated, 
    $hash_Validation = "<font color='orange'><strong>Not Calculated - No 'SECURE_SECRET' present.</strong></font>";
}

# Extract the available receipt fields from the VPC Response
# If not present then let the value be equal to 'No Value Returned'
my $title     = null2unknown($params{'Title'});
my $againLink = null2unknown($params{'AgainLink'});

# Standard Receipt Data
my $amount          = null2unknown($params{'vpc_Amount'});
my $locale          = null2unknown($params{'vpc_Locale'});
my $batchNo         = null2unknown($params{'vpc_BatchNo'});
my $command         = null2unknown($params{'vpc_Command'});
my $message         = null2unknown($params{'vpc_Message'});
my $version         = null2unknown($params{'vpc_Version'});
my $cardType        = null2unknown($params{'vpc_Card'});
my $orderInfo       = null2unknown($params{'vpc_OrderInfo'});
my $receiptNo       = null2unknown($params{'vpc_ReceiptNo'});
my $merchantID      = null2unknown($params{'vpc_Merchant'});
my $authorizeID     = null2unknown($params{'vpc_AuthorizeId'});
my $merchTxnRef     = null2unknown($params{'vpc_MerchTxnRef'});
my $transactionNo   = null2unknown($params{'vpc_TransactionNo'});
my $acqResponseCode = null2unknown($params{'vpc_AcqResponseCode'});
my $txnResponseCode = null2unknown($params{'vpc_TxnResponseCode'});

# CSC Receipt Data
my $vCSCResultCode  = null2unknown($params{'vpc_CSCResultCode'});
my $vCSCRequestCode = null2unknown($params{'vpc_CSCRequestCode'});
my $vACQCSCRespCode = null2unknown($params{'vpc_AcqCSCRespCode'});

# AVS Receipt Data
my $vAVS_City       = null2unknown($params{'vpc_AVS_City'});
my $vAVS_Country    = null2unknown($params{'vpc_AVS_Country'});
my $vAVS_Street01   = null2unknown($params{'vpc_AVS_Street01'});
my $vAVS_PostCode   = null2unknown($params{'vpc_AVS_PostCode'});
my $vAVS_StateProv  = null2unknown($params{'vpc_AVS_StateProv'});
my $vAVSResultCode  = null2unknown($params{'vpc_AVSResultCode'});
my $vAVSRequestCode = null2unknown($params{'vpc_AVSRequestCode'});
my $vACQAVSRespCode = null2unknown($params{'vpc_AcqAVSRespCode'});

# 3-D Secure Data
my $verType        = null2unknown($params{'vpc_VerType'});
my $verStatus      = null2unknown($params{'vpc_VerStatus'});
my $token           = null2unknown($params{'vpc_VerToken'});
my $verSecurLevel  = null2unknown($params{'vpc_VerSecurityLevel'});
my $enrolled       = null2unknown($params{'vpc_3DSenrolled'});
my $xid               = null2unknown($params{'vpc_3DSXID'});
my $acqECI           = null2unknown($params{'vpc_3DSECI'});
my $authStatus       = null2unknown($params{'vpc_3DSstatus'});

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
                $orderInfo,
                $receiptNo,
                $merchantID,
                $authorizeID,
                $merchTxnRef,
                $transactionNo,
                $acqResponseCode,
                $txnResponseCode,
                $vCSCResultCode,
                $vCSCRequestCode,
                $vACQCSCRespCode,
                $vAVS_City,
                $vAVS_Country,
                $vAVS_Street01,
                $vAVS_PostCode,
                $vAVS_StateProv,
                $vAVSResultCode,
                $vAVSRequestCode,
                $vACQAVSRespCode,
                $verType,
                $verStatus,
                $token,
                $verSecurLevel,
                $enrolled,
                $xid,
                $acqECI,
                $authStatus,
                $hash_Validation,
                $hashErrorExists);


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
# @param $transactionNo VPC Response value 'vpc_TransactionNo'
# @param $acqResponseCode VPC Response value 'vpc_AcqResponseCode'
# @param $txnResponseCode VPC Response value 'vpc_TxnResponseCode'
# @param $cscResultCode contains the VPC Response value 'vpc_CSCResultCode'
# @param $cscRequestCode contains the VPC Response value 'vpc_CSCRequestCode'
# @param $cscACQRespCode contains the VPC Response value 'vpc_AcqCSCRespCode'
# @param $avs_City contains the VPC Response value 'vpc_AVS_City'
# @param $avs_Country contains the VPC Response value 'vpc_AVS_Country'
# @param $avs_Street01 contains the VPC Response value 'vpc_AVS_Street01'
# @param $avs_PostCode contains the VPC Response value 'vpc_AVS_PostCode'
# @param $avs_StateProv contains the VPC Response value 'vpc_AVS_StateProv'
# @param $avsResultCode contains the VPC Response value 'vpc_AVSResultCode'
# @param $avsRequestCode contains the VPC Response value 'vpc_AVSRequestCode'
# @param $avsACQRespCode contains the VPC Response value 'vpc_AcqAVSRespCode'
# @param $verType contains the VPC Response value 'vpc_VerType'
# @param $verStatus contains the VPC Response value 'vpc_VerStatus'
# @param $token contains the VPC Response value 'vpc_VerToken'
# @param $verSecurLevel contains the VPC Response value 'vpc_VerSecurityLevel'
# @param $enrolled contains the VPC Response value 'vpc_3DSenrolled'
# @param $xid contains the VPC Response value 'vpc_3DSXID'
# @param $acqECI contains the VPC Response value 'vpc_3DSECI'
# @param $authStatus contains the VPC Response value 'vpc_3DSstatus'
# @param $hashValidated is the display status of the MD5 secure hash comparison
#
sub displayReceipt ($$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$) {
    my ($title,
        $againLink,
        $amount,
        $locale,
        $batchNo,
        $command,
        $message,
        $version,
        $cardType,
        $orderInfo,
        $receiptNo,
        $merchantID,
        $authorizeID,
        $merchTxnRef,
        $transactionNo,
        $acqResponseCode,
        $txnResponseCode,
        $cscResultCode,
        $cscRequestCode,
        $cscACQRespCode,
        $avs_City,
        $avs_Country,
        $avs_Street01,
        $avs_PostCode,
        $avs_StateProv,
        $avsResultCode,
        $avsRequestCode,
        $avsACQRespCode,
        $verType,
        $verStatus,
        $token,
        $verSecurLevel,
        $enrolled,
        $xid,
        $acqECI,
        $authStatus,
        $hashValidated,
        $hashErrorExists)    = @_;

    my $errorTxt = "";

    # Show this page as an error page if vpc_TxnResponseCode ne '0'
    if ($txnResponseCode ne "0" or $hashErrorExists eq 1) {
        $errorTxt = "Error"
    }
    
    print $perl_cgi->header(-expires=>'0', pragma=>'no-cache', cache=>'no-cache');
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
    "    <table width='85%' align='center' cellpadding='5' border='0'>\n",
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Basic Transaction Fields</strong></p></td>\n",
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
    "            <td align='right'><strong><i>Order Information: </i></strong></td>\n",
    "            <td>", $orderInfo, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Purchase Amount: </i></strong></td>\n",
    "            <td>", $amount, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td colspan='2' align='center'>\n",
    "                <font color='#0074C4'>Fields above are the primary request values.<br />\n",
    "                <HR />\n",
    "                Fields below are the response fields for a standard 2-Party Transaction.<br /></font>\n",
    "            </td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>VPC Transaction Response Code: </i></strong></td>\n",
    "            <td>", $txnResponseCode, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Transaction Response Code Description: </i></strong></td>\n",
    "            <td>", getResponseDescription($txnResponseCode), "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Message: </i></strong></td>\n",
    "            <td>", $message, "</td>\n",
    "        </tr>\n";
 
    # only display the following fields if not an error condition
    if ($txnResponseCode ne "7" and $txnResponseCode ne "No Value Returned") { 

    print
    "        <tr>\n",
    "            <td align='right'><strong><i>Receipt Number: </i></strong></td>\n",
    "            <td>", $receiptNo, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Transaction Number: </i></strong></td>\n",
    "            <td>", $transactionNo, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Acquirer Response Code: </i></strong></td>\n",
    "            <td>", $acqResponseCode, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Bank Authorization ID: </i></strong></td>\n",
    "            <td>", $authorizeID, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Batch Number: </i></strong></td>\n",
    "            <td>", $batchNo, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Card Type: </i></strong></td>\n",
    "            <td>", $cardType, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td colspan='2' align='center'>\n",
    "                <font color='#0074C4'>Fields above are for a standard 2-Party Transaction<br />\n",
    "                <HR />\n",
    "                Fields below are additional fields for extra functionality.</font><br />\n",
    "            </td>\n",
    "        </tr>\n",
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Card Security Code Fields</strong></p></td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>CSC Request Code: </i></strong></td>\n",
    "            <td>", $vCSCRequestCode, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>CSC Acquirer Response Code: </i></strong></td>\n",
    "            <td>", $vACQCSCRespCode, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>CSC QSI Result Code: </i></strong></td>\n",
    "            <td>", $vCSCResultCode, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>CSC Result Description: </i></strong></td>\n",
    "            <td>", displayCSCResponse($vCSCResultCode), "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td colspan='2'><HR /></td>\n",
    "        </tr>\n",
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Address Verification Service Fields</strong></p></td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>AVS Street/Postal Address: </i></strong></td>\n",
    "            <td>", $vAVS_Street01, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>AVS City/Town/Suburb: </i></strong></td>\n",
    "            <td>", $vAVS_City, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>AVS State/Province: </i></strong></td>\n",
    "            <td>", $vAVS_StateProv, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>AVS Postal/Zip Code: </i></strong></td>\n",
    "            <td>", $vAVS_PostCode, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>AVS Country Code: </i></strong></td>\n",
    "            <td>", $vAVS_Country, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>AVS Request Code: </i></strong></td>\n",
    "            <td>", $vAVSRequestCode, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>AVS Acquirer Response Code: </i></strong></td>\n",
    "            <td>", $vACQAVSRespCode, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>AVS QSI Result Code: </i></strong></td>\n",
    "            <td>", $vAVSResultCode, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>AVS Result Description: </i></strong></td>\n",
    "            <td>", displayAVSResponse($vAVSResultCode), "</td>\n",
    "        <tr>\n",
    "            <td colspan='2'><HR /></td>\n",
    "        </tr>\n",
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;3-D Secure Fields</strong></p></td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Unique 3DS transaction identifier: </i></strong></td>\n",
    "            <td class='red'>", $xid, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>3DS Authentication Verification Value: </i></strong></td>\n",
    "            <td class='red'>", $token, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>3DS Electronic Commerce Indicator: </i></strong></td>\n",
    "            <td class='red'>", $acqECI, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>3DS Authentication Scheme: </i></strong></td>\n",
    "            <td class='red'>", $verType, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>3DS Security level used in the AUTH message: </i></strong></td>\n",
    "            <td class='red'>", $verSecurLevel, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'>\n",
    "                <strong><i>3DS CardHolder Enrolled: </strong>\n",
    "                <br />\n",
    "                <font size='1'>Takes values: <strong>Y</strong> - Yes <strong>N</strong> - No</i></font>\n",
    "            </td>\n",
    "            <td class='red'>", $enrolled, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'>\n",
    "                <i><strong>Authenticated Successfully: </strong><br />\n",
    "                <font size='1'>Only returned if CardHolder Enrolled = <strong>Y</strong>. Takes values:<br />\n",
    "                <strong>Y</strong> - Yes <strong>N</strong> - No <strong>A</strong> - Attempted to Check <strong>U</strong> - Unavailable for Checking</font></i>\n",
    "            </td>\n",
    "            <td class='red'>", $authStatus, "</td>\n",
    "        </tr>\n",
    "        <tr class='shade'>\n",
    "            <td align='right'><strong><i>Payment Server 3DS Authentication Status Code: </i></strong></td>\n",
    "            <td class='green'>", $verStatus, "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><i><strong>3DS Authentication Status Code Description: </strong></i></td>\n",
    "            <td class='green'>", get3DSstatusDescription($verStatus), "</td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td colspan='2' align='center' valign='middle'>\n",
    "                <font color='#FF0066'><br/>The 3-D Secure values shown in red are those values that are important values to store in case of future transaction repudiation.</font>\n",
    "            </td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td colspan='2' align='center' valign='middle'>\n",
    "                <font color='#00AA00'>The 3-D Secure values shown in green are for information only and are not required to be stored.</font>\n",
    "            </td>\n",
    "        <tr>\n",
    "            <td colspan='2'><HR /></td>\n",
    "        </tr>\n",
    "        </tr>\n";
    "        <tr class='title'>\n",
    "            <td colspan='2' height='25'><p><strong>&nbsp;Hash Validation</strong></p></td>\n",
    "        </tr>\n",
    "        <tr>\n",
    "            <td align='right'><strong><i>Hash Validated Correctly: </i></strong></td>\n",
    "            <td>", $hashValidated, "</td>\n",
    "        </tr>\n",
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
    my %qsiResponse     = (
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

    if (defined($responseCode) and exists $qsiResponse{$responseCode}) {
        return $qsiResponse{$responseCode};
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
        if ($statusResponse eq "" or $statusResponse eq "No Value Returned") {
            return "3DS not supported or there was no 3DS data provided";
        } else {
            return $statusResult{$statusResponse};
        }
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
    } elsif (length($in) eq 0) {
        return "No Value Returned";
    } else {
        return $in;
    }
} # null2unknown()

#  -----------------------------------------------------------------------------
