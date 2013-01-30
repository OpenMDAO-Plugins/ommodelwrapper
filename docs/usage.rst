===========
Usage Guide
===========

Using OMModelWrapper
=========================

This is a wrapper of an OpenModelica model. It compiles OpenModelica's ``.mo``
file and builds its ``.exe`` executable to be used in OpenMDAO using OpenModelica 
compiler installed on your computer.

By default, the wrapper initiation reads through the model parameter and 
variable entries with their default values and creates the inputs 
and outputs of the wrapper component correspondingly.

OMModelWrapper(moFile[, pkgName]) -> new Python wrapper of OpenModelica model    

where

::

  moFile: main model file name in String. `.mo` is not included 
    
  pkgName: additional `.mo` file or library name in String 
               (`.mo` must be included if it's in the name.)
               More than one package is not supported yet.

The following attributes are created for all OpenModelica wrapping applications:    
    
**startTime**
    
    Simulation start time (float)

**stopTime**
    Simulation stop time (float)

**stepSize**
    Time step on which simulation data are recorded as result (float)
    
**tolerance**
    Simulation solver accuracy (float)
    
**solver**
    Name of the chosen solver, which OpenModelica supports (string) 
    
**execute(...)**
    Execute the model and update the output
    
With all the above, additional attributes will be accessible based on the parameter/variable
definitions of the original OpenModelica to be wrapped.    


Example
=========
In the distribution directory ``src/ommodelwrapper/test``, there are two OpenModelica
files, ``SimAcceleration.mo`` and ``VehicleDesign.mo``. The two files are basically
an OpenModelica translation of the vehicle design example included in OpenMDAO. 
Of the two files, ``SimAcceleration.mo`` is the main model file, and ``VehicleDesign.mo`` 
is the package that contains all the classes and function declarations used by
SimAcceleration model.

To generate an OpenMDAO component wrapping the OpenModelica's SimAcceleration 
model, you write in your script:

::

  testModel = OMModelWrapper('SimAcceleration','VehicleDesign.mo')  

This will create the testModel that is an instance of OpenModelica's SimAcceleration model.
The testModel is ready to use. The following example lines execute the model and
provide the 0 to 100km/hr time of the car:

::

  testModel.stopTime = 10
    
  testModel.execute()
    
  print testModel.accel_time

  (Output is:) 6.935


