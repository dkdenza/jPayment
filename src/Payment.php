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
 * @category   Payment
 * @package    Payment
 * @copyright  Copyright (c) 2005-2011 jQueryTips.com
 * @version    1.0.1
 */

require_once('Payment/Exception.php');

class Payment {

	/**
	 * Factory Instance
	 * 
	 * @access public
	 * @static
	 * @param string $adapter
	 * @param array $params (option)
	 * @return object class
	 */
	public static function factory($adapter, $opts=array())
	{
		$adapter = str_replace('_', ' ', $adapter);
		$adapter = str_replace(' ', '_', ucwords($adapter));

		$adapterPath = "Payment/Adapter/".$adapter.".php";
		$adapterName = "Payment_Adapter_".$adapter;
	
		try {
			include_once($adapterPath);		
		} catch (Exception $e) {
			throw new Payment_Exception('Can\'t load payment adapter "'.$adapterName.'"', 0, $e);
		}		
		
		return new $adapterName($opts);
	}
	
}

?>