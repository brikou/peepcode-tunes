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

$compass = new Compass('/var/lib/gems/1.8/bin/compass');
$compass->addLoadPath(__DIR__.'/src');
$compass->setNoLineComments(true);
$compass->setImagesDir(__DIR__.'/../images');
$compass->setHttpImagesPath('../images');
//$compass->setNoCache(true);

$yui = new Yui('../../bin/yuicompressor-2.4.7.jar');

$asset = new Collection(array(
    new File('src/app.scss', array(
        $compass,
    )),
), array(
    //$yui,
));

if (false) $asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();
