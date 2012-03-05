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

require_once('AdapterAbstract.php');

class Payment_Adapter_Kbank extends Payment_Adapter_AdapterAbstract {
	
	/**
	 * Define Gateway name
	 */
	const GATEWAY = "Kbank";
	
	/**
	 * Define security hash prefix
	 */
	const HASHSUM = "DEFINE_SECURITY";
	
	/**
	 * Merchant ID
	 */
	private $_merchantId;
	
	/**
	 * Terminal ID
	 */
	private $_terminalId;
	
	/**
	 * @var Gateway URL
	 */
	protected $_gatewayUrl = "https://rt05.kasikornbank.com/pgpayment/payment.aspx";
	
	/**
	 * @var mapping to transfrom parameter from gateway
	 */
	protected $_defaults_params = array(
		'MERCHANT2'   => "",
		'TERM2'       => "",
		'AMOUNT2'     => "",
		'URL2'        => "",
		'RESPURL'     => "",
		'IPCUST2'     => "",
		'DETAIL2'     => "",
		'INVMERCHANT' => "",
		'FILLSPACE'   => "Y",
		'CHECKSUM'    => ""
	);

	/**
	 * Construct the payment adapter
	 * 
	 * @access public
	 * @param  array $params (default: array())
	 * @return void
	 */
	public function __construct($params=array())
	{
		parent::__construct($params);
	}
	
	/**
	 * Set to enable sandbox mode
	 * [NOTICE] Kbank doesn't implement sandbox yet!
	 * 
	 * @access public
	 * @param  bool 
	 * @return object class (chaining)
	 */
	public function setSandboxMode($val)
	{
		$this->_sandbox = $val;
		return $this;
	}
	
	/**
	 * Get sandbox enable
	 * [NOTICE] Kbank doesn't implement sandbox yet!
	 * 
	 * @access public
	 * @return bool
	 */
	public function getSandboxMode()
	{
		return $this->_sandbox;
	}
	
	/**
	 * Set gateway merchant
	 * Kbank using merchant instead of email
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setMerchantId($val)
	{
		$this->_merchantId = $val;
		return $this;
	}
	
	/**
	 * Get gateway merchant
	 * 
	 * @access public
	 * @return string
	 */
	public function getMerchantId()
	{
		return $this->_merchantId;
	}
	
	/**
	 * Set gateway terminal
	 * Kbank using terms instead of config interface
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setTerminalId($val)
	{
		$this->_terminalId = $val;
		return $this;
	}
	
	/**
	 * Get gateway term
	 * 
	 * @access public
	 * @return string
	 */
	public function getTerminalId()
	{
		return $this->_terminalId;
	}
	
	/**
	 * Build array data and mapping from API
	 * 
	 * @access public
	 * @param  array $extends (default: array())
	 * @return array
	 */
	public function build($extends=array())
	{
		$amount = $this->_amount * 100;
		$crumbs = md5(self::HASHSUM.$this->_invoice);
		$pass_parameters = array(
			'MERCHANT2'   => $this->_merchantId,
			'TERM2'       => $this->_terminalId,
			'INVMERCHANT' => $this->_invoice,
			'DETAIL2'     => $this->_purpose,
			'AMOUNT2'     => $amount,
			'URL2'        => $this->_successUrl,
			'RESPURL'     => $this->_backendUrl,
			'IPCUST2'     => $_SERVER['REMOTE_ADDR'],
			'CHECKSUM'    => $crumbs
		);
		$params = array_merge($pass_parameters, $extends);
		$build_data = array_merge($this->_defaults_params, $params);
		return $build_data;
	}
	
	/**
	 * Render from data with hidden fields
	 * 
	 * @access public
	 * @param  array $attrs (default: array())
	 * @return string HTML
	 */
	public function render($attrs=array())
	{
		// make webpage language
		$data = $this->build($attrs);
		return $this->_makeFormPayment($data);
	}
	
	/**
	 * Get a post back result from API gateway
	 * POST data from API
	 * 
	 * @access public
	 * @return array (POST)
	 */
	public function getFrontendResult()
	{		
		// not implement yet.
	}
	
	/**
	 * Get data posted to background process.
	 * Kbank need only trust SSL to return data feed.
	 * 
	 * @access public
	 * @return array
	 */
	public function getBackendResult()
	{		
		// not implement yet.
		//$crumbs = md5(self::HASHSUM.$this->_invoice);
	}
		
}

?>