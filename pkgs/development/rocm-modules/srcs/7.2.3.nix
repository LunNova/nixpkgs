# Source pins for the ROCm STABLE stream (rocm-7.x tags).
# Maintained by ../srcs-gen.py — see also srcs/<version>.nix per stream.
# Data only: version + fetch coordinates. sourceRoot/postFetch live in recipes.
{
  rocmVersion = "7.2.3";
  # Tag prefix this stream's tracking packages use on rocm-systems/rocm-libraries.
  # Stable = "rocm-"; preview ("+10") stream = "therock-". Used by update tooling.
  tagPrefix = "rocm-";
  packages = {
    amdsmi = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/amdsmi"
        "shared"
      ];
      hash = "sha256-TFi+3txemvV6K827e8S3hZOd9jcj4Qzop6V9CdKrpLg=";
      extraSrcs.esmi_ib = {
        owner = "amd";
        repo = "esmi_ib_library";
        rev = "esmi_pkg_ver-4.2";
        hash = "sha256-czF9ezkAO0PuDkXh8y639AcOZH+KVcWiXPX74H5W/nw=";
      };
    };
    aotriton = {
      version = "0.11.1b";
      owner = "ROCm";
      repo = "aotriton";
      tag = "0.11.1b";
      leaveDotGit = true;
      hash = "sha256-F7JjyS+6gMdCpOFLldTsNJdVzzVwd6lwW7+V8ZOZfig=";
    };
    aqlprofile = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/aqlprofile"
        "shared"
      ];
      hash = "sha256-74HjB5Ughu17rSRx9mfCCsPJI4TVyXnT4aU7vIbm7ak=";
    };
    clr = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/clr"
        "shared"
      ];
      hash = "sha256-n8yWWDxE36m2NN0cmqHXQy5omYPiYoqnaNbqWm63q3E=";
    };
    composable_kernel_base = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/composablekernel"
        "shared"
      ];
      hash = "sha256-Zs6wwPmys1kUlgDD4XzKKw273nH/Ur3HtuYxJjvjDs0=";
    };
    half = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "half";
      rev = "rocm-7.2.3";
      hash = "sha256-If9O5BEeymsLN+C0drZsPSxEWXpJTxeDBGNHNXSumm4=";
    };
    hip-common = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hip"
        "shared"
      ];
      hash = "sha256-orfTXKjcZJ5E73cmXEyltZVYhCQo8FLExVHM3J/rqUM=";
    };
    hipblas = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipblas"
        "shared"
      ];
      hash = "sha256-1+aNDotV5liHBnGddmWtaKYCcsWPxQD3AoEubnghV0M=";
    };
    hipblas-common = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipblas-common"
        "shared"
      ];
      hash = "sha256-83LgS4I1fMSaNtWdVFf1qhYRMT7a9jVzO3XpUzEipXg=";
    };
    hipblaslt = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipblaslt"
        "shared"
      ];
      hash = "sha256-+xMmPKb32NP9U35dHCXfXWwa6exfiL5TezfXERVDfe4=";
    };
    hipcub = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipcub"
        "shared"
      ];
      hash = "sha256-geO6LS1osKAlmVRtiZ6keqFHsJccyB7pRZdWPEkue2M=";
    };
    hipfft = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipfft"
        "shared"
      ];
      fetchSubmodules = true;
      hash = "sha256-EtxZuxBPx6trTN9iC7uri2+UR0Eolp919Ry4U1PEqNA=";
    };
    hipfort = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "hipfort";
      rev = "rocm-7.2.3";
      hash = "sha256-XaB4jauCN41tgD1YHHA2td/yckwfMBemBe/iL0SCxQo=";
    };
    hipify = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "HIPIFY";
      rev = "rocm-7.2.3";
      hash = "sha256-LC0lnYetV7RPVw92zew6za6bDH4zmnERXUM4MVaRVtc=";
    };
    hiprand = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hiprand"
        "shared"
      ];
      hash = "sha256-bjcwjN1dNukhoDAbiSpATlK6dtAwM8bOJTe3IjhdwwY=";
    };
    hiprt = {
      version = "3.0.3.a1525e7";
      owner = "GPUOpen-LibrariesAndSDKs";
      repo = "HIPRT";
      tag = "3.0.3.a1525e7";
      hash = "sha256-7r7KO+WuXOeQQhYLYpJRrD4ZqVsBOqaD2NGD15CWnoo=";
    };
    hipsolver = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipsolver"
        "shared"
      ];
      hash = "sha256-ts5wuXHoBFZ1WMAk8Ir5cucP75G0SMOWmn3FEH04ZEQ=";
    };
    hipsparse = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/hipsparse"
        "shared"
      ];
      hash = "sha256-E1chG+giFtf02fjutoV4yM2XvrQKjgXRSvxs0NBBkvI=";
    };
    llvm = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "llvm-project";
      rev = "rocm-7.2.3";
      hash = "sha256-TwFvQimbax2E37ZC/52lNkHXCgyBNfSGDBaqmas2x/s=";
      rocmLlvmVersion = "22.0.0-rocm";
    };
    migraphx = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "AMDMIGraphX";
      rev = "rocm-7.2.3";
      hash = "sha256-raYsrMZASdEIxSstk14b38q9dt5EOq3rKidoFvobnxk=";
    };
    miopen = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/miopen"
        "shared"
      ];
      fetchSubmodules = true;
      hash = "sha256-plZpBTbEBVMa5CasjfbUsu45xP/BYstrEpWKK2H7QQ4=";
    };
    mivisionx = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "MIVisionX";
      rev = "rocm-7.2.3";
      hash = "sha256-LyiPcZi4vU0R+eI/AbYk8ioewuqET5lCtArtPltJ+Gw=";
    };
    mscclpp = {
      version = "unstable-2024-12-13";
      owner = "microsoft";
      repo = "mscclpp";
      rev = "ee75caf365a27b9ab7521cfdda220b55429e5c37";
      hash = "sha256-/mi9T9T6OIVtJWN3YoEe9az/86rz7BrX537lqaEh3ig=";
    };
    rccl = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rccl";
      rev = "rocm-7.2.3";
      hash = "sha256-A1IQYIDWqu3JLiPQ70G52s1/0ZweQxFlgMUH81qJWmU=";
    };
    rdc = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rdc"
        "shared"
      ];
      hash = "sha256-SmySauRxFnEQJVTjGYf4TpmQclTwZG2RZrk3u6ko5Qo=";
    };
    rocalution = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocALUTION";
      rev = "rocm-7.2.3";
      hash = "sha256-yPM26e8tGNpPScIriAPRb+6OZfdpX4PgE0E9bmc3FkU=";
    };
    rocblas = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocblas"
        "shared"
      ];
      hash = "sha256-wrjcr2ASSF+bk5atjvKfIYSbg+vevo/a2W2ca9Nft/4=";
    };
    rocdbgapi = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "ROCdbgapi";
      rev = "rocm-7.2.3";
      hash = "sha256-KqvhwfIv8pbr8WbnfAKl71fg5yxbwYcpzZcGU9Htdkc=";
    };
    rocfft = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocfft"
        "shared"
      ];
      hash = "sha256-RjWMzLX0nBA8ClweJ8YgRTn+Nzt/VUkOoSw3jMQ3IWg=";
    };
    rocgdb = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "ROCgdb";
      rev = "rocm-7.2.3";
      hash = "sha256-oml/HLExnnjh7+axeWPZRWecpwK2BnzVOaGvXYhrxKs=";
    };
    rocm-bandwidth-test = {
      version = "6.3.3";
      owner = "ROCm";
      repo = "rocm_bandwidth_test";
      rev = "rocm-6.3.3";
      hash = "sha256-dHyfYpRB13wUvim152nZ61McZOQ1zUZFx4dUo2vVqZM=";
    };
    rocm-cmake = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-cmake";
      rev = "rocm-7.2.3";
      hash = "sha256-gY6jzIIN1pSXGbCMN6y35Q/VJgbIqWDRjD8aI/fc1L0=";
    };
    rocm-core = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocm-core"
        "shared"
      ];
      hash = "sha256-Y3WuDwruD5zKN2epwfUCZAGq5vgxCT27awJN8JxmOsY=";
    };
    rocm-docs-core = {
      version = "1.34.0";
      owner = "ROCm";
      repo = "rocm-docs-core";
      rev = "v1.34.0";
      hash = "sha256-dVX+e0nk9/GT0idXNvLwCuN8Fh/r0dWIvqToU9cxKxs=";
    };
    rocm-runtime = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocr-runtime"
        "shared"
      ];
      hash = "sha256-hcyjOLMtoBX/p6r6R9Bl9635DuvI6rTn1KziHMeyYM0=";
    };
    rocm-smi = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocm-smi-lib"
        "shared"
      ];
      hash = "sha256-Si8SbeVKUBtqk6h2QJ9ssQV68bLq6TvESrYXJuArHd8=";
    };
    rocminfo = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocminfo"
        "shared"
      ];
      hash = "sha256-0esRBEXVibC2uzyonpc0ABNNHQ2NAWZrBmmg6p1zP0c=";
    };
    rocmlir = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocMLIR";
      rev = "rocm-7.2.3";
      hash = "sha256-0OvQT8pX6GbEqUwuauKGI66IHw8dsnt5mIijnzYyiRc=";
    };
    rocprim = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocprim"
        "shared"
      ];
      hash = "sha256-e0mZ27OXyblcnXQGv2ex/CvWx9smw6nBbHZIijj7lP8=";
    };
    rocprof-compute-viewer = {
      version = "0.1.6";
      owner = "ROCm";
      repo = "rocprof-compute-viewer";
      rev = "0.1.6";
      hash = "sha256-hjwqU5TxV4p2EjGy5haQfQqItVtYMI7i/VIfrKZvqhE=";
    };
    rocprof-trace-decoder = {
      version = "0.1.7";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "feeca99950c590e0b8228733405c4a1a10fa4773";
      sparseCheckout = [
        "projects/rocprof-trace-decoder"
        "shared"
      ];
      hash = "sha256-aJhPiZf5380jj2IeCipgcTEQYogr5R19UnVwKRGnkxo=";
    };
    rocprofiler = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocprofiler"
        "shared"
      ];
      fetchSubmodules = true;
      hash = "sha256-Wo0pymD8LsrdczdIUEEVe5x2Id//KIFkh40kliAQgWo=";
    };
    rocprofiler-register = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocprofiler-register"
        "shared"
      ];
      hash = "sha256-XhxED3LHIjxBcSVyyEC3pgg0fyKyfKtHkF7umExSboM=";
    };
    rocprofiler-sdk = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocprofiler-sdk"
      ];
      fetchSubmodules = true;
      hash = "sha256-SQjV1FnAgnK1LS5SiApgfvDSjB3AKpucja+PBZSmLvQ=";
    };
    rocr-debug-agent = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocr_debug_agent";
      rev = "rocm-7.2.3";
      hash = "sha256-w2Zg4kpuKy68DkVGsBTUsjRZoV/Y/Z3Q8s0oSIR3Ask=";
    };
    rocrand = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocrand"
        "shared"
      ];
      hash = "sha256-tl++h7LSEXf0jWe007+RIRwYHdB6TKPDpzipj1Emew8=";
    };
    rocsolver = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocsolver"
        "shared"
      ];
      hash = "sha256-n+Y8RheA0UYeSfpvOw5zfwe4VAW5hsKjlCXtBceGhf0=";
    };
    rocsparse = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocsparse"
        "shared"
      ];
      hash = "sha256-hkfBTcLig39al2w8zFTSQQnouaou9wlD6VlvIyFTNMg=";
    };
    rocthrust = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocthrust"
        "shared"
      ];
      hash = "sha256-wHEgpmBZCYtvp+OyebrRyfoFz3WQyKWfHPrdzQVL8lY=";
    };
    roctracer = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-systems";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/roctracer"
        "shared"
      ];
      hash = "sha256-Ps9b/MMdxXthGV96ZDg0kZGPdmn7Sy5if1a/Fjx2fEE=";
    };
    rocwmma = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "projects/rocwmma"
        "shared"
      ];
      hash = "sha256-eoF8a7zknpgvDOSDzolOrdtszUJ5tC7Ur2sRShiQEO0=";
    };
    rpp = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rpp";
      rev = "rocm-7.2.3";
      hash = "sha256-6e4JHKFC2dvtSGo9xbQKzIdUwlHB09pr5C/5xHwP3l4=";
    };
    tensile = {
      version = "7.2.3";
      owner = "ROCm";
      repo = "rocm-libraries";
      rev = "rocm-7.2.3";
      sparseCheckout = [
        "shared/tensile"
        "shared"
      ];
      hash = "sha256-sYudPiEPGeZLmf6+3XfQDZqRXiKgRsGPucApzYwlGV8=";
    };
  };
}
