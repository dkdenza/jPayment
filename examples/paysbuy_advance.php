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
$mp = Payment::factory('paysbuy_advance', array(
	'successUrl'    => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process",
	'backendUrl'    => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process"	
));

/**
 * Sandbox account
 *
 user : demo@paysbuy.com
 password : paysbuy123
 PSBID: 8303545188
 Secure Code: 1586093A8F80CBB5003001B42F0EEB7C
 
 user : example@paysbuy.com
 password : psb12345
 PSBID: 3687016837
 Secure Code:  B9350779BE7F822F9DF5033372E288CD
 */
$mp->setMerchantAccount(array(
	'merchantId' => "8303545188",
	'username'   => "demo@paysbuy.com",
	'secureCode' => "1586093A8F80CBB5003001B42F0EEB7C"
))->setSandboxMode(true);

/**
 * Set payment method (depend on your account)
 * Set force method (cannot change after submitted)
 */
$mp->setMethod('06')
	->setForceMethod(true);

/**
 * Custom gateway
 * Not work for all adapters
 */
$mp->setLanguage('TH')
	->setCurrency('THB');
	
/** 
 * Set billing 
 */
$mp->setInvoice('11111')
	->setPurpose('Buy Something')
	->setAmount(1);

/**
 * Set remark
 */
$mp->setRemark('Something to note.');
	
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
 * When gateway POSTED back with status
 */
if ($mp->isBackendPosted())
{
	$result = $mp->getBackendResult();
	$result = print_r($result, true);
	
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