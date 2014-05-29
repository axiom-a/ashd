#ashd

D port of Ash (ActionScript 3 entity systems framework for game development created by Richard Lord).

Original AS3 version - https://github.com/richardlord/Ash
Visit http://www.ashframework.org for more information.

Natively builds with bub ([bottom-up-build](https://github.com/GrahamStJack/bottom-up-build)), and [DMD 2.065(b3)](https://github.com/D-Programming-Language/dmd).

Once bub has been built/installed:
```shell
bub-config --mode=release <build-dir>
cd <build-dir>
bub -j5
````

Will also build with [dub](https://github.com/rejectedsoftware/dub). Has only been tested on linux.
