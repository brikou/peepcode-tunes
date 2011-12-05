<?php

header('Content-Type: application/x-javascript;charset=UTF-8');

chdir(__DIR__);

require_once '../../vendor/.composer/autoload.php';

use
    \Assetic\Asset\AssetCache as Cache,
    \Assetic\Asset\AssetCollection as Collection,
    \Assetic\Asset\FileAsset as File,
    \Assetic\Filter\GoogleClosure\CompilerJarFilter as Compiler,
    \Assetic\Filter\CoffeeScriptFilter as Coffee
;

$compiler = new Compiler('../../bin/compiler-1592.jar');

$asset = new Collection(array(
    new File('lib/angular-0.10.5/angular.js'),
    new File('lib/angular-0.10.5/init.js'),
), array(
    $compiler,
));

$asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();

$coffee = new Coffee();
$coffee->setBare(true);

$asset = new Collection(array(
    new File('src/Tunes.coffee'),
), array(
    $coffee,
));

$asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();

//echo "(function() { {$asset->dump()} }).call(this);";
