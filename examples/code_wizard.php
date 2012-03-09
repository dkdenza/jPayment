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
 * Include config
 */
require_once('config.inc.php');

/**
 * Grab base url
 */
$current_url = "http://".$_SERVER['HTTP_HOST'].$_SERVER['REQUEST_URI'];
@list($base_url, $query) = explode('?', $current_url);

/**
 * Adapter config
 */
$adapterConfig = array(
	'paypal' => array(
		'name' => "Paypal",
		'options' => array(
			'sandboxMode'     => true,
			'merchantAccount' => "buyer_1279773230_per@jquerytips.com",
			'successUrl'      => $base_url."?action=progress",
			'cancelUrl'       => $base_url."?action=progress",
			'backendUrl'      => $base_url."?action=progress",
			'language'        => "TH",
			'currency'        => "THB"
		)
	),
	'paysbuy' => array(
		'name' => "Paysbuy",
		'options' => array(
			'sandboxMode'     => true,
			'merchantAccount' => "demo@paysbuy.com",
			'successUrl'      => $base_url."?action=progress",
			'backendUrl'      => $base_url."?action=progress",
			'language'        => "TH",
			'currency'        => "THB"
		)
	),
	'paysbuy_advance' => array(
		'name' => "Paysbuy API",
		'options' => array(
			'sandboxMode'     => true,
			'merchantAccount' => array(
				'merchantId' => "8303545188",
				'username'   => "demo@paysbuy.com",
				'secureCode' => "1586093A8F80CBB5003001B42F0EEB7C"
			),
			'successUrl'      => $base_url."?action=progress",
			'backendUrl'      => $base_url."?action=progress",
			'language'        => "TH",
			'currency'        => "THB"
		)
	),
	'kbank' => array(
		'name' => "Kasikorn Bank",
		'options' => array(
			'sandboxMode'     => false,
			'merchantAccount' => array(
				'merchantId' => "[MERCHANT ID]",
				'terminalId' => "[TERMINAL ID]"
			),
			'successUrl'      => $base_url."?action=progress",
			'backendUrl'      => $base_url."?action=progress",
			'language'        => "TH",
			'currency'        => "THB"
		)
	),
	'bbl' => array(
		'name' => "Bangkok Bank",
		'options' => array(
			'sandboxMode'     => false,
			'merchantAccount' => array(
				'merchantId'     => "[MERCHANT ID]"
			),
			'successUrl'      => $base_url."?action=progress",
			'cancelUrl'       => $base_url."?action=progress",
			'failUrl'         => $base_url."?action=progress",
			'backendUrl'      => $base_url."?action=progress",
			'language'        => "TH",
			'currency'        => "THB"
		)
	)
);

/**
 * @var action 
 */
$action = isset($_GET['action']) ? $_GET['action'] : null;

/**
 * Multi payment variable
 */
$mp = null;

/**
 * Action progress 
 */
if ($action == 'progress')
{
	$adapter = $_POST['gateway'];
	$options = $adapterConfig[$adapter]['options'];
	
	$amount = $_POST['amount'];
	
	$mp = Payment::factory($adapter, $options);
	
	$mp->setInvoice('1O000'.rand(1, 99999))
	->setPurpose('Payment')
	->setAmount($amount);
	
	if ($mp->isSuccessPosted()) {
		$result = $mp->getFrontendResult();
		exit(0);
	}
	
	if ($mp->isCancelPosted()) {
		exit(0);
	}
	
	if ($mp->isFailPosted()) {
		exit(0);
	}
	
	if ($mp->isBackendPosted()) {
		$result = $mp->getFrontendResult();
		file_put_contents('log-'.time().'.txt', print_r($result, true));
		exit(0);
	}
}


?>
<!DOCTYPE html>
<html>
	<head>
		<title>jQueryTips.com: Payment Gateway</title>
		<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
		<style type="text/css">
			html, body { font-family:verdana; font-size:12px; }
			label.title { float:left; display:block; width: 120px; }
			p.clearfix { clear:both; }
			#code { width: 800px; height: 350px; }
		</style>
	</head>
	<body>		
		<form method="post" action="?action=progress">
			<p class="clearfix">
				<label class="title">Select a Gateway:</label>
				<select name="gateway">
					<?php foreach ($adapterConfig as $adapter => $val) : ?>
					<option value="<?php echo $adapter; ?>"<?php if (@$_POST['gateway'] == $adapter) echo " selected"; ?>>
						<?php echo $val['name']; ?>
					</option>
					<?php endforeach; ?>
				</select>
			</p>
			<p class="clearfix">
				<label class="title">Amount:</label>
				<input type="text" name="amount" value="<?php echo (isset($_POST['amount'])) ? $_POST['amount'] : 1; ?>" />
				<span class="currency">THB</span>
			</p>
			<p class="clearfix">
				<input type="submit" value="Pay Now" />
			</p>
		</form>
		<?php if (is_object($mp)) : ?>
		<h4>Code:</h4>
		<p>
			<textarea id="code"><?php echo trim($mp->render()); ?></textarea>
		</p>
		<?php endif; ?>
	</body>
</html>