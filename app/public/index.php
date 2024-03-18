<?php
require __DIR__ . '/vendor/autoload.php';


$client = new \GuzzleHttp\Client();

$res = $client->request('GET', 'https://markirovka.crpt.ru/api/v3/true-api/auth/key', [
    'debug' => false,
]);
$out = json_decode($res->getBody()->__toString());

$content = $out->data;
echo'<pre>';
var_dump($out);
echo'</pre>';

$store = new CPStore();
$store->Open(CURRENT_USER_STORE, "my", STORE_OPEN_READ_ONLY);

$certs = $store->get_Certificates();

echo'<pre>';
var_dump($certs);
echo'</pre>';

$cert = $certs->Item(1);

$signer = new CPSigner();
$signer->set_Certificate($cert);

$sd = new CPSignedData();
$sd->set_Content($content);

$sm = $sd->SignCades($signer, CADES_BES , false, ENCODE_BASE64);
$sm = preg_replace("/[\r\n]/","",$sm);
echo "\n";
