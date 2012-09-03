<?php

require_once('../config.inc.php');

$mp = Payment::factory('bbl', array(
	'username'   => 'MglobeApi',
	'password'   => 'M_ApiPassword',
	//'merchantId' => '2147',
	//'invoice'    => '4339'
));

$mp->setMerchantId(2147);
$mp->setInvoice(4339);

$rs = $mp->lookUp();

print_r($rs);