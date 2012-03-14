<?php
/**
 * jPayment Gateway
 *
 * This source file is subject to the new BSD license that is bundled
 * It is also available through the world-wide-web at this URL:
 * http://www.jquerytips.com/
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to admin@jquerytips.com so we can send you a copy immediately.
 *
 * @copyright  Copyright (c) 2011 - 2012 jQueryTips (http://www.jquerytips.com)
 * @version    1.0.1
 */

/**
 * Include config
 */
require_once('config.inc.php');

/**
 * Instance payment class
 */
$mp = Payment::factory('kbank', array(
	'successUrl' => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process",
	'backendUrl' => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process"
));

/**
 * Kbank we need to set both merchant and terminal
 */
$mp->setMerchantAccount(array(
	'merchantId' => "[YOUR MERCHANT ID]",
	'terminalId' => "[YOUR TERMINAL ID]"
));

/** 
 * Set billing 
 */
$mp->setInvoice('987677')
	->setPurpose('Buy Something')
	->setAmount(1);
	
/**
 * Set method accept (credit, debit)
 */
$mp->setMethod('credit');
	
/**
 * When gateway redirect back with success status
 */	
if ($mp->isSuccessPosted())
{
	echo "<h1>Success Posted, just redirect the user to thank you page.</h1>";
	
	$result = $mp->getFrontendResult();
	echo "<pre>".print_r($result, true)."</pre>";
	
	exit(0);
}

/**
 * When gateway redirect back with cancel status
 */
if ($mp->isCancelPosted())
{
	echo "<h1>Cancel Posted, just redirect the user to sorry page.</h1>";
	exit(0);
}

/**
 * When gateway POSTED back with feed data returned
 */
 
// Suppose feed data from gateway
/*$_POST['PMGWRESP'] = '05XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX00000000015114032012152305000000000500XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXMASTERCARDXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX764XXXXXXXXXXXX';*/
if ($mp->isBackendPosted())
{

	$result = $mp->getBackendResult();
	$result = print_r($result, true);
	
	echo $result; exit;
	
	$logfile = "../logs/".date('Y-m-d_H-i-s').".log";
	file_put_contents($logfile, $result);
	
	echo "OK";
	exit(0);
}

?>
<!DOCTYPE html>
<html>
	<head>
		<title>Redirecting to Payment Gateway</title>
		<style type="text/css">
			html, body { font-family: verdana; font-size: 12px; }
			h3 { font-size: 1em; font-weight: normal; }
		</style>
		<script type="text/javascript">
			function paynow() {
				document.getElementById('form-gateway').submit();
			}
			
			function onDocumentReady() {
				setTimeout(function() {
					paynow();
				}, 20000);
			}			
		</script>
	</head>
	<body onload="onDocumentReady();">
		<h3>Waiting 20 seconds to redirect.</h3>
		<?php echo $mp->render(); ?>
		<a href="javascript:paynow();">Pay Now</a>
	</body>
</html>