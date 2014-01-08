RLDartRoutingBundle
=======

RL Dart Routing Bundle. Inspired by FOSJsRoutingBundle.

#Installatoin

At first you should add dependency to your `composer.json`. For this run

```bash
    composer.phar require rl/dartroutingbundle:dev-master
```

Then register new bundle in `AppKernel.php`. Just add the following line

```php
    new RL\DartRoutingBundle\RLDartRoutingBundle(),
```

to the registerBundles() function.

```php
// app/AppKernel.php
public function registerBundles()
{
    return array(
        // ...
        new RL\DartRoutingBundle\RLDartRoutingBundle(),
    );
}
```

The third step is routing registration. Add the following

```yaml
rl_dart_routing:
    resource: "@RLDartRoutingBundle/Resources/config/routing.yml"
    prefix:   /rl_dart_routing
```

to the `routing.yml`

Run

```bash
    php app/console assets:install web --symlink
```

Then add this line `import '../relative/path/to/your/project/root/dir/web/bundles/rldartrouting/dart/router/routing.dart';` to your Dart library/application.
Replace `../relative/path/to/your/project/root/dir` by the real relative path to your project root dir.

And that's it. If you made everything correct RLDartRoutingBundle should be installed successfully.

#Configuration

RLDartRoutingBundle supports two ways of getting routes. Dynamically from Controller and statically form file. By default it uses dynamic way.
But if yow want to use static json file you should add the following to your config.yml

```yaml
rl_dart_routing:
  type: static #it can be static or dynamic. By default this parameter set as dynamic
  routes_json_file: relative/path/to/the/file/with/routes/info.json #by default the path is web/dart_routes.json
```

and then generate this file by the `php app/console rl:router:extract` command.

#Usage

If yow want to use some route from your frontend Dart application you should set option ***expose*** to the route.

```php
    /**
     * @Route("/test/{testParam}", name="test", options = {"expose" = true})
     * @param $testParam
     */
    public function testAction($testParam)
    {
        //...
    }
```

And then you could use `url` or `path` functions in your Dart code for generating url

```dart
    url('test', {'testParam': 'value'})
```

This functions work in the same way as similar functions from Twig.
