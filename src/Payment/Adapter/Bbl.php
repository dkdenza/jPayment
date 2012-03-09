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

class Payment_Adapter_Bbl extends Payment_Adapter_AdapterAbstract {
	
	/**
	 * Define Gateway name
	 */
	const GATEWAY = "Bbl";
	
	/**
	 * Merchant ID
	 */
	private $_merchantId;
	
	/**
	 * @var Payment Method
	 */
	private $_method = "CC";
	
	/**
	 * @var Gateway URL
	 */
	protected $_gatewayUrl = "https://ipay.bangkokbank.com/b2c/eng/payment/payForm.jsp";
	
	/**
	 * @var mapping to transfrom parameter from gateway
	 */
	protected $_defaults_params = array(
		'merchantId' => "",
		'currCode'   => "764",
		'lang'       => "E",
		'amount'     => "",
		'successUrl' => "",
		'failUrl'    => "",
		'cancelUrl'  => "",
		'payType'    => "N",
		'payMethod'  => "CC",
		'orderRef'   => "",
		'remark'     => "-",
		'redirect'   => "30"
	);
	
	/**
	 * @var mapping language frontend interface
	 */
	protected $_language_maps = array(
		'EN' => "E",
		'TH' => "T"
	);
	
	/**
	 * @var mapping currency
	 */
	protected $_currency_maps = array(
		'USD' => "840",
		'THB' => "764"
	);
	
	/**
	 * @var mapping payment methods
  	 */
	protected $_method_maps = array(
		'ALL' => "Accept All Method Available",
		'CC'  => "Credit Card"
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
	 * [NOTICE] Bbl doesn't implement sandbox yet!
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
	 * [NOTICE] Bbl doesn't implement sandbox yet!
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
	 * Set payment method
	 * 
	 * @access public
	 * @param  string $val
	 * @return object class (chaining)
	 */
	public function setMethod($val)
	{
		$val = strtoupper($val);
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
	 * Build array data and mapping from API
	 * 
	 * @access public
	 * @param  array $extends (default: array())
	 * @return array
	 */
	public function build($extends=array())
	{
		$pass_parameters = array(
			'merchantId' => $this->_merchantId,
			'currCode'   => $this->_currency_maps[$this->_currency],
			'lang'       => $this->_language_maps[$this->_language],
			'amount'     => $this->_amount,
			'successUrl' => $this->_successUrl,
			'failUrl'    => $this->_failUrl,
			'cancelUrl'  => $this->_cancelUrl,
			'payType'    => "N",
			'payMethod'  => $this->_method,
			'orderRef'   => $this->_invoice,
			'remark'     => $this->_remark
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
	 * Bbl does not post anything to front action
	 * 
	 * @access public
	 * @return array 
	 */
	public function getFrontendResult()
	{		
		if (isset($_GET['Ref']))
		{
			$invoice = $_GET['Ref'];
			$postdata = array();
			$result = array(
				'status' => true,
				'data'   => array(
					'gateway'  => self::GATEWAY,
					'status'   => "unknown",
					'invoice'  => $invoice,
					'currency' => $this->_currency,
					'amount'   => 0,
					'dump'     => serialize($postdata)
				)
			);
			return $result;
		}
		return false;
	}
	
	/**
	 * Get data posted to background process.
	 * Bbl need only trust SSL to return data feed.
	 * [IMPORTANT] For response back to Gateway you need to type "OK" on HTML.
	 * 
	 * @access public
	 * @return array
	 */
	public function getBackendResult()
	{
		if (isset($_POST) && count($_POST) > 0)
		{
			$postdata = $_POST;
			if (array_key_exists('successcode', $postdata))
			{
				$statusResult = ($postdata['successcode'] == 0) ? "success" : "failed";
				$invoice = $postdata['Ref'];
				$ref = $postdata['PayRef'];
				$result = array(
					'status' => true,
					'data' => array(
						'gateway'  => self::GATEWAY,
						'status'   => $this->_mapStatusReturned($statusResult),
						'invoice'  => $invoice,
						'currency' => $this->_currency,
						'amount'   => $postdata['Amt'],				
						'dump'     => serialize($postdata)
					)
				);
				return $result;
			}
		}
		
		$result = array(
			'status' => false,
			'msg'    => "Can not get data feed."
		);
		return $result;
	}
	
}

?>