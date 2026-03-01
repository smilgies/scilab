// generate library
// starting from Version-2M folder:
// genlib(lib_name,folder)
// > lib_name is the library name
// > folder is the folder containing the sci files
// > flag %T enforces compilation

// NOTE: the file name of a fcn has to be fcn.sci
// NOTE: this also means, only one fcn per fcn.sci
genlib("GIXSlib","GIXSlib-3A",%t,%t);

// check that all functions are in the library
// libraryinfo("GIXSlib")
