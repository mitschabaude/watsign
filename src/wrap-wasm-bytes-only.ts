// the JS side for common_bytes_only.wat
import {toBytes} from 'fast-base64/js';
export {wrap};

type ModuleWrapper = {
  imports: WebAssembly.Imports;
  modulePromise: Promise<WebAssembly.Module>;
  instancePromise: Promise<WebAssembly.Instance> | undefined;
  maxPersistentMemory: number;
};
let modules: Record<string, ModuleWrapper> = {};
let currentId = 0;

function wrap<E extends string[] | undefined>(
  wasmCode: string | Uint8Array,
  {
    exports,
    fallback,
    imports,
    maxPersistentMemory = MAX_PERSISTENT_BYTES,
  }: {
    exports?: E;
    fallback?: string | Uint8Array;
    imports?: WebAssembly.ModuleImports;
    maxPersistentMemory?: number;
  } = {}
): E extends string[]
  ? Record<E[number], WasmFunction> & {isReady: Promise<void>}
  : Promise<Record<string, WasmFunction> & {isReady: Promise<void>}> {
  let id = currentId++;
  let importObject: WebAssembly.Imports = imports ? {imports} : {};
  let instantiated = instantiate(wasmCode, importObject, fallback);

  modules[id] = {
    modulePromise: instantiated.then(i => i.module),
    instancePromise: instantiated.then(i => i.instance),
    imports: importObject,
    maxPersistentMemory,
  };

  let wrap = (exports: string[]) =>
    ({
      ...Object.fromEntries(
        exports.map(name => [name, wrapFunction(name, modules[id])])
      ),
      isReady: instantiated.then(() => {}),
    } as Record<string, WasmFunction> & {isReady: Promise<void>});

  return (
    exports
      ? wrap(exports as string[])
      : instantiated.then(i =>
          wrap(
            WebAssembly.Module.exports(i.module)
              .filter(m => m.kind === 'function')
              .map(m => m.name)
          )
        )
  ) as never;
}

async function instantiate(
  wasmCode: string | Uint8Array,
  importObject: WebAssembly.Imports,
  wasmCodeFallback?: string | Uint8Array
) {
  try {
    let wasmBytes = typeof wasmCode === 'string' ? toBytes(wasmCode) : wasmCode;
    return WebAssembly.instantiate(wasmBytes, importObject);
  } catch (err) {
    if (wasmCodeFallback === undefined) throw err;
    console.warn(err);
    console.warn('falling back to version without experimental feature');
    let wasmBytes =
      typeof wasmCodeFallback === 'string'
        ? await toBytes(wasmCodeFallback)
        : wasmCodeFallback;
    return WebAssembly.instantiate(wasmBytes, importObject);
  }
}

async function reinstantiate(wrapper: ModuleWrapper) {
  let {modulePromise, instancePromise, imports} = wrapper;
  if (instancePromise === undefined) {
    instancePromise = modulePromise.then(m =>
      WebAssembly.instantiate(m, imports)
    );
    wrapper.instancePromise = instancePromise;
  }
  let instance = await instancePromise;
  let memory = instance.exports.memory as WebAssembly.Memory;

  return {instance, memory};
}

type WasmFunction = (...args: number[]) => undefined | number;

function wrapFunction(name: string, wrapper: ModuleWrapper) {
  return async function call(...args: Uint8Array[]) {
    let {instance, memory} = await reinstantiate(wrapper);
    let func = instance.exports[name] as WasmFunction;
    let {alloc, free} = instance.exports as Record<string, WasmFunction>;

    // figure out how much memory to allocate
    let totalBytes = 0;
    for (let arg of args) {
      totalBytes += arg.byteLength;
    }
    let offset = alloc(totalBytes) as number;

    // translate function arguments to numbers
    let actualArgs: number[] = [];
    for (let arg of args) {
      let length = arg.byteLength;
      actualArgs.push(offset, length);
      new Uint8Array(memory.buffer, offset, length).set(arg);
      offset += length;
    }
    try {
      let pointer = func(...actualArgs);
      if (pointer === undefined) return undefined;
      let view = new DataView(memory.buffer, pointer, 128);
      let offset = 1;
      pointer = view.getUint32(offset, true);
      offset += 4;
      let length = view.getUint32(offset, true);
      offset += 4;
      return new Uint8Array(memory.buffer.slice(pointer, pointer + length));
    } catch (err) {
      console.error(err);
    } finally {
      free();
      cleanup(wrapper, memory);
    }
  };
}

// memory management
const MAX_PERSISTENT_BYTES = 1e7;

// garbage collect instance if it exceeds memory limit
function cleanup(wrapper: ModuleWrapper, memory: WebAssembly.Memory) {
  let maxMem = wrapper.maxPersistentMemory;
  if (memory.buffer.byteLength >= maxMem) {
    console.warn(
      `Cleaning up Wasm instance, memory limit of ${maxMem}B was exceeded.`
    );
    queueMicrotask(() => {
      wrapper.instancePromise = undefined;
    });
  }
}
