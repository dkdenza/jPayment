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

class Payment_Adapter_Paypal extends Payment_Adapter_AdapterAbstract {
	
	/**
	 * Define Gateway name
	 */
	const GATEWAY = "Paypal";
	
	/**
	 * @var Gateway URL
	 */
	protected $_gatewayUrl = "https://www.paypal.com/cgi-bin/webscr";
	
	/**
	 * @var mapping to transfrom parameter from gateway
	 */
	protected $_defaults_params = array(
		'cmd'             => "_xclick",
		'lc'              => "EN",
		'notify_url'      => "",
		'return'          => "",
		'cancel_return'   => "",
		'business'        => "",
		'invoice'         => "",
		'item_name'       => "",
		'item_number'     => "",
		'amount'          => "",
		'currency_code'   => "THB",
		'discount_amount' => 0,
		'quantity'        => 1,
		'custom'		  => ""	
	);
	
	/**
	 * @var mapping language frontend interface
	 */
	protected $_language_maps = array(
		'EN' => "EN",
		'TH' => "TH"
	);
	
	/**
	 * @var mapping currency
	 */
	protected $_currency_maps = array(
		'USD' => "USD",
		'THB' => "THB"
	);
	
	/**
	 * @var mapping payment methods
  	 */
	protected $_method_maps = array(
		'01' => "Paypal Account",
		'02' => "Credit Card"
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
			$this->_gatewayUrl = str_replace('www.', 'www.sandbox.', $this->_gatewayUrl);
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
	 * Build array data and mapping from API
	 * 
	 * @access public
	 * @param  array $extends (default: array())
	 * @return array
	 */
	public function build($extends=array())
	{
		$pass_parameters = array(
			'business'      => $this->_merchantAccount,
			'invoice'       => $this->_invoice,
			'item_name'     => $this->_purpose,
			'amount'        => $this->_amount,
			'return'        => $this->_successUrl,
			'cancel_return' => $this->_cancelUrl,
			'notify_url'    => $this->_backendUrl,
			'currency_code' => $this->_currency_maps[$this->_currency],
			'lc'            => $this->_language_maps[$this->_language],
			'custom'		=> $this->_remark
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
	public function render($attrs=array())	{
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
		if (count($_POST) == 0 || !array_key_exists('invoice', $_POST)) {
			return false;
		}	
		$postdata = $_POST;
		
		$result = array(
			'status' => true,
			'data'   => array(
				'gateway'  => self::GATEWAY,
				'status'   => $postdata['payment_status'],
				'invoice'  => $postdata['invoice'],
				'currency' => $this->_currency,
				'amount'   => $postdata['mc_gross'],				
				'dump'     => serialize($postdata)
			)
		);
		return $result;
	}

	/**
	 * Get backend posted from server
	 * Check transaction from IPN data
	 * 
	 * @access public
	 * @return array
	 */
	public function getBackendResult()
	{
		if (isset($_POST) && count($_POST) > 0)
		{
			$postdata = $_POST;
			$postdata['cmd'] = "_notify-validate";
			
			$response = $this->_makeRequest($this->_gatewayUrl, $postdata, array(
				CURLOPT_CAINFO => "cacert.pem"
			));
			$status = $response['status'];			
			$body = $response['response'];
			
			if (preg_match('|VERIFIED|', $body)) 
			{	
				$statusResult = $postdata['payment_status'];
				$result = array(
					'status' => true,
					'data' => array(
						'gateway'  => self::GATEWAY,
						'status'   => $this->_mapStatusReturned($statusResult),
						'invoice'  => $postdata['invoice'],
						'currency' => $this->_currency,
						'amount'   => $postdata['mc_gross'],				
						'dump'     => serialize($postdata)
					),
					'custom' => array(
						'response_ipn' => $body
					)
				);
				return $result;
			} // end if verified	
			
		} // end isset post
		
		// in case ipn not found first
		$result = array(
			'status' => false,
			'msg'    => "Can not verify IPN"
		);
		return $result;
	}
	
}

?>