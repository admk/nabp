====
NABP
====

:Author:Xitong Gao (gxtfmx@gmail.com)
:Version:Unreleased

An efficient hardware implementation of parallelised back projection
reconstruction for computerised tomography.

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

:akpytemp_: A Simple but Awesome General Purpose Templating Utility
:vpi_pyeval_: Minimal Verilog Procedual Interface (VPI) Extension for the Python Scripting Language
:`Icarus Verilog 0.9`_: Open source Verilog simulation and synthesis tool
:GTKWave_: GTK+ based wave viewer for Unix, Win32, and Mac OSX
:`PIL 1.1.7`_: Python Imaging Library

Links
=====

.. _akpytemp: http://github.com/admk/akpytemp
.. _vpi_pyeval: http://github.com/admk/vpi_pyeval
.. _Icarus Verilog 0.9: http://iverilog.icarus.com
.. _GTKWave: http://gtkwave.sourceforge.net
.. _PIL 1.1.7: http://www.pythonware.com/products/pil/


vim:tw=78:sw=4:ts=8:ft=rst:norl
