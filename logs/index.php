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
 
$logs = glob('*.log');
?>
<!DOCTYPE html>
<html>
	<head>
		<title>Logs</title>
		<style type="text/css">
			html, body { font-family: verdana; font-size: 12px; }
			h1 { font-size: 1.2em; }
		</style>
	</head>
	<body>
		<h1>Payment Logs</h1>
		<div id="container">
			<?php if (count($logs) > 0) : ?>
			<ol class="logs-list">
				<?php foreach ($logs as $file) : ?>
				<?php $mtime = date('Y-m-d H:i:s', filemtime($file)); ?>
				<li><a href="<?php echo $file; ?>" target="_blank"><?php echo $file; ?> (<?php echo $mtime; ?>) </a></li>
				<?php endforeach; ?>
			</ol>
			<?php endif; ?>
		</div>
	</body>
</html>