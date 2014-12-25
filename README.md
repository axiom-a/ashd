#ashd

D port of Ash (ActionScript 3 entity systems framework for game development created by Richard Lord).

Original AS3 version - https://github.com/richardlord/Ash
Visit http://www.ashframework.org for more information.

Builds with:
 - cmake 
 - bub ([bottom-up-build](https://github.com/GrahamStJack/bottom-up-build))
 - [DMD 2.066.1](https://github.com/D-Programming-Language/dmd).

Building with cmake:
```shell
cd <location where build dir will sit>
mkdir <build-dir>
cd <build-dir>
cmake <ashd-source-dir>
make -j3
````

Building with bub: 
Once bub has been built/installed:
```shell
bub-config --mode=release <build-dir>
cd <build-dir>
bub -j5
````

Will also build with [dub](https://github.com/rejectedsoftware/dub). Has only been tested on linux.
