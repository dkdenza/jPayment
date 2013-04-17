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

my $vpcURL          = $params{'virtualPaymentClientURL'};
my $md5HashData     = "";

# Sub Prototypes
# --------------
# Performs a customer browser redirect of the transaction data
sub doRedirect ($);

#######################
# START OF MAIN PROGRAM
# =====================
#######################

# This is the URL link for another transaction
# This shows how a user field (such as an application sessionID) could be added
$params{AgainLink} = $ENV{'HTTP_REFERER'};

# Create the request to the Virtual Payment Client which is a URL encoded GET
# request. Since we are looping through all the data we may as well sort it in
# case we want to create a secure hash and add it to the VPC data if the
# merchant secret has been provided.
my $key = "";
my $appendAmp = 0;
$md5HashData = $SECURE_SECRET;

# check all optional fields and remove them from the array if not required
if (exists($params{'EnableCardTypeData'})) {
	delete($params{"vpc_CardType"});
	delete($params{"vpc_Gateway"});
}

# remove any AVS data fields if EnableAVS data is unchecked
if (exists($params{'EnableAVSdata'})) {
	delete($params{"vpc_AVS_Street01"});
	delete($params{"vpc_AVS_City"});
	delete($params{"vpc_AVS_StateProv"});
	delete($params{"vpc_AVS_PostCode"});
	delete($params{"vpc_AVS_Country"});
	delete($params{"vpc_AVSLevel"});
}

# no need to send the vpc url, EnableAVSdata and submit button to the vpc
delete($params{"virtualPaymentClientURL"});
delete($params{"SubButL"});
delete($params{"EnableAVSdata"});
delete($params{"EnableCardTypeData"});

# Retrieve the order page URL from the incoming order page and add it to 
# the hash map. This is only here to give the user the easy ability to go 
# back to the Order page. This would not be required in a production system
# NB. Other merchant application fields that you want returned to the 
# applicationcan be added in the same manner
my $againLink = $ENV{'HTTP_REFERER'};

# add the againLink to the Hash Map
%params = (%params, "AgainLink", $againLink);

# sort the hash map for the creation of the secure hash code
foreach $key (sort keys %params) {
    # create the md5 input and URL leaving out any fields that have no value
	if (length($params{$key}) > 0) {
		
		$md5HashData .= $params{$key};
		
		# URL encode the key & field values for the URL
		my $encKeyValue = $key;
		$encKeyValue =~s/([^a-zA-Z0-9\x20_.-])/uc sprintf("%%%02x",ord($1))/eg;
		$encKeyValue =~s/ /'+'/eg;

		my $encFieldValue = $params{$key};
		$encFieldValue =~s/([^a-zA-Z0-9\x20_.-])/uc sprintf("%%%02x",ord($1))/eg;
		$encFieldValue =~s/ /'+'/eg;


		# this ensures the first paramter of the URL is preceded by the '?' char
		if ($appendAmp == 0) {
			$vpcURL .= '?' . $encKeyValue . '=' . $encFieldValue;
			$appendAmp = 1;
		} else {
			$vpcURL .= '&' . $encKeyValue . "=" . $encFieldValue;
		}
    }
}

# Create the secure hash and append it to the Virtual Payment Client Data if
# the merchant secret has been provided.
if (length($SECURE_SECRET) > 0) {
    $vpcURL .= "&vpc_Txn_Secure_Hash=" . md5_hex($md5HashData);
}

# FINISH TRANSACTION - Redirect the customers using the Digital Order
doRedirect ($vpcURL);

# *******************
# END OF MAIN PROGRAM
# *******************

#  -----------------------------------------------------------------------------

# This subroutine marks up and displays the simple HTML redirect page.
# The browser is redirected using the tag:
#     <meta HTTP-EQUIV='Refresh' CONTENT='0;URL=$vpcURL'>
# This method will display the complete HTML page to the customers browser to
# perform the redirection.

# @param $digitalOrder String containing the Digital Order

sub doRedirect ($) {
    my ($vpcURL) = @_;
    my $redirectTitle = "Virtual Payment Client Redirect Page";

    # The Digital Order is sent using a Meta refresh to send the customers
    # browser to the Payment Server with the Digital Order.
    # The tag used to perform the redirect is
    # "<meta HTTP-EQUIV='Refresh' CONTENT='0;URL=$digitalOrder'>"
    # We now mark up and display the complete HTML page that we use to perform
    # this simple redirection.
    print $perl_cgi->header(-expires=>'0', pragma=>'no-cache', cache=>'no-cache');
    print
    "<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>\n",
    "<html>\n",
    "<head><title>", $redirectTitle, "</title>\n",
    "<meta http-equiv='Content-Type' content='text/html, charset=iso-8859-1'>\n",
    "<meta HTTP-EQUIV='Refresh' CONTENT='0;URL=$vpcURL'>",
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
    "<table width='100%' border='2' cellpadding='2' class='title'><tr><td class='shade' width='90%'><h2 class='co'>&nbsp;Virtual Payment Client Example</h2></td><td class='title' align='center'><h3 class='co'>Dialect<br/>Solutions</h3></td></tr></table>\n",
    "<!-- End Branding Table -->\n",
    "<center><h1><br/>", $redirectTitle, "</H1></center>\n",
    "<table width='70%' align='center' border='0' cellpadding='10'><tr><td align='center'>\n",
    "<br/>The Digital Order has been generated and your browser\n",
    " is being redirected to process your order.</BR>\n",
    "<strong>If your browser does not go to the payment site within 30 \n",
    "seconds <A HREF='", $vpcURL, "'>Click Here</A>.</strong>\n",
    "</td></tr>\n",
    "</table>\n",
    "</body></html>";
}

#  -----------------------------------------------------------------------------
