====
NABP
====

============= =============================
Author        Xitong Gao (gxtfmx@gmail.com)
------------- -----------------------------
Version       Unreleased 0.2.x
------------- -----------------------------
Description   An efficient hardware implementation of parallelised back
              projection reconstruction for computerised tomography.
============= =============================

Current Simulation Result Image (Normalized without Truncation)
===============================================================

.. image:: http://f.cl.ly/items/3n2O3g1s461O1O0e0s20/pe_dump_180.png

Simulation Instructions
=======================

To simulate the entire design or specific parts of the architecture, run in
shell::

    ./simulate <design_name>

You can specify ``nabp``, ``processing`` or ``filtered_ram`` as your
``<design_name>`` input.

Configuration File
==================

The architecture can be configured by providing a .naconfig file.
.. TODO add support for config file input

Template Verilog Source Code
============================

Introduction
------------

Template Verilog allows a flexible implementation of the architecture, which
is designed to work with a large number of variations of its parameters. The
source files are written by inlining Python scripting language within the
Verilog source code to adopt a readable yet dynamic realisation of our design.

Code Generation
---------------

The code generation engine akpytemp_ is used to transform the Template Verilog
source files into Verilog source files.

Project Structure
=================

================ ================
Folder & Files   Description
================ ================
akpytemp/        A simple but awesome general purpose templating utility.
---------------- ----------------
build/           Contains compiled executables and the files they generates.
---------------- ----------------
cat_py/          A third party library for generating the phantom image and
                 also contains functions for the Radon and the inverse Radon
                 transforms.
---------------- ----------------
derived_src/     Preprocessed Verilog source files.
---------------- ----------------
MATLAB/          The algorithm implemented in MATLAB. This does not reflect the
                 implementation of its Verilog counterpart.
---------------- ----------------
pynabp/          Python utilities dedicated for the templated Verilog source
                 files. Also contains Python modules loadable in simulation
                 runtime.
---------------- ----------------
src/             Templated Verilog source files. Contains the actual
                 implementation of the architecture.
---------------- ----------------
vpi_pyeval/      Minimal Verilog Procedual Interface extension for Python.
---------------- ----------------
wave/            Waveform files for the GTKWave wave viewer. Used to display
                 signals for the test cases.
================ ================

MATLAB Algorithm Instructions
=============================

The MATLAB code shows the algorithm of our new back projection reconstruction
architecture. It is used as a verification of correctness, but not an actually
efficient algorithm to be used in a software implementation.

Example usage (In MATLAB)::

    figure; nabp(radon(phantom()), 0:179);

TODOs
=====

Run in shell::

    git grep TODO

Dependencies
============

====================== =======================
Dependency             Description
====================== =======================
akpytemp_              A Simple but Awesome General Purpose Templating Utility
---------------------- -----------------------
vpi_pyeval_            Minimal Verilog Procedual Interface Extension for Python
---------------------- -----------------------
`Icarus Verilog 0.9`_  Open source Verilog simulation and synthesis tool
---------------------- -----------------------
GTKWave_               GTK+ based wave viewer for Unix, Win32, and Mac OSX
---------------------- -----------------------
`PIL 1.1.7`_           Python Imaging Library
---------------------- -----------------------
PBS_                   A Python subprocess wrapper
====================== =======================


.. _akpytemp: http://github.com/admk/akpytemp
.. _vpi_pyeval: http://github.com/admk/vpi_pyeval
.. _Icarus Verilog 0.9: http://iverilog.icarus.com
.. _GTKWave: http://gtkwave.sourceforge.net
.. _PIL 1.1.7: http://www.pythonware.com/products/pil/
.. _PBS: http://github.com/amoffat/pbs


License
=======

NABP
Copyright © 2016 Xitong Gao

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


.. vim:tw=78:sw=4:ts=8:ft=rst:norl
