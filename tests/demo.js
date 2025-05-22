console.log('demo.js log ...\n')

console.log('==> globalThis:\n')
for (var key in globalThis) {
    console.log("  " + key + '\n')
}

console.log('==> std:\n')
for (var key in std) {
    console.log("  " + key + '\n')
}

console.log('==> os:\n')
for (var key in os) {
    console.log("  " + key + '\n')
}

console.log('==> bjson:\n')
for (var key in bjson) {
    console.log("  " + key + '\n')
}

globalThis.std.printf('\n\nhello_world\n');
globalThis.std.printf(globalThis + '\n');


var a = 0xf2;
os.setTimeout(() => { std.printf('AAB\n') }, 2000)
globalThis.std.printf("a value is %d\n", a);

