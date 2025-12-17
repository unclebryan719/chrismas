#!/bin/bash

# 一键下载 Christmas Galaxy 所需的外部资源到本地
# 运行方式：
#   cd /Users/unclebryan/IdeaProjects/chrismas
#   chmod +x ./download_assets.sh
#   ./download_assets.sh
#
# 说明：
# - 脚本会创建 libs / assets 目录，并从官方 CDN 下载 three.js / mediapipe / 纹理 / 字体。
# - 需要当前环境可以访问外网（可以用 VPN，下载完成后本地运行就不再需要 VPN 了）。

set -e

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Base dir: $BASE_DIR"

echo "=== 创建目录结构 ==="
mkdir -p "$BASE_DIR/libs/three/build"
mkdir -p "$BASE_DIR/libs/three/examples/jsm/controls"
mkdir -p "$BASE_DIR/libs/three/examples/jsm/environments"
mkdir -p "$BASE_DIR/libs/three/examples/jsm/loaders"
mkdir -p "$BASE_DIR/libs/three/examples/jsm/geometries"
mkdir -p "$BASE_DIR/libs/three/examples/jsm/math"

mkdir -p "$BASE_DIR/libs/mediapipe/hands"

mkdir -p "$BASE_DIR/assets/textures"
mkdir -p "$BASE_DIR/assets/fonts"

echo "=== 下载 three.js 0.160.0 模块及扩展（核心来自 cdnjs，examples 来自 unpkg） ==="

curl -L "https://cdnjs.cloudflare.com/ajax/libs/three.js/0.160.0/three.module.js" \
  -o "$BASE_DIR/libs/three/build/three.module.js"

# 注意：cdnjs 不提供 examples/jsm，使用 unpkg 的版本固定地址
curl -L "https://unpkg.com/three@0.160.0/examples/jsm/controls/OrbitControls.js" \
  -o "$BASE_DIR/libs/three/examples/jsm/controls/OrbitControls.js"

curl -L "https://unpkg.com/three@0.160.0/examples/jsm/environments/RoomEnvironment.js" \
  -o "$BASE_DIR/libs/three/examples/jsm/environments/RoomEnvironment.js"

curl -L "https://unpkg.com/three@0.160.0/examples/jsm/loaders/FontLoader.js" \
  -o "$BASE_DIR/libs/three/examples/jsm/loaders/FontLoader.js"

curl -L "https://unpkg.com/three@0.160.0/examples/jsm/geometries/TextGeometry.js" \
  -o "$BASE_DIR/libs/three/examples/jsm/geometries/TextGeometry.js"

curl -L "https://unpkg.com/three@0.160.0/examples/jsm/math/MeshSurfaceSampler.js" \
  -o "$BASE_DIR/libs/three/examples/jsm/math/MeshSurfaceSampler.js"

echo "=== 下载 MediaPipe 相关脚本（来自 jsDelivr，使用最新稳定版本） ==="

# 注意：utils 库用最新版本，hands 本身我们锁定到 0.4.1675469240（在 hands.js 中写明）
MP_VER="0.4.1675469240"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils/camera_utils.js" \
  -o "$BASE_DIR/libs/mediapipe/camera_utils.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/control_utils/control_utils.js" \
  -o "$BASE_DIR/libs/mediapipe/control_utils.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/drawing_utils/drawing_utils.js" \
  -o "$BASE_DIR/libs/mediapipe/drawing_utils.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands.js" \
  -o "$BASE_DIR/libs/mediapipe/hands.js"

echo "=== 下载 MediaPipe Hands 所需的模型 / wasm 文件（固定版本 0.4.1675469240） ==="

# 打包好的参数与模型数据（binary，已验证可下载）
curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_packed_assets.data" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_packed_assets.data"

# hands.js 内部实际引用的文件名：
#   hands_solution_packed_assets_loader.js
#   hands_solution_wasm_bin.js
#   hands_solution_simd_wasm_bin.js

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_packed_assets_loader.js" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_packed_assets_loader.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_wasm_bin.js" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_wasm_bin.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_wasm_bin.wasm" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_wasm_bin.wasm"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_simd_wasm_bin.js" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_simd_wasm_bin.js"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands_solution_simd_wasm_bin.wasm" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands_solution_simd_wasm_bin.wasm"

# 图计算图和 tflite 模型（full / lite），Hands 在运行时会通过 locateFile 请求它们
curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hands.binarypb" \
  -o "$BASE_DIR/libs/mediapipe/hands/hands.binarypb"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hand_landmark_full.tflite" \
  -o "$BASE_DIR/libs/mediapipe/hands/hand_landmark_full.tflite"

curl -L "https://cdn.jsdelivr.net/npm/@mediapipe/hands@${MP_VER}/hand_landmark_lite.tflite" \
  -o "$BASE_DIR/libs/mediapipe/hands/hand_landmark_lite.tflite"

echo "=== 下载雪花纹理（three.js 官方示例） ==="

curl -L "https://threejs.org/examples/textures/particles/snowflake1.png" \
  -o "$BASE_DIR/assets/textures/snowflake1.png"

echo "=== 下载 3D 字体文件（three.js 官方示例） ==="

curl -L "https://threejs.org/examples/fonts/helvetiker_bold.typeface.json" \
  -o "$BASE_DIR/assets/fonts/helvetiker_bold.typeface.json"

echo "=== 全部资源下载完成，可以在浏览器中直接打开 index.html 体验啦！==="


