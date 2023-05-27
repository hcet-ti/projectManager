# projectManager
![Showing_off_Project_Manager](http://projectmanager.great-site.net/assets/img/Showing%20Project%20Manager.gif)
A simple program to convert C files into POS homework PDFs.

🌍 Website: http://projectmanager.great-site.net

The entry point is located at `ui.c`, which contains most of the UI code. Most of the computing, converting and creating happens inside `PDFGen-0.1.0/pdfgen.c`, a library I modified a bit to fit my needs (original: https://github.com/AndreRenaud/PDFGen). Also, a big thanks to the creators of the other libraries that I used (https://github.com/deinernstjetzt/mregexp, https://github.com/Theldus/kat and of course https://github.com/fesch/Structorizer.Desktop).

## Dependencies
- Java v11 or higher
- GCC
- OpenJDK
- ImageMagick:
```
libMagickWand-7.Q16HDRI.dll.a
libMagickCore-7.Q16HDRI.dll.a

mfc140u.dll
libMagickWand-7.Q16HDRI-10.dll
libMagickCore-7.Q16HDRI-10.dll
libxml2-2.dll
libbz2-1.dll
libgcc_s_seh-1.dll
libgomp-1.dll
libheif.dll
libjbig-0.dll
libjpeg-8.dll
liblzma-5.dll
zlib1.dll
msvcp140.dll
libpng16-16.dll
libwinpthread-1.dll
libtiff-5.dll
libwebp-7.dll
libwebpdemux-2.dll
libwebpmux-3.dll
libzip.dll
libstdc++-6.dll
libaom.dll
libdav1d.dll
rav1e.dll
libx265.dll
libde265-0.dll
libdeflate.dll
libLerc.dll
libzstd.dll
libiconv-2.dll
libfreetype-6.dll
libbrotlidec.dll
libbrotlicommon.dll
libharfbuzz-0.dll
msvcp140_1.dll
msvcp140_2.dll
msvcp140_atomic_wait.dll
msvcp140_codecvt_ids.dll
libglib-2.0-0.dll
libintl-8.dll
libpcre-1.dll
libgraphite2.dll
```
