#ashd

D port of Ash (ActionScript 3 entity systems framework for game development created by Richard Lord).

Original AS3 version - https://github.com/richardlord/Ash
Visit http://www.ashframework.org for more information.

Builds with:
 - cmake (modified for use with D) ([cmake](https://github.com/trentforkert/cmake))
 - [DMD 2.071.0](http://dlang.org)

Building with cmake:
```shell
cd <location where build dir will sit>
mkdir <build-dir>
cd <build-dir>
cmake <ashd-source-dir>
make -j3
````


Will also build with [dub](https://github.com/rejectedsoftware/dub). Has only been tested on linux.
