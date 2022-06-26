# toggle-monitor-grayscale
This script toggles your Xorg monitor(s) between color and grayscale.  The DDC method works with Wayland.
It can be bound to a keyboard shortcut to easily toggle on the fly.

## Why ?

- grayscale can cause less eye strain for some people. 
Especially combined with a warm monitor color preset (that filters out most blue light) and light themes
for both your Desktop Environment and apps, for creating a paper-like looking desktop.
Try it and you might be surprised !
- grayscale can increase concentration and reduces distractions. I've also found it to have a calming effect

## How does it work ?

The script can turn the monitor into grayscale using 3 separate methods:

### Compositor based method

For this method, you must use `picom` (recommended) or `compton` (untested) as compositor and have a video card 
that plays nice with the `glx` backend (probably most of them these days).
These compositors are often used in conjunction with tiling Window Managers such as `i3`.
To use `compton` in place of `picom` you will have to edit the `compositor` variable at the beginning of the script.
This method uses a glx shader to transform color to grayscale.

##### Advantages

- not video card specific
- screenshots taken are in grayscale

##### Drawbacks

- requires specific compositor

### NVIDIA based method

You will need a NVIDIA card and the NVIDIA proprietary drivers.
This method uses the Digital Vibrance property of these drivers to transform the 
colors to grayscale.

##### Advantages

- not specific to a compositor
- can be applied to only a specific monitor (see usage)
- can be used to only desaturate colors instead of full grayscale. 
  Edit script and set variable `desaturate_value` in function `toggle_nvidia` to a value between -1024 and 0 (-1024 => full grayscale)
- simplier than restarting the compositor  

##### Drawbacks

- video card specific
- on Optimus laptops, will not work with the laptop's panel. Will work with external screens managed by the dGPU
- minor: grayscale persists if you exit Xorg without resetting color
- minor: Digital Vibrance cannot be captured on screenshots, thus always in color

### DDC/CI based method

DDC/CI is a protocol that allows a program to change monitor settings, such as contrast, brightness and more.
Here, we use program [`ddcutil`](https://github.com/rockowitz/ddcutil/) to change the saturation parameter of a monitor (if it supports it), setting saturation to 0 for grayscale.

You will need to install the `ddcutil` tool, likely available as a package for your distro.
Your monitor must support DDC/CI. Most of them support it, but on some monitors DDC/CI can be enabled/disabled in its OSD, so make sure
to check that.

Then try `toggle-monitor-grayscale.sh ddc` to check if `ddcutil` detects your monitor and supports changing the saturation attribute.
If `ddcutil` does not detect your monitor, look into its documentation for possible solutions.

##### Advantages

- not specific to a compositor nor graphic card
- works with Wayland
- can be applied to only a specific monitor (see usage)
- can be used to only desaturate colors instead of full grayscale. 
  Edit script and set variable `desaturate_value` in function `toggle_ddc` to a value between 0 and maximum saturation / 2 (0 => full grayscale)
- simplier than restarting the compositor  

##### Drawbacks

- does not work with all monitors
- does not work with laptop panels as they do not support DDC/CI 

## Comparison between compositor and NVIDIA methods

It is not possible to make a screenshot of a graycaled screen with the NVIDIA method (unlike the compositor method).
The only way I've found to compare them is to take a screenshot of the screen in color and a second screenshot with the compositor method in grayscale.
Then compare both screenshots on [this web site](https://www.diffchecker.com/image-diff/) turning grayscale with the NVIDIA method which will grayscale the color screenshot 
to the NVIDIA method but not have any effect on the already grayscaled compositor screenshot.
It turns out that the NVIDIA method produces darker grayscale than the compositor method, preserving more details on images such as photos (at the expense of
making them darker). The difference between the 2 methods is marginal for text.

## Get the script

```
cd /somewhere/in/your/PATH
wget https://raw.githubusercontent.com/bubbleguuum/toggle-monitor-grayscale/main/toggle-monitor-grayscale.sh && chmod +x toggle-monitor-grayscale.sh
```

## Usage

```
toggle-monitor-grayscale.sh -h

toggle-monitor-grayscale.sh [picom|nvidia|ddc|auto]
toggle-monitor-grayscale.sh picom [picom args]
toggle-monitor-grayscale.sh nvidia [nv mon]
toggle-monitor-grayscale.sh ddc [ddc mon]

picom:   use a GLX shader to set grayscale
nvidia:  use NVIDIA proprietary driver Digital Vibrance setting to set grayscale
ddc:     use DDC/CI monitor protocol to set the monitor saturation to 0 (grayscale) if supported by monitor
auto:    use picom if running, otherwise nvidia if available, otherwise ddc if available

picom args: in picom mode, optional picom parameters

nv mon:     in nvidia mode, an optional monitor name as enumerated by xrandr.
            if unspecified, apply to all monitors managed by the NVIDIA driver
ddc mon:    in ddc mode, optional ddcutil options to identify the monitor. See 'man ddcutil'
            if unspecified, apply to the first monitor detected by ddcutil
if invoked with no argument, auto is used.
```

## Improving grayscale experience

If you use grayscale mode most of the time, you will probably want to do some adjustments to your setup,
some of which are personal preference:

#### General

- if your monitor has a warm color preset, use it (or make your own). For example, my monitor has a "Paper" preset and it is perfect, cutting a lot of blue light
- consider using a light theme for your Desktop Environment (if not using a standalone WM) and apps


#### Terminal

- configure your terminal to use a white (or light) background combined with black text
- you will notice that the colored output of `ls` is not that readable. You can either disable color for `ls` (make sure 
that the `--color` option is not passed to it, often in an alias or shell function of your distro), or you can use the `.dir_colors_grayscale` file of this
repo which disables all colors, except folders that are bold. To use it: `eval $(dircolors -b .dir_colors_grayscale)` or if you want to make it permanent
copy that file as `~/.dir_colors`. This file can also be customized if you want to add more font styling (italics, underline, reverse video, ...) to some file types. It is also a good idea to use the -F option of `ls` for appending a character at the end of folder, executable, link... files to indidicate their types (see `man ls`).

#### Syntax highlighting

Syntax highlighting in editors and IDEs will likely have to be revised to be grayscale friendly. This can use a combination of bold, italics, underline and maybe 1 or 2 colors that can be distinguished from normal text while remaining readable. There may be some premade eink color schemes available that can be used.

#### Firefox

Firefox may need some adjustments too, especially to make links easier to see. 
Fo this, create of modify the `userContent.css` file in `/path/to/your/firefox profile/chrome` folder:

```
a {
    color: #000000 !important;
    background-color:transparent !important; /* necessary so link is always readable */
    text-decoration: underline !important; 
}  /* Unvisited link color */

a:visited {
    color: #7f7f7f !important;
    background-color:transparent !important; /* necessary so link is always readable */
    text-decoration: underline !important; 
}   /* Visited link color */

```

This will override all sites to make all links underlined (a bit heavy but very visible), unvisited link in full black and visited links in medium gray.
