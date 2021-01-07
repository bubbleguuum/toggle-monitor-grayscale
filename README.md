# toggle-monitor-grayscale
This script toggles your Xorg monitor(s) between color and grayscale.
It can be bound to a keyboard shortcut to easily toggle on the fly.

## Why ?

- grayscale can cause less eye strain for some people. 
Especially combined with a warm monitor color preset (that filters out most blue light) and light themes
for both your Desktop Environment and apps, for creating a paper-like looking desktop.
Try it and you might be surprised !
- grayscale can increase concentration and reduces distractions. I've also found it to have a calming effect

## How does it work ?

The script employs two distinct methods to make the screen grayscale.
Both give close results in term of grayscale but they are difficult to compare
as the nvidia method cannot be screenshotted:

### Compositor based 

You must use picom (recommended!) or compton (untested) for this method to work.
It uses a glx shader to transform color to grayscale.
These compositors are often used in conjunction with tiling Window Managers such as i3.
To use `compton` in place of `picom` you will have to edit the `compositor` variable of the script.

##### Advantages

- not video card specific
- screenshot taken are in grayscale

##### Inconvenients

- requires specific compositor

### NVIDIA drivers based

You will need a NVIDIA card and the NVIDIA proprietary drivers.
It uses the Digital Vibrance property of these drivers to transform the 
colors to grayscale.

##### Advantages

- not specific to a compositor
- can be set to only a specific monitor (see usage)
- can be used to only desaturate colors instead of full grayscale. 
  Edit script and set variable `desaturate_value` to a value between -1024 and 0 (-1024 => full grayscale)

##### Inconvenients

- video card specific
- on Optimus laptops, will not work with the laptop's panel. Will work with external screens managed by the dGPU
- minor: grayscale persists if you exit Xorg without resetting color
- minor: screenshots taken are not in grayscale

## Get the script

```
cd /somewhere/in/your/PATH
wget https://raw.githubusercontent.com/bubbleguuum/toggle-monitor-grayscale/main/toggle-monitor-grayscale.sh && chmod +x toggle-monitor-grayscale.sh
```

## Usage

```
toggle-monitor-grayscale.sh -h

Toggle monitors between color and grayscale mode.

toggle-monitor-grayscale.sh [picom|nvidia|auto]
toggle-monitor-grayscale.sh picom [picom args]
toggle-monitor-grayscale.sh nvidia [monitor]

picom:   use a picom glx shader to set grayscale
nvidia:  use NVIDIA proprietary driver Digital Vibrance setting to set grayscale
auto:    use picom if running, othewise nvidia if available

picom args: in picom mode, optional picom parameters
monitor: in nvidia mode, an optional monitor name as listed by xrandr
         if unspecified, apply to all monitors managed by the NVIDIA driver

if invoked with no argument, auto is used.
```

## Improving grayscale experience

If you use grayscale mode most of the time, you will probably want to do some adjustments to your setup,
some of which are personal preference:

- if your monitor has a warm color preset, use it (or make your own). For example, my monitor has a "Paper" preset and it is perfect, cutting a lot of blue light
- consider using a light theme for your Desktop Environment (if not using a standalone WM) and apps
- configure your terminal to use a white (or light) background combined with black text
- you will notice that the colored output of `ls` is not that readable. You can either disable color for `ls` (make sure 
that the `--color` option is not passed to it, often in an alias or shell function of your distro), or you can use the `.dir_colors_grayscale` file of this
repo which disables all colors, except folders that are bold. To use it: `eval $(dircolors -b /path/to/.dir_colors_grayscale)` or if you want to make it permanent
copy that file as `~/.dir_colors`. This file can also be customized if you want to add more font styling (italics, underline, reverse video, ...) to some file types. It is also a good idea to use the -F option of `ls` for appending a character at the end of folder, executable, link... files to indidicate their types (see `man ls`).
- syntax highlighting in editors and IDEs will likely have to be revised to be grayscale friendly. This can use a combination of bold, italics, underline and maybe 1 or 2 colors that can be distinguished from normal text while remaining readable. There may be some premade eink color schemes available that can be used.
