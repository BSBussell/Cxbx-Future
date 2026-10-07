# JSRF white-flash fix

[Back to Future patches](README.md) · [Implementation and diff](https://github.com/BSBussell/Cxbx-Future/commit/16dcae3aa16fb0e679e3a873994bece76e426cf4)

## High Level Explanation

This patch is intended to prevent the unintended white flashes seen in JSRF under [Cxbx-Reloaded](https://github.com/Cxbx-Reloaded/Cxbx-Reloaded). It corrects how the emulator stores information needed to draw a frame, removing the headache-inducing flashbang we all know and love.

So, in a nutshell, Cxbx has two ways of rendering graphics here: **high-level emulation (HLE)**, which implements Xbox graphics functions, and emulated **GPU command processing.** In flashbang versions, both paths are able to overwrite the same stored shader values. HLE could then draw using values that had changed since the game supplied them. Leading to *mind-boggling* visual effects. (flashbang)

This fix gives HLE its own storage for shader constants and inline vertex attributes. HLE reads and updates that storage throughout the rendering process. And GPU command processing keeps its own state. This stops GPU command processing from stepping on HLE's toes by overwriting those values.

### Side effects?

The emulator source changes are confined to four files in the graphics pipeline. All that the changes accomplish is separating rendering state and ensuring that HLE data is not mangled by the GPU emulation. The rendering fix does not change emulator source outside these graphical files.

There are no changes to CPU instruction execution. These changes aren't intended to alter movement, collision, input handling, RNG, frame limiting, or emulator game-speed controls. While the game could still query constants, the only change made in this build is ensuring that the constants are what they should be rather than being fudged by the interspersed state.

The build uses the September 2022 source base and legacy compiler tools in order to keep the build as close to the original release as possible. As such I am quite confident in saying that this build should run nearly identical to the Cxbx-Reloaded commit it is based on, just with no flashbang.

### Competitive integrity

My assessment is that this is a reasonable fix to allow for speedrunning, bingo, rando, and other, things. Its purpose is to correct an emulator specific rendering error while preserving the game's intended behavior.

Removing a white flash improves accessibility and visibility; that is the goal behind this patch. The flashbang is an obnoxious visual error, and for users sensitive to flashing visuals, it can be uncomfortable or headache-inducing.

While I have not explicitly ruled out every possible gameplay regression (vs mode has not been tested 🙂‍↕️), I don't believe that should automatically disqualify this patch. Given that it is scoped to how rendering state is stored, uploaded, and read back, I believe that this patched build should be approved for JSRF speedrunning.

## Technical breakdown for nerds 🫵!

Ok, this is where there's gonna be a lot more technical jargon. Here's a brief glossary if you are curious or if you're like me and this is all very new to you:

- **HLE:** Explained above!
- **NV2A:** The original Xbox's GPU, whose behavior Cxbx emulates.
- **Push-buffer processing:** Reading and executing batches of commands intended for Xbox GPU.

### State ownership

Previously, HLE constant setters and inline vertex attribute setters stored values in the emulated NV2A GPU's state. Push-buffer processing also writes that state, allowing it to even overwrite values that may be needed by a later HLE draw.

The fix separates this storage:

- HLE now has its own storage for its 192 four-component shader constants and their dirty flags. A dirty flag tells us which constants need to be uploaded to Direct3D 9.
- HLE also has 16 four-component inline vertex attribute values.
- Emulated GPU command processing continues to use NV2A state, while HLE keeps these shader constants and inline attributes in its own storage!

This prevents the two from messing with each other!

### Modified files

All files are relative to `src/core/hle/D3D8/`.

| File | Why it changed |
| --- | --- |
| `XbVertexShader.cpp` | Keeps HLE constants and dirty flags separate so push-buffer processing cannot overwrite them. |
| `XbVertexShader.h` | Exposes that HLE storage to uploads, readback, and vertex state shader execution. |
| `XbVertexBuffer.cpp` | Keeps inline attributes separate too, so new inline vertices start with HLE's values. |
| `Direct3D9/Direct3D9.cpp` | Makes uploads, readback, and state shaders use the HLE copy, and stops the final upload from including an extra constant. |

Here is the [commit diff](https://github.com/BSBussell/Cxbx-Future/commit/16dcae3aa16fb0e679e3a873994bece76e426cf4) to observe exactly what changed for the curious.

### What about the original white flash fix

There is some history, for the people who don't know, essentially an anonymous individual shared with JSRF admins the source for a white flash fix. There is some more complicated history there in that it was done by backporting a modern Cxbx-Reloaded commit to a 2025 build, but that build had its own errors.

The supplied original white-flash fix used the same state separation but added one extra `float4` to `g_HleVertexShaderConstants` in `XbVertexShader.cpp` to accommodate an off-by-one upload in `CxbxUpdateDirtyVertexShaderConstants`. This implementation just corrects the count instead. The renderer uses [192 constant registers](../../src/core/hle/D3D8/XbD3D8Types.h), stored here at indices 0 through 191. A final dirty batch starting at index `s` therefore uploads `191 - s + 1`, or `192 - s`, constants. The old `192 - s + 1` count read beyond the guest constant array and overwrote host register 192, which stores the first default vertex attribute. So, no padding is needed when we have the corrected count.

This version also fixes `D3DDevice_GetVertexShaderConstant` so the getter reads the same storage that HLE setters and state shaders update. It reads back the latest values stored by HLE, instead of whatever happens to be in the host D3D registers after a draw or fixed-function pass. Those registers can contain older values or host rendering data, so they are not a reliable copy of the game's constants. The getter now checks the register and count bounds and clamps a request that runs past the end. The setter already had range checks and count clamping in the supplied patch, but now the register range is checked before adding the 96-register offset, avoiding an overflow from that adjustment. Just to be a lil extra defensive 🙂

### Validation and remaining checks

The Release build successfully completed using MSVC 14.33. We have also observed no regressions during brief testing on Beatrice's desktop machine and her MacBook through CrossOver (Wine). Both builds accomplished the goal of fixing the white flash and ran excellently without issues.
