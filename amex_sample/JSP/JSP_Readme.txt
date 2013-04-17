
README.TXT
==========

This JSP example code is written to show how transactions can be implemented 
using the Virtual Payment Client. 

The example HTML files can be simply installed into any directory of the Web
Server's ROOT directory. 

The xxx.jsp files must be saved in the appropriate directory that services 
php scripts. The .jsp file that will service the HTTP request is specified in 
the '<form action="/xxx.jsp" method="post">' parameter of the input HTML file. 
 
This 'ACTION' value may have to be changed for your installation.

The initial HTML page passes control to the .jsp script when the submit button 
on the HTML page is clicked.

The MerchantID and Merchant Access Code is that value given to you by your 
Payment Provider.

In 3-Party Mode the example talks about a 'secure-hash-secret' found in both the 
DO.jsp and DR.jsp files. This is an optional security measure to detect if 
customers interfere with the data while in transit through their browser. It is 
not used for 2-Party transactions as the 2Party.jsp file communicates directly 
to the Virtual Payment Client and not through the customer's browser.

In 2-party mode the correct Java libraries need to be installed on the 
machine servicing the 2Party.jsp file. 

  For jdk1.2, 1.3
  * Must have jsse.jar, jcert.jar and jnet.jar in your classpath
  * Best approach is to make them installed extensions - 
    i.e. put them in the jre/lib/ext directory.

  For jdk1.4 (jsse is already part of default installation - should run fine)

There are different options here that may need to be commented/uncommented to 
work on your machine. This example is shipped with proxy enabled and a temporary 
SSL certificate disabled. 

author Dialect Solutions Group 2004
