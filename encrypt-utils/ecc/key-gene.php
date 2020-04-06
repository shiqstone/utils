<?php

require __DIR__ . "/../vendor/autoload.php";

use Mdanter\Ecc\EccFactory;
use Mdanter\Ecc\Serializer\PrivateKey\PemPrivateKeySerializer;
use Mdanter\Ecc\Serializer\PrivateKey\DerPrivateKeySerializer;

use Mdanter\Ecc\Serializer\PublicKey\DerPublicKeySerializer;
use Mdanter\Ecc\Serializer\PublicKey\PemPublicKeySerializer;

$adapter = EccFactory::getAdapter();
$generator = EccFactory::getNistCurves()->generator384();
$private = $generator->createPrivateKey();

$derSerializer = new DerPrivateKeySerializer($adapter);
$der = $derSerializer->serialize($private);
echo sprintf("DER encoding:\n%s\n\n", base64_encode($der));

$pemSerializer = new PemPrivateKeySerializer($derSerializer);
$pem = $pemSerializer->serialize($private);
echo sprintf("PEM encoding:\n%s\n\n", $pem);

$public = $private->getPublicKey();
$pubKeySerializer = new PemPublicKeySerializer(new DerPublicKeySerializer($adapter));
$pubkey = $pubKeySerializer->serialize($public);
echo sprintf("Pub PEM encoding:\n%s\n\n", $pubkey);
