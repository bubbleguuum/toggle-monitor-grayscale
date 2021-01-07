#!/bin/bash

# should also work with compositor=compton, untested
compositor=picom

function usage {

    bin=$(basename $0)

    echo
    echo "Toggle monitors between color and grayscale mode."
    echo 
    echo "$bin [$compositor|nvidia|auto]"
    echo "$bin $compositor [$compositor args]"
    echo "$bin nvidia [monitor]"
    echo
    echo "$compositor:   use a glx shader to set grayscale"
    echo "nvidia:  use NVIDIA proprietary driver Digital Vibrance setting to set grayscale"
    echo "auto:    use $compositor if running, otherwise nvidia if available"
    echo
    echo "$compositor args: in $compositor mode, optional $compositor parameters"
    echo "monitor:    in nvidia mode, an optional monitor name as enumerated by xrandr."
    echo "            if unspecified, apply to all monitors managed by the NVIDIA driver"
    echo
    echo "if invoked with no argument, auto is used."
    echo

    exit 0
}

function toggle_nvidia {

    dpy=$1
    
    value=$(nvidia-settings -t -q DigitalVibrance)

    # set a value in [-1024..0[ range to desaturate colors instead of full grayscale
    # -1024 => full grayscale
    desaturate_value=-1024
    
    if (( value == $desaturate_value )); then
	value=0
	toggle_mode="color"
    else
	value=$desaturate_value
	toggle_mode="grayscale"
    fi

    if [ -n "$dpy" ]; then
	param="[DPY:$dpy]/DigitalVibrance"
    else
	param="DigitalVibrance"
    fi

    nvidia-settings -a ${param}=${value} > /dev/null
}

function toggle_compositor {

    if pgrep -a -x $compositor | grep glx-fshader-win > /dev/null; then
	pkill -x $compositor
	sleep 1
	$compositor $* -b
	toggle_mode="color"
    else
	pkill -x $compositor
	sleep 1

	shader='uniform sampler2D tex; void main() { vec4 c = texture2D(tex, gl_TexCoord[0].xy); float y = dot(c.rgb, vec3(0.2126, 0.7152, 0.0722)); gl_FragColor = vec4(y, y, y, 1.0); }'
	
	$compositor $* -b --backend glx --glx-fshader-win "${shader}" 2> /dev/null
	toggle_mode="grayscale"
    fi
}


mode=$1

case $mode in

    --help|-h)
	usage
	;;

    $compositor)
	if ! pgrep -x $compositor > /dev/null; then
            echo "$compositor is not running"
            exit 1
	fi
	;;

    nvidia)
	if ! which nvidia-settings > /dev/null; then
	    echo "nvidia-settings is not installed"
	    exit 1
	fi
    ;;
    
    *)
	[ -z "$mode" ] && mode=auto
	
	if [ "$mode" = "auto" ]; then

	    if pgrep -x $compositor > /dev/null; then
		mode=$compositor
	    elif which nvidia-settings > /dev/null; then
		mode=nvidia
	    else
		echo "neither running $compositor nor nvidia-settings installed"
		exit 1
	    fi
	else
	    usage
	fi
    
esac

#set -x

# pass eventual remaining arguments to toggle_* function
if (( $# > 0 )); then
   shift
fi

if [ "$mode" = "nvidia" ]; then
    toggle_nvidia $*
else
    toggle_compositor $*
fi

if (( $? == 0 )); then
    echo "$mode: set to $toggle_mode"
else
    echo "$mode: toggle failed"
fi


