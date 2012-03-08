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

class Payment_Adapter_Paysbuy_Advance extends Payment_Adapter_AdapterAbstract {
	
	/**
	 * Define Gateway name
	 */
	const GATEWAY = "Paysbuy Advance";
	
	/**
	 * @var Merchant ID
	 */
	private $_merchantId;
	
	/**
	 * @var Username 
	 */
	private $_username;
	
	/**
	 * @var Secure Code 
	 */
	private $_secureCode;
	
	/**
	 * @var Payment Method
	 */
	private $_method = "01";
	
	/**
	 * @var Force method 
	 */
	protected $_forceMethod = 0;
	
	/**
	 * @var Gateway authenticate URL
	 */
	protected $_gatewayAuthUrl = "http://www.paysbuy.com/api_paynow/api_paynow.asmx/api_paynow_authentication_new";
	
	/**
	 * @var Gateway URL
	 */
	protected $_gatewayUrl = "http://www.paysbuy.com/paynow.aspx";
	
	/**
	 * @var Check payment transaction (available only paysbuy)
	 */
	protected $_checkUrl = "https://www.paysbuy.com/getinvoicestatus/getinvoicestatus.asmx/GetInvoice";
	
	/**
	 * @var mapping to transfrom parameter from gateway
	 */
	protected $_defaults_params = array(
		'psbID'            => "",
		'username'         => "",
		'secureCode'       => "",
		'curr_type'        => "TH",
		'com'              => "",
		'method'           => "01",
		'opt_fix_method'   => 0,
		'opt_fix_redirect' => 0,
		'language'         => "T",
		'inv'              => "",
		'itm'              => "",
		'amt'              => "",
		'resp_front_url'   => "",
		'resp_back_url'    => ""
	);
	
	/**
	 * @var mapping language frontend interface
	 */
	protected $_language_maps = array(
		'EN' => "E",
		'TH' => "T",
		'JP' => "J"
	);
	
	/**
	 * @var mapping currency
	 */
	protected $_currency_maps = array(
		'USD' => "US",
		'THB' => "TH",
		'AUD' => "AU", 
		'EUR' => "EU",
		'GBP' => "GB", 
		'JPY' => "JP",
		'NZD' => "NZ", 
		'HKD' => "HK",
		'SGD' => "SG",
		'CHF' => "CH"
	);
	
	/**
	 * @var mapping payment methods
  	 */
	protected $_method_maps = array(
		'01' => "Paysbuy Account",
		'02' => "Credit Card",
		'03' => "Paypal",
		'04' => "Amex",
		'05' => "Online Banking",
		'06' => "Counter Service"
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
	 * 
	 * @access public
	 * @param  bool 
	 * @return object class (chaining)
	 */
	public function setSandboxMode($val)
	{
		$this->_sandbox = $val;
		if ($val == true) {
			$this->_gatewayAuthUrl = str_replace('www.', 'demo.', $this->_gatewayAuthUrl);
			$this->_gatewayUrl = str_replace('www.', 'demo.', $this->_gatewayUrl);
		}
		return $this;
	}
	
	/**
	 * Get sandbox enable
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
	 * Paysbuy API using merchant instead of email
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
	 * Set gateway username
	 * Paysbuy API require username to access
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setUsername($val)
	{
		$this->_username = $val;
		return $this;
	}
	
	/**
	 * Get gateway username
	 * 
	 * @access public
	 * @return string
	 */
	public function getUsername()
	{
		return $this->_username;
	}
	
	/**
	 * Set gateway secure code
	 * Paysbuy API require secure code to access
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setSecureCode($val)
	{
		$this->_secureCode = $val;
		return $this;
	}
	
	/**
	 * Get gateway secure code
	 * 
	 * @access public
	 * @return string
	 */
	public function getSecureCode()
	{
		return $this->_secureCode;
	}
	
	/**
	 * Set payment method
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setMethod($val)
	{
		if (array_key_exists($val, $this->_method_maps)) {
			$this->_method = $val;
		}
		return $this;
	}
	
	/**
	 * Get payment method
	 * 
	 * @access public
	 * @return string
	 */
	public function getMethod()
	{
		return $this->_method;
	}
	
	/**
	 * Set force payment method
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setForceMethod($val)
	{
		$this->_forceMethod = $val;
		return $this;
	}
	
	/**
	 * Get force payment method
	 * 
	 * @access public
	 * @return string
	 */
	public function getForceMethod($val)
	{
		$this->_forceMethod = $val;
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
		$pass_parameters = array(
            'psbID'            => $this->_merchantId,
            'username'         => $this->_username,
            'secureCode'       => $this->_secureCode,
            'inv'              => $this->_invoice,
            'itm'              => $this->_purpose,
            'amt'              => $this->_amount,
            'paypal_amt'       => '',
            'curr_type'        => $this->_currency_maps[$this->_currency],
            'com'              => '',
            'method'           => (int)$this->_method,
            'language'         => $this->_language_maps[$this->_language],
            'resp_front_url'   => $this->_successUrl,
            'resp_back_url'    => $this->_backendUrl,
            'opt_fix_method'   => $this->_forceMethod,
            'opt_fix_redirect' => 0,
            'opt_name'         => '',
            'opt_email'        => '',
            'opt_mobile'       => '',
            'opt_address'      => '',
            'opt_detail'       => ''
        );
        
        $params = array_merge($pass_parameters, $extends);
		$build_data = array_merge($this->_defaults_params, $params);	
		
		//print_r($build_data); exit;
		
		return $this->_makeRequest($this->_gatewayAuthUrl, $build_data);
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
		$data = $this->build($attrs);
		$response = trim(strip_tags($data['response']));
		$refid = substr($response, 2);
		
		$this->_gatewayUrl .= "?refid=".$refid;
		// reset all data
		$data = array();
		return $this->_makeFormPayment($data);
	}
	
	/**
	 * Get a post back result from API gateway
	 * POST data from API
	 * Only Paysbuy we re-check transaction 
	 * 
	 * @access public
	 * @return array (POST)
	 */
	public function getFrontendResult()
	{		
		if (count($_POST) == 0 || !array_key_exists('apCode', $_POST)) {
			return false;
		}	
		$postdata = $_POST;
		
		$status = substr($postdata['result'], 0, 2);
		$invoice = substr($postdata['result'], 2);
		
		$result = array(
			'status' => true,
			'data' => array(
				'gateway'  => self::GATEWAY,
				'status'   => (strcmp($status, 00)) ? "success" : "failed",
				'invoice'  => $invoice,
				'currency' => $this->_currency,
				'amount'   => $postdata['amt'],				
				'dump'     => serialize($postdata)
			)
		);
		return $result;
	}
	
	/**
	 * Get data posted to background process.
	 * Sandbox is not available to use this, because have no API
	 * 
	 * @access public
	 * @return array
	 */
	public function getBackendResult()
	{
		// paysbuy sandbox mode is fucking, so they don't have a simulate API to check invoice
		// anyway we can still use get fronend method instead.
		if ($this->_sandbox == true) {
			return $this->getFrontendResult();
		}
		
		if (count($_POST) == 0 || !array_key_exists('apCode', $_POST)) {
			return false;
		}
		$postdata = $_POST;
		
		// invoice from response
		$invoice = substr($postdata['result'], 2);
		
		// for advance paysbuy API using username as email
		$merchantEmail = $this->_username;

		try {
			$params = array(
				'merchantEmail' => $merchantEmail, 
				'invoiceNo'     => $invoice,			 
				'strApCode'     => $postdata['apCode']
			);
			$response = $this->_makeRequest($this->_checkUrl, $params);
			$xml = $response['response'];
			
			// parse XML
			$sxe = new SimpleXMLElement($xml);
			
			$methodResult = (string)$sxe->MethodResult;
			$statusResult = (string)$sxe->StatusResult;

			$result = array(
				'status' => true,
				'data'   => array(
					'gateway'  => self::GATEWAY,
					'status'   => $this->_mapStatusReturned($statusResult),
					'invoice'  => $invoice,
					'currency' => $this->_currency,
					'amount'   => (string)$sxe->AmountResult,
					'dump'     => serialize($postdata)
				),
				'custom' => array(
					'recheck' => "yes"
				)
			);
		}
		catch (Exception $e) {
			$result = array(
				'status' => false,
				'msg'    => $e->getMessage()
			);
		}		
		return $result;
	}
	
}

?>