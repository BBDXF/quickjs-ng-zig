const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // c flags
    const is_msvc = target.result.abi == .msvc;
    var c_flags = std.ArrayList([]const u8).init(b.allocator);
    defer c_flags.deinit();
    if (is_msvc) {
        // MSVC 标志
        c_flags.appendSlice(&.{
            "/std:c11", // 使用 C17 标准
            "/D_GNU_SOURCE", // 模拟 GNU 扩展（需注意兼容性）
            "/DWIN32_LEAN_AND_MEAN", // 减少不必要的头文件引入
            "/D_WIN32_WINNT=0x0602", // 定义 Windows 版本
            "/STACK:8388608", // 增加堆栈大小（8MB）
            "/D_CRT_SECURE_NO_WARNINGS", // 禁用安全警告
        }) catch unreachable;
    } else {
        // GCC/Clang 标志
        c_flags.appendSlice(&.{
            "-std=c11", // 使用 C17 标准
            "-D_GNU_SOURCE", // 启用 GNU 扩展
            "-Wl,--stack,8388608", // 增加堆栈大小（8MB）
        }) catch unreachable;
    }

    // qjs lib
    const qjs_lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });

    qjs_lib_mod.addCSourceFiles(.{
        .files = &.{
            "quickjs/cutils.c",
            "quickjs/libregexp.c",
            "quickjs/libunicode.c",
            "quickjs/quickjs.c",
            "quickjs/xsum.c",
            "quickjs/quickjs-libc.c",
        },
        .flags = c_flags.items,
    });
    qjs_lib_mod.addIncludePath(b.path("quickjs"));
    // libs
    // qjs_lib_mod.linkSystemLibrary("m", .{ .needed = true });
    const is_linux = target.result.os.tag == .linux;
    if (is_linux) {
        qjs_lib_mod.linkSystemLibrary("pthread", .{ .needed = true });
    }

    const qjs_lib = b.addStaticLibrary(.{
        .name = "qjs",
        .root_module = qjs_lib_mod,
        // .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });
    qjs_lib.linkLibC();

    // qjsc exe
    const qjsc_exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    qjsc_exe_mod.addCSourceFiles(.{
        .files = &.{
            "quickjs/qjsc.c",
        },
        .flags = c_flags.items,
    });
    qjsc_exe_mod.addIncludePath(b.path("quickjs"));
    const qjsc_exe = b.addExecutable(.{
        .name = "qjsc",
        .root_module = qjsc_exe_mod,
    });
    qjsc_exe.linkLibC();
    qjsc_exe.linkLibrary(qjs_lib);

    // qjs exe
    const qjs_exe_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    qjs_exe_mod.addCSourceFiles(.{
        .files = &.{
            "quickjs/gen/repl.c",
            "quickjs/gen/standalone.c",
            "quickjs/qjs.c",
        },
        .flags = c_flags.items,
    });
    qjs_exe_mod.addIncludePath(b.path("quickjs"));
    const qjs_exe = b.addExecutable(.{
        .name = "qjs",
        .root_module = qjs_exe_mod,
    });
    qjs_exe.linkLibC();
    qjs_exe.linkLibrary(qjs_lib);

    // zjs
    const zjs_lib_mod = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    zjs_lib_mod.addIncludePath(b.path("quickjs"));
    zjs_lib_mod.addIncludePath(b.path("src"));
    zjs_lib_mod.addCSourceFiles(.{
        .files = &.{
            "src/wrapper.c",
        },
        .flags = c_flags.items,
    });
    zjs_lib_mod.link_libc = true;

    const zjs_lib = b.addLibrary(.{
        .name = "zjs",
        .root_module = zjs_lib_mod,
        .version = .{ .major = 1, .minor = 0, .patch = 0 },
    });
    zjs_lib.linkLibC();
    zjs_lib.linkLibrary(qjs_lib);

    // test
    const demo_exe = b.addExecutable(.{
        .name = "demo",
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("tests/demo.zig"),
    });
    demo_exe.addIncludePath(b.path("src"));
    demo_exe.addIncludePath(b.path("quickjs"));
    demo_exe.linkLibrary(zjs_lib);

    // install
    // b.installArtifact(qjs_lib);
    b.installArtifact(zjs_lib);
    b.installArtifact(qjsc_exe);
    b.installArtifact(qjs_exe);

    // test
    b.installArtifact(demo_exe);
    b.installFile("tests/demo.js", "bin/demo.js");

    // headers
    b.installFile("quickjs/quickjs.h", "include/quickjs.h");
    b.installFile("quickjs/quickjs-libc.h", "include/quickjs-libc.h");
    b.installFile("src/wrapper.h", "include/wrapper.h");
}
