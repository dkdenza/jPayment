<?php
/**
 * Payment
 *
 * This source file is subject to the new BSD license that is bundled
 * It is also available through the world-wide-web at this URL:
 * http://www.jquerytips.com/
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to admin@jquerytips.com so we can send you a copy immediately.
 *
 * @category   Payment
 * @package    Payment
 * @copyright  Copyright (c) 2005-2011 jQueryTips.com
 * * @version    1.0.1
 */

/**
 * Contact BBL Officer
 * Tel: 02-626-3025
 */

/**
 * Include config
 */
require_once('config.inc.php');

/**
 * Instance payment class
 */
$mp = Payment::factory('bbl', array(
	'successUrl' => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process",
	'cancelUrl'  => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process",
	'failUrl'    => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process"
));

/**
 * Set URL to feed data 
 * To enable this feature you need to contect BBL directly 
 */
$mp->setBackendUrl('http://'.$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'].'?action=process');

/**
 * Bbl we need to set both merchant and terminal
 */
$mp->setMerchantAccount(array(
	'merchantId' => "[YOUR MERCHANT ID]"
));

/**
 * Bbl allow to set interface and currency
 */
$mp->setLanguage('TH')
	->setCurrency('THB');

/** 
 * Set billing 
 */
$mp->setInvoice('10000071')
	->setPurpose('Buy Something')
	->setAmount(1);
	
/**
 * Set method payment CC, ALL
 */
$mp->setMethod('CC');

/**
 * Set remark
 */
$mp->setRemark('Something like note');

/**
 * Set ref maximum is 5 [option]
 */
$mp->setAny('ref1', "Sub Ref1");
$mp->setAny('ref2', "Sub Ref2");
$mp->setAny('ref3', "Sub Ref3");
$mp->setAny('ref4', "Sub Ref4");
$mp->setAny('ref5', "Sub Ref5");

/**
 * When gateway redirect back with success status
 */	
if ($mp->isSuccessPosted()) 
{
	$result = $mp->getFrontendResult();
	echo "<pre>".print_r($result, true)."</pre>";
	exit(0);
}

/**
 * When gateway redirect back with fail status
 */
if ($mp->isFailPosted()) 
{
	echo "Reject from gateway, so what next?";
	exit(0);
}

/**
 * When gateway POSTED back with cancel status
 */
if ($mp->isCancelPosted()) 
{
	echo "User canceled or Gateway rejected, so do something.";
	exit(0);
}

/**
 * When gateway POSTED back with feed data returned
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