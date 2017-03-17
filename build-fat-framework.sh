set -e

# If we're already inside this script then die
if [ -n "$RW_MULTIPLATFORM_BUILD_IN_PROGRESS" ]; then
  exit 0
fi
export RW_MULTIPLATFORM_BUILD_IN_PROGRESS=1

RW_FRAMEWORK_NAME=${PROJECT_NAME} #Make sure that the 'product name' of all the platforms are the same
RW_INPUT_STATIC_LIB="${PROJECT_NAME}.framework/${PROJECT_NAME}"
RW_FRAMEWORK_LOCATION="${BUILT_PRODUCTS_DIR}/${RW_FRAMEWORK_NAME}.framework"

echo "RW_FRAMEWORK_NAME: ${RW_FRAMEWORK_NAME}"
echo "RW_INPUT_STATIC_LIB: ${RW_INPUT_STATIC_LIB}"
echo "RW_FRAMEWORK_LOCATION: ${RW_FRAMEWORK_LOCATION}"

# Rebuilds the static library with the received sdk: Usage example: 'build_static_library <sdk>'
function build_static_library {
echo "Rebuilding static library with target: ${TARGET_NAME}, SDK: ${1}"
xcrun xcodebuild -quiet -project "${PROJECT_FILE_PATH}" \
  -target "${TARGET_NAME}" \
  -configuration "${CONFIGURATION}" \
  -sdk "${1}" \
  ENABLE_BITCODE=YES \
  ONLY_ACTIVE_ARCH=NO \
  BUILD_DIR="${BUILD_DIR}" \
  OBJROOT="${OBJROOT}" \
  BUILD_ROOT="${BUILD_ROOT}" \
  SYMROOT="${SYMROOT}" $ACTION
}

# Smashes 2 static libs together. Usage example: 'make_fat_library in1 in2 out'
function make_fat_library {
  echo "Merge architectures"
  echo "Source1:"
  echo "${1}"
  echo "Source2:"
  echo "${2}"
  echo "Destination:"
  echo "${3}"
  xcrun lipo -create "${1}" "${2}" -output "${3}"
}





# 1 - Extract the platform (iphoneos/iphonesimulator) from the SDK name
if [[ "$SDK_NAME" =~ ([A-Za-z]+) ]]; then
  RW_SDK_PLATFORM=${BASH_REMATCH[1]}
  echo "RW_SDK_PLATFORM: $RW_SDK_PLATFORM"
else
  echo "Could not find platform name from SDK_NAME: $SDK_NAME"
  exit 1
fi

# 2 - Extract the version from the SDK
if [[ "$SDK_NAME" =~ ([0-9]+.*$) ]]; then
  RW_SDK_VERSION=${BASH_REMATCH[1]}
  echo "RW_SDK_VERSION: $RW_SDK_VERSION"
else
  echo "Could not find sdk version from SDK_NAME: $SDK_NAME"
  exit 1
fi

# 3 - Determine the other platform
if [ "$RW_SDK_PLATFORM" == "iphoneos" ]; then
  RW_OTHER_PLATFORM=iphonesimulator
elif [ "$RW_SDK_PLATFORM" == "appletvos" ]; then
  RW_OTHER_PLATFORM=appletvsimulator
elif [ "$RW_SDK_PLATFORM" == "appletvsimulator" ]; then
  RW_OTHER_PLATFORM=appletvos
else
  RW_OTHER_PLATFORM=iphoneos
fi
echo "RW_OTHER_PLATFORM: $RW_OTHER_PLATFORM"

# 4 - Find the build directory
if [[ "$BUILT_PRODUCTS_DIR" =~ (.*)$RW_SDK_PLATFORM$ ]]; then
  RW_OTHER_BUILT_PRODUCTS_DIR="${BASH_REMATCH[1]}${RW_OTHER_PLATFORM}"
  echo "Other platform build directory: $RW_OTHER_BUILT_PRODUCTS_DIR."
else
  echo "Could not find other platform build directory."
  exit 1
fi

# Build the other platform.
build_static_library "${RW_OTHER_PLATFORM}${RW_SDK_VERSION}"

# If we're currently building for iphonesimulator, then need to rebuild to ensure that we get both i386 and x86_64
if [ "$RW_SDK_PLATFORM" == "iphonesimulator" ]; then
  build_static_library "${SDK_NAME}"
fi

# Join the 2 static libs into 1 and push into the .framework
make_fat_library "${BUILT_PRODUCTS_DIR}/${RW_INPUT_STATIC_LIB}" \
  "${RW_OTHER_BUILT_PRODUCTS_DIR}/${RW_INPUT_STATIC_LIB}" \
  "${RW_FRAMEWORK_LOCATION}/${RW_FRAMEWORK_NAME}"

# Copy Swift modules from other build (if it exists) to the copied framework directory
OTHER_SWIFT_MODULES_DIR="${RW_OTHER_BUILT_PRODUCTS_DIR}/${RW_FRAMEWORK_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/."
echo "Copying Swift modules from: ${OTHER_SWIFT_MODULES_DIR}"
if [ -d "${OTHER_SWIFT_MODULES_DIR}" ]; then
  cp -R "${OTHER_SWIFT_MODULES_DIR}" "${RW_FRAMEWORK_LOCATION}/Modules/${PROJECT_NAME}.swiftmodule"
  echo "Copied swift modules to: ${RW_FRAMEWORK_LOCATION}/Modules/${PROJECT_NAME}.swiftmodule"
fi

# Copy the framework to the build directory
echo "Copying fat framework to ${PROJECT_DIR}/build/${RW_FRAMEWORK_NAME}.framework"
ditto "${RW_FRAMEWORK_LOCATION}" "${PROJECT_DIR}/build/${RW_FRAMEWORK_NAME}.framework"
rm -rf "${RW_FRAMEWORK_LOCATION}"

echo "running framework build script DONE!!"
