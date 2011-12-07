<?php

header('Content-Type: application/x-javascript;charset=UTF-8');

chdir(__DIR__);

require_once '../../../../vendor/.composer/autoload.php';

use
    \Assetic\Asset\AssetCache as Cache,
    \Assetic\Asset\AssetCollection as Collection,
    \Assetic\Asset\GlobAsset as Glob,
    \Assetic\Filter\GoogleClosure\CompilerJarFilter as Compiler,
    \Assetic\Filter\CoffeeScriptFilter as Coffee
;

$coffee = new Coffee();
$coffee->setBare(true);

$asset = new Collection(array(
    new Glob('*.coffee'),
), array(
    $coffee,
));

$asset = new Cache(
    $asset,
    new \Assetic\Cache\FilesystemCache(sys_get_temp_dir())
);

echo $asset->dump();

//echo "(function() { {$asset->dump()} }).call(this);";
