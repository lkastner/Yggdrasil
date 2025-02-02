# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder

name = "libsndfile"
version = v"1.0.31"

# Collection of sources required to build
sources = [
    ArchiveSource("https://github.com/libsndfile/libsndfile/releases/download/$(version)/libsndfile-$(version).tar.bz2",
                  "a8cfb1c09ea6e90eff4ca87322d4168cdbe5035cb48717b40bf77e751cc02163")
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir/libsndfile-*/
export CFLAGS="-I${includedir}" 
./configure --prefix=${prefix} --build=${MACHTYPE} --host=${target} --disable-static
make -j${nproc}
make install
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = supported_platforms(;experimental=true)

# The products that we will ensure are always built
products = [
    LibraryProduct("libsndfile", :libsndfile),
    ExecutableProduct("sndfile-cmp", :sndfile_cmp),
    ExecutableProduct("sndfile-concat", :sndfile_concat),
    ExecutableProduct("sndfile-convert", :sndfile_convert),
    ExecutableProduct("sndfile-deinterleave", :sndfile_deinterleave),
    ExecutableProduct("sndfile-info", :sndfile_info),
    ExecutableProduct("sndfile-interleave", :sndfile_interleave),
    ExecutableProduct("sndfile-metadata-get", :sndfile_metadata_get),
    ExecutableProduct("sndfile-metadata-set", :sndfile_metadata_set),
    ExecutableProduct("sndfile-play", :sndfile_play),
    ExecutableProduct("sndfile-salvage", :sndfile_salvage),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    Dependency("alsa_jll"),
    Dependency("FLAC_jll"),
    Dependency("libvorbis_jll"),
    Dependency("Ogg_jll"),
    Dependency("Opus_jll"),
]

# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies; julia_compat="1.6")
