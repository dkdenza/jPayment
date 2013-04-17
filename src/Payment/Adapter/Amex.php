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

require_once('AdapterAbstract.php');

class Payment_Adapter_Amex extends Payment_Adapter_AdapterAbstract {
	
	/**
	 * Define Gateway name
	 */
	const GATEWAY = "Amex";
	
	/**
	 * @var Merchant ID
	 */
	private $_merchantId;
	
	/**
	 * @var Username
	 */
	private $_username;
	
	/**
	 * @var Password
	 */
	private $_password;
	
	/**
	 * @var Access Code
	 */
	private $_accessCode;
	
	/**
	 * @var Secure Code 
	 */
	private $_secureCode;
	
	/**
	 * @var Payment Method
	 */
	private $_method = "01";
	
	/**
	 * @var Gateway URL
	 */
	protected $_gatewayUrl = "https://vpos.amxvpos.com/vpcpay";
	
	/**
	 * @var Check payment transaction
	 */
	protected $_checkUrl = "https://vpos.amxvpos.com/vpcdps";
	
	/**
	 * @var mapping to transfrom parameter from gateway
	 */	
	protected $_defaults_params = array(
		'Title'           => '',
		'vpc_AccessCode'  => '',
		'vpc_Amount'      => '',
		'vpc_Command'     => 'pay',
		'vpc_Locale'      => 'en',
		'vpc_MerchTxnRef' => '',
		'vpc_Merchant'    => '',
		'vpc_OrderInfo'   => '',
		'vpc_ReturnURL'   => '',
		'vpc_Version'     => '1',
		'vpc_SecureHash'  => '',
	);
	
	/**
	 * @var mapping language frontend interface
	 */
	protected $_language_maps = array(
		'EN' => "en",
		'TH' => "th"
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
	 * Sandbox some methods not available in SSL mode.
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
	 * 
	 * @access public
	 * @param  string
	 * @return string
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
	 * Set gateway password
	 * 
	 * @access public
	 * @param  string
	 * @return string
	 */	
	public function setPassword($val)
	{
		$this->_password = $val;
		return $this;
	}
	
	/**
	 * Get gateway password
	 * 
	 * @access public
	 * @return string
	 */
	public function getPassword()
	{
		return $this->_password;
	}
	
	/**
	 * Set gateway access code
	 * Amex API require access code to access
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setAccessCode($val)
	{
		$this->_accessCode = $val;
		return $this;
	}
	
	/**
	 * Get gateway access code
	 * 
	 * @access public
	 * @return string
	 */
	public function getAccessCode()
	{
		return $this->_accessCode;
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
	 * Get invoice return from gateway feed data
	 * This invoice return from gateway, so don't need set method
	 * 
	 * @access public
	 * @return string
	 */
	public function getGatewayInvoice()
	{
		return $_GET['vpc_MerchTxnRef'];
	}
	
	/**
	 * State of canceled payment returned.
	 * override from abstract 
	 * 
	 * @access public
	 * @return bool
	 */
	public function isCancelPosted()
	{
		if (isset($_GET) && array_key_exists('vpc_Message', $_GET)) 
		{
			return preg_match('|Cancelled|i', $_GET['vpc_Message']);
		}		
		return false;
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
		$amount = ($this->_amount * 100);
        $pass_parameters = array(
        	'Title'           => $this->_purpose,
			'vpc_AccessCode'  => $this->_accessCode,
			'vpc_Amount'      => $amount,
			'vpc_Locale'      => $this->_language_maps[$this->_language],
			'vpc_MerchTxnRef' => $this->_invoice,
			'vpc_Merchant'    => $this->_merchantId,
			'vpc_OrderInfo'   => $this->_remark,
			'vpc_ReturnURL'   => $this->_successUrl
        );
        
        $pass_parameters = array_merge($this->_defaults_params, $pass_parameters);

        $hashed = $this->_callculateHash($pass_parameters);        
        
		$build_data = array_merge($pass_parameters, $extends, array(
			'vpc_SecureHash' => $hashed
		));
		
		return $build_data;
	}
	
	/**
	 * Callculate secret code hashed.
	 * 
	 * @access private
	 * @param  array   $values
	 * @return string
	 */
	private function _callculateHash($values)
	{
		$md5HashData = $this->_secureCode;

		foreach($values as $key => $value) 
		{
		    if (strlen($value) > 0) 
		    {
		        $md5HashData .= $value;
		    }
		}

		return strtoupper(md5($md5HashData));
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
		return $this->_makeFormPayment($data, 'GET');
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
		// Amex return GET 
		if (count($_GET) == 0 || !array_key_exists('vpc_SecureHash', $_GET)) {
			return false;
		}
		
		// Nothing to process
		if ($_GET['vpc_TxnResponseCode'] == '7' || $_GET['vpc_TxnResponseCode'] == 'No Value Returned') {
			return false;
		}
	
		// Buffer data
		$postdata = $_GET;
		
		//echo '<pre>' .print_r($postdata, true) . '</pre>';
		
		// Get hashed, and reset junk values
		$hashed = $_GET['vpc_SecureHash'];
		unset($postdata['vpc_SecureHash'], $postdata['action'], $postdata['state']);
		
		// Get secure code to process
		$md5HashData = $this->getSecureCode();
		
		// Calculated hashed
		foreach ($postdata as $key => $value) 
		{
	        if ($key != "vpc_Secure_Hash" or strlen($value) > 0) {
	            $md5HashData .= $value;
	        }
	    }
	    
	    // Hashed not match
	    if (strtoupper($hashed) != strtoupper(md5($md5HashData))) {
	    	return false;
	    }
	    
	    // Result returned
	    $status        = $postdata['vpc_Message'];
	    $invoice       = $postdata['vpc_MerchTxnRef'];
	    $vpc_amount    = $postdata['vpc_Amount'];
	    $amount        = ($vpc_amount / 100);
	    $amount        = $this->_decimals($amount);
	    
	    $statusResult = ($status == 'Approved') ? "success" : "pending";
	    
	    // Mapping response
	    $result = array(
	    	'status'          => true,
	    	'data'            => array(
	    		'gateway'        => self::GATEWAY,
	    		'transaction_id' => $postdata['vpc_TransactionNo'],
	    		'status'         => $this->_mapStatusReturned($statusResult),
	    		'invoice'        => $invoice,
	    		'currency'       => $this->_currency,
	    		'amount'         => $amount,
	    		'capture' 		 => $vpc_amount,
	    		'dump'           => serialize($postdata)
	    	)
	    );
	    
	    return $result;
	}
	
	/**
	 * Capture transaction.
	 * 
	 * @access  public
	 * @return  array
	 */
	public function capture($transactionId, $ref, $capture = null)
	{
		$process = array(
			'vpc_Version'        => 1,
			'vpc_Command'        => 'capture',
			'vpc_AccessCode'     => $this->getAccessCode(),
			'vpc_MerchTxnRef'    => $ref,
			'vpc_Merchant'       => $this->getMerchantId(),
			'vpc_TransNo'        => $transactionId,
			'vpc_Amount'         => $capture,
			'vpc_User'           => $this->getUsername(),
			'vpc_Password'       => $this->getPassword()
		);
		
		print_r($process);

		$params = $process;		
		$response = $this->_makeRequest($this->_checkUrl, $params);
		
		if (isset($response['response']))
		{
			$resp = $response['response'];
			parse_str($resp, $out);
			
			echo '<pre>'.print_r($out, true).'</pre>';
		}
		
		return false;
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
		/*if ($this->_sandbox == true) {
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
			
			$amount = (string)$sxe->AmountResult;
			$amount = $this->_decimals($amount);

			$result = array(
				'status' => true,
				'data'   => array(
					'gateway'  => self::GATEWAY,
					'status'   => $this->_mapStatusReturned($statusResult),
					'invoice'  => $invoice,
					'currency' => $this->_currency,
					'amount'   => $amount,
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
		return $result;*/
	}
	
}

?>