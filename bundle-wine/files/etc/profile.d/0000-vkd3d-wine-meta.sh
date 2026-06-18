#!/bin/sh
export DXVK_STATE_CACHE_PATH="$HOME/.cache/dxvk" VKD3D_SHADER_CACHE_PATH="$HOME/.cache/vkd3d"
mkdir -p "$DXVK_STATE_CACHE_PATH" "$VKD3D_SHADER_CACHE_PATH" &> /dev/null
