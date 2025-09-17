# luci-app-nyn

**luci-app-nyn** is a Front-end interface in openwrt for nyn - the modern 802.1x standard authentication client.

## How to build

- First clone this repository to the package directory of the openwrt you want to compile:

```
cd ./package
git clone https://github.com/Dichgrem/luci-app-nyn.git
```
- Then select ``Network->nyn`` and ``LuCI->Applications->luci-app-nyn`` in make menuconfig and change them to "M" state;

- Finally, run
```
make package/luci-app-nyn/clean V=s
make package/luci-app-nyn/compile V=s 
```
and
```
make package/nyn/clean V=s
make package/nyn/compile V=s
```
to start build.

- You can use this command to find the compiled ipk:

```
❯ find bin/ -name "nyn*.ipk"
bin/packages/x86_64/base/nyn_1.0.0-r1_x86_64.ipk
❯ find bin/ -name "luci-app-nyn*.ipk"
bin/packages/x86_64/base/luci-app-nyn_0_all.ipk
```

## Acknowledgements

- [diredocks/nyn](https://github.com/diredocks/nyn)
- [bitdust/njit8021xclient](https://github.com/bitdust/njit8021xclient)

