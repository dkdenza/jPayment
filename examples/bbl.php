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
 * @version    1.0b
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
	'failUrl'    => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process",
	'backendUrl' => "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI']."?action=process"	
));

/**
 * Bbl we need to set both merchant and terminal
 */
$mp->setMerchantAccount(array(
	'merchantId' => "1347"
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
	
$mp->setMethod('CC');

if ($mp->isSuccessPosted()) 
{
	$result = $mp->getFrontendResult();
	echo "<pre>".print_r($result, true)."</pre>";
	exit(0);
}

if ($mp->isFailPosted()) 
{
	echo "Reject from gateway, so what next?";
	exit(0);
}

if ($mp->isCancelPosted()) 
{
	echo "User canceled or Gateway rejected, so do something.";
	exit(0);
}

if ($mp->isBackendPosted()) 
{
	//echo "Data feed from gateway.";
	$result = $mp->getBackendResult();
	echo "<pre>".print_r($result, true)."</pre>";
	
	// Bbl need text "OK" to response to data feed.
	echo "OK";
	exit(0);
}

$mp->setAny('ref1', "Sub Ref1");
$mp->setAny('ref2', "Sub Ref2");
$mp->setAny('ref3', "Sub Ref3");
$mp->setAny('ref4', "Sub Ref4");
$mp->setAny('ref5', "Sub Ref5");


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
			function onDocumentReady() {
				document.getElementById('form-gateway').submit();
			}
		</script>
	</head>
	<body onload="onDocumentReady();">
		<h3>Waiting to redirect...</h3>
		<?php echo $mp->render(array(
			'cardNo'       => "4918914107195005",
			'securityCode' => 123
		)); ?>
	</body>
</html>