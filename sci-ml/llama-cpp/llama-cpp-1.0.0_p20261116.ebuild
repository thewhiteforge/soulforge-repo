EAPI=8

inherit cmake

DESCRIPTION="llama.cpp inference engine with NVIDIA CUDA acceleration"
HOMEPAGE="https://github.com/ggml-org/llama.cpp"

COMMIT="d998c676ff463b1b8ad94ad7c0b905e281422fad"

SRC_URI="
    https://github.com/ggml-org/llama.cpp/archive/${COMMIT}.tar.gz
        -> ${P}.tar.gz
"

S="${WORKDIR}/llama.cpp-${COMMIT}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

RESTRICT="mirror"

BDEPEND="
    dev-build/cmake
    dev-util/nvidia-cuda-toolkit
    sys-devel/gcc:14
"

DEPEND="
    dev-libs/openssl:0=
    dev-util/nvidia-cuda-toolkit
    net-misc/curl
"

RDEPEND="${DEPEND}"

src_configure() {
    export CC=/usr/bin/gcc-14
    export CXX=/usr/bin/g++-14

    local mycmakeargs=(
        -DCMAKE_CUDA_COMPILER=/opt/cuda/bin/nvcc
        -DCMAKE_CUDA_HOST_COMPILER=/usr/bin/g++-14
        -DCUDAToolkit_ROOT=/opt/cuda
        -DCMAKE_CUDA_ARCHITECTURES=75
        -DGGML_CUDA=ON
        -DGGML_CPU=ON
        -DGGML_NATIVE=OFF
        -DGGML_BLAS=OFF
        -DGGML_CUDA_NCCL=OFF
        -DLLAMA_BUILD_SERVER=ON
        -DLLAMA_BUILD_TOOLS=ON
        -DLLAMA_BUILD_APP=ON
        -DLLAMA_BUILD_EXAMPLES=OFF
        -DLLAMA_BUILD_TESTS=OFF
        -DLLAMA_BUILD_UI=OFF
        -DLLAMA_USE_PREBUILT_UI=OFF
        -DLLAMA_TOOLS_INSTALL=ON
        -DLLAMA_OPENSSL=ON
        -DLLAMA_BUILD_IS_DEV=ON
        -DBUILD_SHARED_LIBS=ON
    )

    cmake_src_configure
}

src_compile() {
    cmake_src_compile
}

src_install() {
    cmake_src_install
}
