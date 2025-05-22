# quickjs-ng-zig
Use zig to build quickjs-ng project.
support windows and linux.

## install
```bash
git submodule add https://github.com/quickjs-ng/quickjs.git
git add .gitmodules quickjs

```

## build
```bash
git clone --recurse-submodules  https://github.com/bbdxf/quickjs-ng-zig.git
git submodule init
git submodule update

zig build
```

## use it
please refer to the `build.zig` file to integrate it into your project.

```bash
zig build
./zig-out/bin/demo ./zig-out/bin/demo.js 
```

