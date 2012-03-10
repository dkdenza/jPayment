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

interface Payment_Adapter_AdapterInterface {
	
	/**
	 * Construct the adapter
	 */
	public function __construct($opts=array());
	
	/**
	 * Enable sandbox API
	 */
	public function setSandboxMode($val);
	
	/**
	 * Get the status sandbox mode
	 */
	public function getSandboxMode();
		
	/**
	 * Transform payment fields and build to array
	 */
	public function build($opts=array());
	
	/**
	 * Render the HTML payment Form
	 */
	public function render($opts=array());
	
	/**
	 * Get post frontend result from API gateway
	 */
	public function getFrontendResult();
	
	/**
	 * Get post backend result from API gateway
	 */
	public function getBackendResult();

}

?>