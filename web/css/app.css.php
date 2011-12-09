<?php

header('Content-Type: text/css');

chdir(__DIR__);

require_once '../../vendor/.composer/autoload.php';

use
    \Assetic\Asset\AssetCache as Cache,
    \Assetic\Asset\AssetCollection as Collection,
    \Assetic\Asset\FileAsset as File,
    \Assetic\Filter\Yui\CssCompressorFilter as Yui,
    \Assetic\Filter\CompassFilter as Compass
;

$yui = new Yui('../../bin/yuicompressor-2.4.7.jar');

$asset = new Collection(array(
    new File('lib/normalize.css'),
    new File('lib/angular-0.10.5.css'),
), array(
    $yui,
));

$asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();

$compass = new Compass('compass');
$compass->addLoadPath(__DIR__.'/src');
$compass->setNoLineComments(true);
$compass->setImagesDir(__DIR__.'/../images');
$compass->setHttpImagesPath('../images');

$asset = new Collection(array(
    new File('src/app.scss', array(
        $compass,
    )),
), array(
    $yui,
));

if (false) $asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();
