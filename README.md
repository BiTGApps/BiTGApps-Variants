## Build your own BiTGApps

**The example git commands assume you have a [GitHub account](https://github.com/join) and have set-up [SSH authentication](https://help.github.com/articles/set-up-git/#connecting-over-ssh).**

If you want to build your own version of BiTGApps, you'll need to fetch the git sources using below commands:

**1. Download script**

```shellscript
curl -sLo sources.sh https://raw.githubusercontent.com/BiTGApps/BiTGApps-Variants/master/sources.sh
```

**2. Fetch sources**

```shellscript
. sources.sh 'args'
```

> _Set argument to either 'basic' or 'omni' without quotes._

**To build BiTGApps you'll need the Android build tools installed and set-up in your $PATH. If you use Ubuntu you can check out [@mfonville's Android build tools for Ubuntu](http://mfonville.github.io/android-build-tools/).**

Before building, set environmental variables:

```shellscript
. envsetup.sh 'args'
```

> _Set argument to either 'BASIC' or 'OMNI' without quotes._

To build packages for all platforms and all Android releases:

```shellscript
make
```

To build BiTGApps for a specific Android release on a specific platform, define both the platform and the API level of that release, seperated by a dash.

Example (for building for Android 7.1 on ARM):

```shellscript
make arm-25
```

## License

The BiTGApps Project itself is licensed under the [GPLv3](https://www.gnu.org/licenses/gpl-3.0.txt).

[![GPLv3](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)
