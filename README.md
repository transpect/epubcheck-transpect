# epubcheck-transpect
XProc pipeline to check EPUBs for compliance with IDPF EPUB2/3, Amazon MOBI/KF8, retailer, and publisher requirements

## Requirements

* Java 1.7 or higher
* Bash if you don’t want to invoke calabash directly

## Installation

Download the [latest release](https://github.com/transpect/epubcheck-transpect/releases) or checkout with git:
```
git clone https://github.com/transpect/epubcheck-transpect.git --recursive
```
If you want to see kindlegen errors, you’d have to get [kindlegen](http://www.amazon.com/gp/feature.html?docId=1000765211) and copy the kindlegen binary to `infrastructure/kindlegen/i386/kindlegen` (for Linux), `infrastructure/kindlegen/i386/macos/kindlegen` (for Mac OS), or `infrastructure/kindlegen/i386/kindlegen.exe` (for Windows). You’ll have to create the directory beforehand.

## Invocation

In the directory that the checkout created:
```
./epubcheck-transpect /path/to/file.epub
```
Invocation without arguments will show you the options.

For direct invocation of calabash, please look at how it is invoked in the [epubcheck-transpect](epubcheck-transpect) script. For Windows, until we provide an `epubcheck-transpect.bat` file, you can use this calabash invocation with `calabash\calabash.bat` instead of `calabash/calabash.sh`.

# Customization

## Parameter Set

The parameters for image size checking etc. are in [config/params.xml](config/params.xml). We will provide an option to supply another parameter file. 

## Custom Schematron

There will also be an option to run your own Schematron in addition to the [one that is bundled](https://github.com/transpect/epubtools/blob/master/schematron/epub.sch.xml). Run epubcheck-transpect with `-s` switch and add the path to your own Schematron file. The file `example/example.sch` provides an example. You may extend it for your needs.

Schematron files are always applied to an XML representation of the EPUB file. In order to find out what the input for Schematron looks like, invoke the check with `-d`, the debug switch. You’ll find a file `debug/epubcheck-validate/wrap-with-srcpaths.xml` in the debug directory that the script will tell you. This file also has an `<?xml-model?>` processing instruction that points to the canonical URL of the Schematron file. If you are using oXygen XML Editor and if you have opened the project [epubcheck-transpect.xpr](epubcheck-transpect.xpr), you will be able to perform the bundled Schematron check on this wrapper file. You can add an additional Schematron schema association that points to your custom Schematron.
