
README.TXT
==========

This ASP example code is written to show how transactions can be implemented 
using the Virtual Payment Client. 

All the example HTML files can be simply installed into any directory of the Web
Server's ROOT directory. 

The .asp file that will service the HTTP request is specified in 
the '<FORM ACTION="/xxx.asp" METHOD="post">' parameter of the input HTML file. 
 
This 'ACTION' value may have to be changed for your installation.

The initial HTML page passes control to the .asp script when the submit button 
on the HTML page is clicked.

The MerchantID and Merchant Access Code is that value given to you by your 
Payment Provider.

In 3-Party Mode the example talks about a 'secure-hash-secret' found in both the 
DO.asp and DR.asp files. This is an optional security measure to detect if 
customers interfere with the data while in transit through their browser. It is 
not used for 2-Party transactions as the 2Party.asp file communicates directly 
to the Virtual Payment Client and not through the customer's browser.

In 2-party mode the examples require MSMXML version 3.0 to be installed on the 
machine servicing the 2Party.asp file. You will find MSMXML 3.0 Service pack 2 
as part of this ASP example set.

There are different options here that may need to be commented/uncommented to 
work on your machine. This example is shipped with proxy enabled and a temporary 
SSL certificate disabled. 

author Dialect Solutions Group 2004
