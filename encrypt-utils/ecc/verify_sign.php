<?php

require __DIR__ . "/../vendor/autoload.php";

use Mdanter\Ecc\Crypto\Signature\SignHasher;
use Mdanter\Ecc\EccFactory;
use Mdanter\Ecc\Crypto\Signature\Signer;
use Mdanter\Ecc\Serializer\PublicKey\PemPublicKeySerializer;
use Mdanter\Ecc\Serializer\PublicKey\DerPublicKeySerializer;
use Mdanter\Ecc\Serializer\Signature\DerSignatureSerializer;

# Same parameters as creating_signature.php

$adapter = EccFactory::getAdapter();
$generator = EccFactory::getNistCurves()->generator384();
$algorithm = 'sha256';
//alice
$sigData = base64_decode('MGYCMQDEgHlQXcmyDw5dEE6ChyhQn3397cHh+Iv5u3N9E4EyfJfeQs7u/l5+/nEhozjYBT8CMQDb8bbOxPfz5PW4DckPXu6PJpPMzhuXef+TTYwihqWH7MwLqaqycM2WDAPdHOJNjug=');
//openssl
//$sigData = base64_decode('MEQCIHK+HXgq0AjeKfmdI9l4uGBL0keIiZiQOCEyij25B/X/AiAQs++18Vhb0Q9tqWjzWUNTAMLEzUKF0XzKyHQ028/q4Q==');
$document = 'I am writing today...';

// Parse signature
$sigSerializer = new DerSignatureSerializer();
$sig = $sigSerializer->parse($sigData);

// Parse public key
$keyData = file_get_contents(__DIR__ . '/../data/alice-secp256r1.pub.pem');
//$keyData = file_get_contents(__DIR__ . '/openssl-secp256r1.pub.pem');
$derSerializer = new DerPublicKeySerializer($adapter);
$pemSerializer = new PemPublicKeySerializer($derSerializer);
$key = $pemSerializer->parse($keyData);

$hasher = new SignHasher($algorithm);
$hash = $hasher->makeHash($document, $generator);

$signer = new Signer($adapter);
$check = $signer->verify($key, $sig, $hash);

if ($check) {
    echo "Signature verified\n";
} else {
    echo "Signature validation failed\n";
}
