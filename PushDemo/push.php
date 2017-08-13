<?php  
  
// Put your device token here (without spaces):  
$deviceToken = '6b6c33f21a64605d2e9b8cdbb781409f433668f7e28acaf4db59d05bbfae9ee7';//ios6的touch  
  
// Put your private key's passphrase here:  
$passphrase = '1234';//证书的密码  
  
// Put your alert message here:  
$message = 'My first push notification!';  
  
////////////////////////////////////////////////////////////////////////////////  
  
// $ctx = stream_context_create(); 
$ctx = stream_context_create([
    'ssl' => [
                             'verify_peer' => false,
                             'verify_peer_name' => false
                             ]
    ]); 

stream_context_set_option($ctx, 'ssl', 'local_cert', 'ck222.pem');  
stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);  
  
// Open a connection to the APNS server  
//这个为正是的发布地址
 //$fp = stream_socket_client(“ssl://gateway.push.apple.com:2195“, $err, $errstr, 60, //STREAM_CLIENT_CONNECT, $ctx);
//这个是沙盒测试地址，发布到appstore后记得修改哦
$fp = stream_socket_client(  
    'ssl://gateway.sandbox.push.apple.com:2195', $err,  
    $errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);  
  
if (!$fp)  
    exit("Failed to connect: $err $errstr" . PHP_EOL);  
  
echo 'Connected to APNS' . PHP_EOL;  
  
$alert = array(  
                'body'=>’push测试2’,  
                'action-loc-key'=>'ok');  
// Create the payload body  
$pushInfo['aps'] = array(  
    'alert' => $alert,  
    'sound' => '1',  
    // 'content-available' => 1//,//for 静默下载。  
    'badge' => 1  
    );  
$pushInfo['usrdefined'] = array('ptype'=>'6',  
                                'pushid'=>'4865',  
                                //自定义字段  
                                'appleid'=>’123456’  
);  
  
// Encode the payload as JSON  
$payload = json_encode($pushInfo);  
  
// Build the binary notification  
$msg = chr(0) . pack('n', 32) . pack('H*', $deviceToken) . pack('n', strlen($payload)) . $payload;  
  
// Send it to the server  
$result = fwrite($fp, $msg, strlen($msg));  
  
if (!$result)  
    echo 'Message not delivered' . PHP_EOL;  
else  
    echo 'Message successfully delivered' . PHP_EOL;  
  
// Close the connection to the server  
fclose($fp); 
?>