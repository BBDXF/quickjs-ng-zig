// wrapper for qjs.c main functions.
// it's used by the myui project.

#ifndef WRAPPER_H
#define WRAPPER_H

#include "quickjs.h"

typedef struct _JS_App{
    JSRuntime* rt;
    JSContext* ctx;
    JSValue global;
} JS_App;

// js_app_new: Create a new JS_App instance.
// max_stack_size: The maximum size of the stack in bytes.
// max_heap_size: The maximum size of the heap in bytes.
// Returns: A pointer to the JS_App instance.
JS_App* js_app_new(int max_stack_size, int max_heap_size);

// js_app_free: Free the memory allocated for the JS_App instance.
// app: A pointer to the JS_App instance.
void js_app_free(JS_App* app);

// js_app_eval: Evaluate a JavaScript string.
// app: A pointer to the JS_App instance.
// data: The JavaScript string to evaluate.
// data_len: The length of the JavaScript string.
// name: The name of the JavaScript string.
// is_module: Whether the JavaScript string is a module.
// Returns: 0 on success, -1 on failure.
int js_app_eval(JS_App* app, const char* data, const int data_len, const char* name, bool is_module);

// js_app_eval_file: Evaluate a JavaScript file.
// app: A pointer to the JS_App instance.
// filename: The name of the JavaScript file to evaluate.
//           app will auto detect file suffix and type to check whether it's a module.
// Returns: 0 on success, -1 on failure.
int js_app_eval_file(JS_App* app, const char* filename);

// js_app_eval_bin: Evaluate a binary JavaScript file which is compiled by qjsc.
// app: A pointer to the JS_App instance.
// data: The binary JavaScript file.
// data_len: The length of the binary JavaScript file.
// Returns: 0 on success, -1 on failure.
void js_app_eval_bin(JS_App* app, const char* data, const int data_len);

// run loop until end
void js_app_run_loop(JS_App* app);

#endif